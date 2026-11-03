// Project picker: lists `pj` projects in the same look as the native "Go to…"
// window (mods/picker has no source API, so this is a sibling mod).
//
// Type to filter, ↑/↓ and Enter to go, ctrl+n to always make a new space, Esc
// to leave. Enter focuses the project's open space (same folder, this
// computer), else creates one. Opened by leader `P` (mods/leader).

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { spaces, run, exec, theme, settings, props, closeOverlay, notify, home, shared } from "herdr";

const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };
const ROW = 32;
const LIST_MAX = 320;

const norm = (p) => (p ?? "").replace(/\/+$/, "");

// pj's color names ("blue", "bright-red") -> the theme's ansi0..15, so icons follow the theme.
const ANSI = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"];
function iconColor(t, name) {
  if (!name) return t.dim;
  if (name.startsWith("#")) return name;
  const bright = name.startsWith("bright-");
  const i = ANSI.indexOf(bright ? name.slice(7) : name);
  return i < 0 ? t.dim : (t[`ansi${i + (bright ? 8 : 0)}`] ?? t.dim);
}

export default class PjPicker extends View {
  init(_props, cx) {
    this.filter = "";
    this.projects = null; // null while loading
    this.at = 0;
    this.scroll = 0;
    this.input = InputState.new({ placeholder: "Go to a project…" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; this.scroll = 0; cx.notify(); });
    this.input.on("submit", () => this.go(this.rows()[this.at], false));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      try {
        // One line per project, tab-separated. --icons makes %i a Nerd Font glyph
        // (pj's own mapping, so ~/.config/pj/config.yaml icon/color overrides apply).
        const r = await exec("pj", ["--icons", "--format", "%P\t%n\t%l\t%i\t%c", "--sort", "alpha"]);
        if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim() || `pj exited ${r.code}`);
        const h = norm(home());
        this.projects = r.stdout
          .split("\n")
          .filter(Boolean)
          .map((line) => {
            const [path, name, markerLabel, icon, color] = line.split("\t");
            return {
              path,
              name,
              markerLabel,
              icon,
              color,
              displayPath: path.startsWith(`${h}/`) ? `~${path.slice(h.length)}` : path,
              hay: `${name} ${path} ${markerLabel ?? ""}`.toLowerCase(),
            };
          });
      } catch (e) {
        notify({ title: "pj failed", body: String(e?.message ?? e).split("\n")[0], level: "error" });
        this.close();
        return;
      }
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  rows() {
    const f = this.filter.toLowerCase();
    return (this.projects ?? []).filter((p) => !f || p.hay.includes(f));
  }

  go(r, forceNew) {
    if (!r) return;
    const open = this.openSpace(r);
    this.close();
    if (open && !forceNew) run("space.select", { id: open.id });
    else run("space.new", { folder: r.path, name: r.name, machine: "" });
  }

  openSpace(p) {
    const want = norm(p.path);
    return spaces().find((s) => !s.machine && norm(s.folder) === want);
  }

  render() {
    const t = theme();
    const rows = this.rows();
    const n = rows.length;
    this.at = Math.max(0, Math.min(this.at, n - 1));
    const sel = rows[this.at];

    // Spaces by folder, for the "already open" dot (colors are read-only here:
    // the shipped picker owns assigning them).
    // Icons are Nerd Font glyphs: draw them in the terminal font, which has them.
    const iconFont = settings().font ?? "Monaco Nerd Font Mono";
    const colors = shared("space.colors") ?? {};
    const openBy = new Map();
    for (const s of spaces()) if (!s.machine) openBy.set(norm(s.folder), s);
    const dotColor = (s) => {
      const c = colors[s.id];
      if (!c) return t.accent;
      return c.startsWith("#") ? c : (MARK[c] ?? t[c] ?? t.accent);
    };

    // Fixed-height rows in one strip; scrolling moves it only as far as keeps
    // the selected row in view.
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
    const place = (el, i) =>
      fixed ? el.absolute().left(0).right(0).top(i * ROW - this.scroll).bottom(height - ((i + 1) * ROW - this.scroll)) : el;
    const visible = (i) => !fixed || ((i + 1) * ROW > this.scroll && i * ROW < this.scroll + height);

    const row = (r, i) => {
      const on = i === this.at;
      const open = openBy.get(norm(r.path));
      return h_flex()
        .id(`pj-${i}`)
        .mx(4)
        .px(10)
        .h(ROW)
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(on, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.go(r, false))
        .child(div().w(18).flex_none().font_family(iconFont).text_size(15).text_color(iconColor(t, r.color)).child(r.icon ?? ""))
        .child(div().flex_shrink(1).min_w(0).truncate().font_semibold().text_color(t.foreground).child(r.name))
        // Open space: a dot in its color right after the name (no reserved slot on other rows).
        .when(open, (el) => el.child(div().size(7).flex_none().rounded(4).bg(dotColor(open))))
        .child(h_flex().flex_1().min_w(0).justify_end().child(div().min_w(0).truncate().text_size(11).text_color(t.dim).child(r.displayPath)))
        .when(r.markerLabel, (el) => el.child(div().flex_none().text_size(10.5).text_color(t.dim).child(r.markerLabel)));
    };

    const empty = (msg) => div().h(ROW).px(14).flex().items_center().text_color(t.dim).child(msg);

    return v_flex()
      .id("pj-picker")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return this.close();
        const ctrl = e.modifiers.control;
        if ((k === "down" || (k === "j" && ctrl)) && n) this.at = (this.at + 1) % n;
        else if ((k === "up" || (k === "k" && ctrl)) && n) this.at = (this.at + n - 1) % n;
        else if (k === "n" && e.modifiers.control) this.go(sel, true);
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child("Projects")).child(div().text_size(11).text_color(t.dim).child("Enter go · ctrl+n new space · Esc")))
      .child(
        h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
          .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(
        v_flex()
          .id("pj-list")
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
              // The selection follows the wheel, so the next frame doesn't scroll back to it.
              while (this.at < n - 1 && this.at * ROW < this.scroll) this.at++;
              while (this.at > 0 && (this.at + 1) * ROW > this.scroll + height) this.at--;
              cx.notify();
            }))
          .when(this.projects === null, (el) => el.child(empty("Loading projects…")))
          .when(this.projects !== null && n === 0, (el) => el.child(empty("No matching projects")))
          .children(rows.map((r, i) => (visible(i) ? place(row(r, i), i) : null)).filter(Boolean)),
      );
  }
}
