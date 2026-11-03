// Leader key (ctrl+s, like the herdr TUI's prefix): press it, then one key.
//
// TEMPORARY WORKAROUND: Herdr app has no native leader key. If it ever ships
// one, replace this mod with it (see ../../README.md).
//
// keys.json binds "ctrl-s": "mod.open:leader", which opens this mod as a popup
// that takes the keyboard. The next typed character picks an action from ITEMS
// and closes the popup; Esc, ctrl+s again or an unmapped key just closes it.
//
// The same mod also draws the title bar of terminal popups (lazygit, yazi, ...):
// those are a hidden hc terminal shown in an overlay, with this mod as the bar
// (props: { bar: { terminal, title, kill } }).

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, closeOverlay, focused, hc, home, notify, exec, openOverlay, props, run, setShared, shared, spaces, terminals, theme } from "herdr";

// ---- actions -------------------------------------------------------------

const here = () => {
  const f = focused();
  const space = spaces().find((s) => s.id === f?.space);
  return { space: f?.space, cwd: f?.cwd || space?.folder || home(), machine: space?.machine ?? null };
};

// A program in a popup over the window: a hidden hc terminal shown in a modal
// overlay under a title bar. The overlay closes by itself when the program
// exits. `persist`: the terminal outlives the popup (✕ only hides it) and is
// reopened by the same key while it's still alive.
async function popup({ title, cmd, width = 0.8, height = 0.8, persist = false }) {
  const { cwd, machine } = here();
  let terminal = persist ? shared(`leader.${title}`) : null;
  if (terminal && !terminals().some((t) => t.address === terminal && t.state === "live")) terminal = null;
  if (!terminal) {
    const r = await hc([
      "run", "--bg", "--json", "--no-parent", "--no-notify", ...(persist ? [] : ["--rm"]),
      ...(machine ? ["--on", machine] : ["--cwd", cwd]),
      "--", "bash", "-lc", cmd,
    ]);
    if (r.code !== 0) return notify({ title: `${title} failed to start`, body: (r.stderr || r.stdout).trim(), level: "error" });
    terminal = JSON.parse(r.stdout).address;
    if (persist) setShared(`leader.${title}`, terminal);
  }
  // Close the leader right before opening the popup, not after: a popup
  // opened under a still-open leader loses the keyboard to the pane beneath
  // when the leader goes. (Still in the same tick, so the view can open it.)
  closeLeader();
  openOverlay({
    kind: "dialog",
    modal: true,
    width,
    height,
    layout: {
      type: "column",
      children: [
        { type: "block", size: { px: 30 }, content: { mod: "leader", props: { bar: { terminal, title, kill: !persist } } } },
        { type: "block", content: { terminal } },
      ],
    },
  });
  // Make sure the popup's terminal, not the pane beneath, types.
  run("pane.focus", { terminal });
}

// Set by the open leader: closes it (once).
let closeLeader = () => {};

const dialog = (action, size) => {
  const h = here();
  openOverlay({ mod: "worktree", kind: "dialog", ...size, props: { space: h.space, folder: h.cwd, action } });
};

const DIRS = { h: "left", j: "down", k: "up", l: "right" };

// group, keys typed, how they're shown, what they do. Mirrors config.toml's
// [keys] and [[keys.command]] in shared/.config/herdr/ (the TUI).
const ITEMS = [
  { group: "Panes", keys: ["h", "j", "k", "l"], show: "h j k l", label: "Focus pane", act: (k) => run("pane.go", { direction: DIRS[k] }) },
  { group: "Panes", keys: ["\\"], show: "\\", label: "Split down", act: () => run("pane.split", { direction: "down" }) },
  { group: "Panes", keys: ["|"], show: "|", label: "Split right", act: () => run("pane.split", { direction: "right" }) },
  { group: "Panes", keys: ["x"], show: "x", label: "Close pane", act: () => run("pane.close") },
  { group: "Panes", keys: ["z"], show: "z", label: "Zoom pane", act: () => run("pane.zoom") },

  { group: "Tabs", keys: ["n"], show: "n", label: "New tab", act: () => run("tab.new") },
  { group: "Tabs", keys: ["["], show: "[", label: "Previous tab", act: () => run("tab.prev") },
  { group: "Tabs", keys: ["]"], show: "]", label: "Next tab", act: () => run("tab.next") },
  { group: "Tabs", keys: ["T"], show: "T", label: "Rename tab", act: () => run("tab.rename") },
  { group: "Tabs", keys: ["X"], show: "X", label: "Close tab", act: () => run("tab.close") },

  { group: "Spaces", keys: ["N"], show: "N", label: "New space (~/development)", act: () => run("space.new", { folder: `${home()}/development` }) },
  { group: "Spaces", keys: ["o"], show: "o", label: "Go to…", act: () => run("mod.open", { name: "picker" }) },
  { group: "Spaces", keys: ["P"], show: "P", label: "Project picker (pj)", late: true, act: () => popup({ title: "Projects", cmd: `sel=$(pj | fzf --height=100% --reverse --prompt='project> ') && [ -n "$sel" ] && herdr-app do space.new --folder "$sel"`, width: 0.6, height: 0.6 }) },
  { group: "Spaces", keys: ["w"], show: "w", label: "Open worktree", act: () => dialog("open", { width: 560, height: 480 }) },
  { group: "Spaces", keys: ["W"], show: "W", label: "New worktree", act: () => dialog("new", { width: 460, height: 280 }) },
  { group: "Spaces", keys: ["D"], show: "D", label: "Remove worktree", act: () => dialog("remove", { width: 440, height: 260 }) },

  { group: "Agents", keys: "123456789".split(""), show: "1-9", label: "Focus agent", act: (k) => { const a = agents()[Number(k) - 1]; if (a) run("agent.focus", { terminal: a.address }); } },

  { group: "Popups", keys: ["c"], show: "c", label: "Quick shell", late: true, act: () => popup({ title: "Quick shell", cmd: "~/.config/herdr/scripts/quick-shell.sh", width: 0.6, height: 0.6 }) },
  { group: "Popups", keys: ["C"], show: "C", label: "Mini shell (persists)", late: true, act: () => popup({ title: "Mini shell", cmd: "~/.config/herdr/scripts/quick-shell.sh --persist", width: 0.6, height: 0.6, persist: true }) },
  { group: "Popups", keys: ["E"], show: "E", label: "Editor", late: true, act: () => popup({ title: "Editor", cmd: "$EDITOR", width: 0.8, height: 0.8 }) },
  { group: "Popups", keys: ["G"], show: "G", label: "Lazygit", late: true, act: () => popup({ title: "Lazygit", cmd: "lazygit-launch", width: 0.95, height: 0.9 }) },
  { group: "Popups", keys: ["Y"], show: "Y", label: "Yazi", late: true, act: () => popup({ title: "Yazi", cmd: "yazi", width: 0.8, height: 0.8 }) },

  {
    group: "Other", keys: ["g"], show: "g", label: "Open PR in browser", late: true,
    act: async () => {
      const r = await exec("gh", ["pr", "view", "--web"], { cwd: here().cwd }).catch((e) => ({ code: 1, stderr: String(e) }));
      if (r.code !== 0) notify({ title: "No PR for this branch", body: (r.stderr || "").trim().split("\n")[0], level: "warning" });
    },
  },
  { group: "Other", keys: ["b"], show: "b", label: "Toggle sidebar", act: () => run("layout.toggle", { id: "sidebar" }) },
  { group: "Other", keys: ["s"], show: "s", label: "Settings", act: () => run("app.settings") },
  { group: "Other", keys: ["?"], show: "?", label: "Keybinds", act: () => run("app.help") },
];

const COLUMNS = [["Panes", "Tabs"], ["Spaces", "Agents"], ["Popups", "Other"]];

// ---- views ---------------------------------------------------------------

export default class Leader extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    if (!props()?.bar) {
      this.handle.focus();
      cx.timer.after(300, () => this.handle.focus());
    }
  }

  close() {
    closeOverlay(props().overlay);
  }

  key(e, cx) {
    if (e.key === "escape" || e.keystroke === "ctrl-s" || e.keystroke === "ctrl-c") {
      cx.stop_propagation();
      return this.close();
    }
    // Only typed characters count: a bare shift/arrow/etc. isn't a choice.
    const m = e.modifiers;
    if (e.key_char === undefined || m.control || m.platform || m.alt) return;
    cx.stop_propagation();
    const item = ITEMS.find((i) => i.keys.includes(e.key_char));
    // Popups and notifications need this view alive until they've been shown
    // (a closed view's async work can no longer open overlays), so they run
    // first and the leader closes after (popups close it themselves, right
    // before opening, so the keyboard lands in them). Everything else closes
    // first so the focus is back where the action expects it.
    let closed = false;
    closeLeader = () => { if (!closed) { closed = true; this.close(); } };
    if (item?.late) Promise.resolve(item.act(e.key_char)).finally(closeLeader);
    else { closeLeader(); item?.act(e.key_char); }
  }

  bar(t, { terminal, title, kill }) {
    const overlay = props().overlay;
    return h_flex()
      .size_full().px(12).gap(8).items_center()
      .bg(t.surface).border_b(1).border_color(t.border).text_size(12)
      .child(div().truncate().font_semibold().text_color(t.foreground).child(title))
      .child(div().flex_1())
      .child(
        div().id("leader-close").px(8).py(2).rounded(5).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click(() => {
            if (kill) run("terminal.kill", { terminal });
            closeOverlay(overlay);
          })
          .child(kill ? "✕" : "hide"),
      );
  }

  render() {
    const t = theme();
    const bar = props()?.bar;
    if (bar) return this.bar(t, bar);
    const group = (name) =>
      v_flex().gap(2).child(div().pb(2).text_size(11.5).font_medium().text_color(t.dim).child(name))
        .children(
          ITEMS.filter((i) => i.group === name).map((i) =>
            h_flex().h(24).items_center().gap(10)
              .child(div().w(34).flex_none().font_semibold().text_color(t.accent).child(i.show))
              .child(div().truncate().text_color(t.foreground).child(i.label)),
          ),
        );
    return v_flex()
      .id("leader").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .size_full().min_h(0).p(18).gap(14).bg(t.popover).text_size(12)
      .child(
        h_flex().items_center()
          .child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child("Leader"))
          .child(div().text_size(11).text_color(t.dim).child("press a key · Esc to cancel")),
      )
      .child(h_flex().gap(28).items_start().children(COLUMNS.map((names) => v_flex().flex_1().min_w(0).gap(12).children(names.map(group)))));
  }
}
