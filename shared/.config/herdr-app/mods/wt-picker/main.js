// Worktree pickers: the Mac app side of the TUI's prefix+w / W / D popups
// (shared/.config/herdr/scripts/wt-picker.sh). Same look as mods/pj-picker.
//
// props.mode:
//   "pick" (default, leader W): find-or-create in the focused space's repo.
//     Type a name: the checkouts of that repo that match are listed. Enter
//     focuses a checkout's open space, opens a space for it, or (no match)
//     creates the typed name as a new worktree and opens it. ctrl+n creates the
//     typed name even when something matches.
//   "all" (leader w): every managed worktree (~/.herdr/worktrees/<repo>/<name>)
//     across all repos. Enter focuses its open space or opens one. No create.
//   "branch" (leader B): the focused space's repo's local and origin branches
//     that have no worktree yet, newest first. Enter checks the branch out into a
//     worktree (remote-only ones get a tracking branch) and opens a space for it.
//     Tab cycles the list all / local / remote (remote = origin-only branches).
//     No create, no delete. Refs are whatever is already local (no fetch).
//   "remove" (leader D): remove the focused space's worktree.
// In the "pick" and "all" lists ctrl+d offers to remove the highlighted worktree (asks first;
// forced if it has changes). ctrl+j/k move, Esc leaves.
//
// The git/worktree work is done by ~/bin/herdr-wt (Herdr-independent
// subcommands), which uses Worktrunk (`wt`) so creating runs the hooks in
// ~/.config/worktrunk/config.toml. Local only: on remote spaces leader W/D fall
// back to the shipped `worktree` mod; leader w always lists this Mac's worktrees.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { spaces, panes, focused, run, exec, theme, settings, props, closeOverlay, notify, home, shared } from "herdr";

const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };
const ROW = 32;
const LIST_MAX = 320;

const norm = (p) => (p ?? "").replace(/\/+$/, "");
const inside = (p, dir) => p === dir || p.startsWith(`${dir}/`);

// Where a space is now: its first terminal's live folder, else where it was
// made (as in the shipped worktree mod).
function place(s) {
  if (!s) return null;
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return panes().find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder || null;
}

// The local space showing a checkout: its first terminal is in it, and not in
// a deeper checkout.
function spaceOf(path, all) {
  return spaces().find((s) => {
    if (s.machine) return false;
    const at = norm(place(s));
    if (!at || !inside(at, path)) return false;
    return !all.some((c) => c.path !== path && c.path.length > path.length && inside(at, c.path));
  });
}

async function wt(args, cwd) {
  const r = await exec(`${home()}/bin/herdr-wt`, args, { cwd }).catch((e) => ({ code: 1, stdout: "", stderr: String(e?.message ?? e) }));
  return { ok: r.code === 0, code: r.code, out: (r.stdout ?? "").trim(), err: (r.stderr || r.stdout || "").trim() };
}

const lastLine = (s) => s.split("\n").filter(Boolean).pop() ?? "";

export default class WtPicker extends View {
  init(_props, cx) {
    this.mode = props()?.mode ?? "pick";
    const f = focused();
    const space = spaces().find((s) => s.id === f?.space);
    this.cwd = f?.cwd || place(space) || home();
    this.filter = "";
    this.list = null; // null while loading
    this.at = 0;
    this.scroll = 0;
    this.busy = ""; // "Creating x…" etc.: list hidden, keys ignored
    this.error = "";
    this.confirm = null; // { c, changes } while asking to remove c
    this.message = "";
    this.all = this.mode === "all";
    this.branch = this.mode === "branch";
    this.scope = "all"; // branch mode, Tab cycles: all -> local -> remote (origin-only)
    this.co = null; // branch mode: the repo's checkouts, to match a new worktree to its space
    this.input = InputState.new({
      placeholder: this.all ? "Switch to a worktree…" : this.branch ? "Check out a branch…" : "Go to or create a worktree…",
    });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; this.scroll = 0; cx.notify(); });
    this.input.on("submit", (_e, cx) => this.enter(cx));
    this.handle = cx.focus_handle();
    // Remove mode has no input: the view itself takes the keys.
    const focus = () => (this.mode === "remove" ? this.handle.focus() : this.input.focus());
    focus();
    cx.timer.after(600, focus);
    cx.spawn(async (cx) => {
      await this.load();
      if (this.mode === "remove" && this.list) {
        const cur = await wt(["current"], this.cwd);
        const c = this.list.find((x) => x.path === cur.out);
        if (!c) this.error = `Not in a worktree: ${this.cwd}`;
        else await this.ask(c);
      }
      cx.notify();
    });
  }

  close() {
    if (this.closed) return;
    this.closed = true;
    closeOverlay(props().overlay);
  }

  // herdr-wt resolves targets against the repo of its cwd: in all mode that's
  // the worktree's own repo, not the focused space's.
  cwdFor(c) {
    return c.mainPath ?? this.cwd;
  }

  async loadAll() {
    const r = await wt(["managed"], home());
    if (!r.ok) {
      this.list = [];
      this.error = lastLine(r.err) || "herdr-wt managed failed";
      return;
    }
    const h = norm(home());
    const cwd = norm(this.cwd);
    this.list = r.out.split("\n").filter(Boolean).map((line) => {
      const [repo, branch, path, mainPath] = line.split("\t");
      return {
        repo,
        branch,
        path,
        mainPath,
        main: false,
        here: inside(cwd, path),
        name: branch || "(detached)",
        displayPath: path.startsWith(`${h}/`) ? `~${path.slice(h.length)}` : path,
        hay: `${repo} ${branch} ${path}`.toLowerCase(),
      };
    });
  }

  // Branches with no worktree (herdr-wt branches), plus the repo's checkouts.
  async loadBranches() {
    const r = await wt(["branches"], this.cwd);
    if (!r.ok) {
      this.list = [];
      this.error = /not in a git repository/.test(r.err) ? `Not in a git repository: ${this.cwd}` : lastLine(r.err) || "herdr-wt branches failed";
      return;
    }
    const c = await wt(["checkouts"], this.cwd);
    this.co = (c.ok ? c.out : "").split("\n").filter(Boolean).map((line) => {
      const [branch, path, main] = line.split("\t");
      return { branch, path, main: main === "1" };
    });
    this.repo = (this.co[0]?.path ?? "").split("/").filter(Boolean).pop() ?? "";
    this.list = r.out.split("\n").filter(Boolean).map((line) => {
      const [branch, kind, date, subject = ""] = line.split("\t");
      return { branch, kind, date, subject, name: branch, hay: `${branch} ${subject}`.toLowerCase() };
    });
  }

  async load() {
    if (this.all) return this.loadAll();
    if (this.branch) return this.loadBranches();
    const r = await wt(["checkouts"], this.cwd);
    if (!r.ok) {
      this.list = [];
      this.error = /not in a git repository/.test(r.err) ? `Not in a git repository: ${this.cwd}` : lastLine(r.err) || "herdr-wt checkouts failed";
      return;
    }
    const h = norm(home());
    const here = (await wt(["current"], this.cwd)).out;
    // The repo's name (its main checkout's folder), shown in the title.
    const mainPath = r.out.split("\n")[0]?.split("\t")[1] ?? "";
    this.repo = mainPath.split("/").filter(Boolean).pop() ?? "";
    this.list = r.out.split("\n").filter(Boolean).map((line) => {
      const [branch, path, main] = line.split("\t");
      return {
        branch,
        path,
        main: main === "1",
        here: path === here,
        name: branch || "(detached)",
        displayPath: path.startsWith(`${h}/`) ? `~${path.slice(h.length)}` : path,
        hay: `${branch} ${path}`.toLowerCase(),
      };
    });
  }

  // Matching checkouts, or a lone "Create <query>" row when nothing matches.
  rows() {
    const q = this.filter.trim();
    const f = q.toLowerCase();
    // Branch scope: "local" = has a local branch (local or both), "remote" = origin only.
    const inScope = (c) => !this.branch || this.scope === "all" || (this.scope === "remote") === (c.kind === "remote");
    const hits = (this.list ?? []).filter((c) => inScope(c) && (!f || c.hay.includes(f)));
    if (this.all || this.branch || !q || this.list === null || hits.length) return hits;
    return [{ create: true, name: q }];
  }

  enter(cx) {
    if (this.busy) return;
    if (this.confirm) return this.remove(cx);
    const sel = this.rows()[this.at];
    if (sel) this.go(sel, cx);
  }

  go(r, cx) {
    // Branch rows have no checkout yet: `herdr-wt create` makes (or finds) one.
    if (r.create || this.branch) return this.create(r.create ? r.name : r.branch, cx);
    this.open(r.path);
  }

  open(path) {
    const s = spaceOf(norm(path), (this.branch ? this.co : this.list) ?? []);
    this.close();
    if (s) run("space.select", { id: s.id });
    // Unnamed, so the space follows the checkout folder and nests under the repo.
    else run("space.new", { folder: path, machine: "" });
  }

  create(name, cx) {
    if (this.all || !name || this.busy) return;
    this.busy = this.branch ? `Checking out ${name}… (checkout, hooks)` : `Creating ${name}… (fetch, checkout, hooks)`;
    this.error = "";
    cx.notify();
    cx.spawn(async (cx) => {
      const r = await wt(["create", name], this.cwd);
      this.busy = "";
      if (!r.ok) {
        this.error = lastLine(r.err) || "Couldn't create the worktree";
        return cx.notify();
      }
      // Re-read the list so a checkout made just now is matched to no space.
      await this.load();
      this.open(lastLine(r.out));
    });
  }

  async ask(c) {
    this.message = "";
    if (c.main) {
      this.error = `${c.displayPath} is the main checkout, not a worktree`;
      return;
    }
    const d = await wt(["dirty", c.path], this.cwdFor(c));
    this.confirm = { c, changes: d.ok ? d.out : "" };
  }

  remove(cx) {
    const { c, changes } = this.confirm;
    this.confirm = null;
    this.busy = `Removing ${c.name}…`;
    cx.notify();
    cx.spawn(async (cx) => {
      const r = await wt(["delete", c.path, ...(changes ? ["-f"] : [])], this.cwdFor(c));
      this.busy = "";
      if (!r.ok) {
        this.error = lastLine(r.err) || "Couldn't remove the worktree";
        return cx.notify();
      }
      // Checkout gone first, then its space (nothing left behind if this fails).
      const s = spaceOf(norm(c.path), this.list ?? []);
      if (s) run("space.close", { id: s.id, confirmed: true });
      const msg = lastLine(r.out) || `Removed ${c.displayPath}`;
      if (this.mode === "remove") {
        notify({ title: "Worktree removed", body: msg, level: "info" });
        return this.close();
      }
      this.message = msg;
      if (!this.all && inside(this.cwd, c.path)) this.cwd = this.list.find((x) => x.main)?.path ?? home();
      await this.load();
      this.at = 0;
      cx.notify();
    });
  }

  render() {
    const t = theme();
    const rows = this.rows();
    const n = rows.length;
    this.at = Math.max(0, Math.min(this.at, n - 1));
    const sel = rows[this.at];
    const removing = this.mode === "remove";

    const colors = shared("space.colors") ?? {};
    const dotColor = (s) => {
      const c = colors[s.id];
      if (!c) return t.accent;
      return c.startsWith("#") ? c : (MARK[c] ?? t[c] ?? t.accent);
    };

    const total = n * ROW;
    const height = Math.min(LIST_MAX, this.listHeight ?? LIST_MAX);
    const fixed = total > height;
    const maxScroll = Math.max(0, total - height);
    this.scroll = Math.max(0, Math.min(this.scroll, maxScroll));
    if (sel) {
      const top = this.at * ROW;
      if (top < this.scroll) this.scroll = top;
      if (top + ROW > this.scroll + height) this.scroll = top + ROW - height;
    }
    const placeAt = (el, i) =>
      fixed ? el.absolute().left(0).right(0).top(i * ROW - this.scroll).bottom(height - ((i + 1) * ROW - this.scroll)) : el;
    const visible = (i) => !fixed || ((i + 1) * ROW > this.scroll && i * ROW < this.scroll + height);

    const tag = (text, color) => div().flex_none().text_size(10.5).text_color(color).child(text);
    const row = (r, i) => {
      const on = i === this.at;
      const base = h_flex()
        .id(`wt-${i}`)
        .mx(4)
        .px(10)
        .h(ROW)
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(on, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.go(r, cx));
      if (r.create)
        return base
          .child(div().w(18).flex_none().text_size(15).text_color(t.accent).child("+"))
          .child(div().flex_shrink(1).min_w(0).truncate().text_color(t.foreground).child(`Create worktree ${r.name}`))
          .child(h_flex().flex_1().justify_end().child(tag("from origin/<default>", t.dim)));
      if (this.branch)
        return base
          .child(div().w(18).flex_none().text_size(13).text_color(t.dim).child("⎇"))
          .child(div().flex_shrink(1).min_w(0).truncate().font_semibold().text_color(t.foreground).child(r.name))
          .when(r.kind === "remote", (el) => el.child(tag("remote", t.ansi3 ?? t.dim)))
          .child(h_flex().flex_1().min_w(0).justify_end().child(div().min_w(0).truncate().text_size(11).text_color(t.dim).child(r.subject)))
          .child(tag(r.date, t.dim));
      const open = spaceOf(norm(r.path), this.list ?? []);
      return base
        .child(div().w(18).flex_none().text_size(13).text_color(t.dim).child(r.main ? "◆" : "⑂"))
        .when(r.repo, (el) => el.child(tag(r.repo, t.dim)))
        .child(div().flex_shrink(1).min_w(0).truncate().font_semibold().text_color(t.foreground).child(r.name))
        .when(open, (el) => el.child(div().size(7).flex_none().rounded(4).bg(dotColor(open))))
        .child(h_flex().flex_1().min_w(0).justify_end().child(div().min_w(0).truncate().text_size(11).text_color(t.dim).child(r.displayPath)))
        .when(r.main, (el) => el.child(tag("main", t.dim)))
        .when(r.here, (el) => el.child(tag("here", t.accent)));
    };

    const line = (msg, color) => div().min_h(ROW).px(14).flex().items_center().text_color(color ?? t.dim).child(msg);

    // Remove confirmation (replaces the list).
    const confirmView = () => {
      const { c, changes } = this.confirm;
      return v_flex()
        .gap(8)
        .px(14)
        .child(div().text_size(14).font_semibold().text_color(t.foreground).child(`Remove worktree ${c.name}?`))
        .child(div().text_size(11).text_color(t.dim).child(c.displayPath))
        .child(div().text_color(t.foreground).child("Closes its space and deletes the folder; the branch goes too if merged."))
        .when(changes, (el) =>
          el
            .child(div().pt(4).font_semibold().text_color(t.ansi1 ?? t.foreground).child("Uncommitted changes (will be lost):"))
            .child(div().font_family(settings().font ?? "Menlo").text_size(11.5).text_color(t.foreground).child(changes.split("\n").slice(0, 12).join("\n"))))
        .child(div().pt(6).text_size(11.5).text_color(t.dim).child(changes ? "Enter discard and remove · Esc cancel" : "Enter remove · Esc cancel"));
    };

    const hints = removing ? "Enter remove · Esc" : this.branch ? `Enter check out · Tab ${this.scope} · Esc` : this.all ? "Enter go · ctrl+d delete · Esc" : "Enter go · ctrl+n create · ctrl+d delete · Esc";
    const title = removing ? "Remove worktree" : this.branch ? "Branches" : this.all ? "All worktrees" : "Worktrees";

    return v_flex()
      .id("wt-picker")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        const ctrl = e.modifiers.control;
        if (k === "escape") {
          if (this.confirm && !removing) {
            this.confirm = null;
            cx.stop_propagation();
            return cx.notify();
          }
          return this.close();
        }
        if (this.busy) return cx.stop_propagation();
        // (Elsewhere Enter reaches the input's submit handler.)
        if (k === "enter" && removing) this.enter(cx);
        else if (this.confirm) return;
        else if ((k === "down" || (k === "j" && ctrl)) && n) this.at = (this.at + 1) % n;
        else if ((k === "up" || (k === "k" && ctrl)) && n) this.at = (this.at + n - 1) % n;
        else if (k === "tab" && this.branch) {
          this.scope = { all: "local", local: "remote", remote: "all" }[this.scope];
          this.at = 0;
          this.scroll = 0;
        } else if (k === "n" && ctrl) { if (!this.branch) this.create(this.filter.trim(), cx); }
        else if (k === "d" && ctrl) {
          // (Branch mode lists branches, not worktrees: nothing to delete.)
          if (!this.branch) {
            this.error = "";
            this.message = "";
            if (!sel || sel.create) this.error = "ctrl+d: highlight a worktree to delete it";
            else cx.spawn(async (cx) => { await this.ask(sel); cx.notify(); });
          }
        } else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex().items_center().gap(8)
          .child(div().flex_none().text_size(15).font_semibold().text_color(t.foreground).child(title))
          .when(this.repo && !this.all, (el) => el.child(div().min_w(0).truncate().text_size(15).text_color(t.dim).child(`(${this.repo})`)))
          .child(div().flex_1())
          .child(div().flex_none().text_size(11).text_color(t.dim).child(hints)),
      )
      .when(!removing, (el) =>
        el.child(
          h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
            .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
            .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
        ))
      .when(this.message && !this.busy && !this.confirm, (el) => el.child(line(this.message, t.accent)))
      .when(this.error && !this.busy, (el) => el.child(line(this.error, t.ansi1 ?? t.foreground)))
      .when(this.busy, (el) => el.child(line(this.busy)))
      .when(this.confirm && !this.busy, (el) => el.child(confirmView()))
      .when(!this.busy && !this.confirm && !removing, (el) =>
        el.child(
          v_flex()
            .id("wt-list")
            .on_size_change((size, cx) => {
              this.listHeight = size.height / settings().zoom;
              cx.notify();
            })
            .h(Math.min(LIST_MAX, Math.max(total, ROW)))
            .min_h(0)
            .mb(6)
            .when(fixed, (el) =>
              el.overflow_hidden().on_scroll_wheel((e, cx) => {
                this.scroll = Math.max(0, Math.min(this.scroll - e.delta.y, maxScroll));
                while (this.at < n - 1 && this.at * ROW < this.scroll) this.at++;
                while (this.at > 0 && (this.at + 1) * ROW > this.scroll + height) this.at--;
                cx.notify();
              }))
            .when(this.list === null, (el) => el.child(line("Loading worktrees…")))
            .when(this.list !== null && n === 0 && !this.error, (el) =>
              el.child(line(this.branch
                ? (this.filter.trim() ? "No matching branch" : this.scope === "all" ? "No branches without a worktree" : `No ${this.scope} branches without a worktree`)
                : this.all ? (this.filter.trim() ? "No matching worktree" : "No worktrees in ~/.herdr/worktrees") : "Type a branch name to create a worktree")))
            .children(rows.map((r, i) => (visible(i) ? placeAt(row(r, i), i) : null)).filter(Boolean)),
        ))
      .when(removing && !this.busy && !this.confirm && !this.error, (el) => el.child(line("Checking…")));
  }
}
