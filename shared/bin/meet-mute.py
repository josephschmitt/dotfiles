#!/usr/bin/env python3

# Raycast Script Command metadata
# @raycast.schemaVersion 1
# @raycast.title Toggle Meet Mute
# @raycast.mode silent
# @raycast.packageName Meetings
# @raycast.description Toggle the mic in the active Google Meet call (in Crest), then match Trace to it.

"""Toggle Google Meet's mic in Crest, then match Trace to Meet's new state.

Each run:
  1. Finds the open Meet call in Crest and clicks its mic button in the
     background (no focus change, works from any app or tab).
  2. Re-reads Meet's mic state after the click.
  3. If Trace is running, sets Trace to that same state using its absolute
     Mute / Unmute Shortcuts actions (not a toggle, so they can't drift).

Because step 3 always copies Meet's actual state, any mismatch (say you
clicked mute inside Meet) is corrected the next time you press the hotkey.

Requirements
  * Crest > Settings > Agents: "Allow agents to use Crest" on, with the Space
    holding your Meet tabs enabled. Approve "Meet Mute" when Crest first asks.
  * Two shortcuts in the Shortcuts app, named as in TRACE_MUTE_SHORTCUT and
    TRACE_UNMUTE_SHORTCUT below, containing Trace's Mute / Unmute actions.

Add --debug to print every tool call and reply.
"""
import json
import re
import subprocess
import sys
import time

# --- configuration ---------------------------------------------------------
CREST_HELPER = "/Applications/Crest.app/Contents/Helpers/crest-browser"
TRACE_PROCESS = "Trace"                    # process name used to detect Trace
TRACE_MUTE_SHORTCUT = "Trace Mute Mic"     # Shortcuts app shortcut names
TRACE_UNMUTE_SHORTCUT = "Trace Unmute Mic"
# ---------------------------------------------------------------------------

DEBUG = "--debug" in sys.argv
MEET_URL = re.compile(r"https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}")
MIC_LABEL = re.compile(r"turn (off|on) microphone", re.I)


def log(*a):
    if DEBUG:
        print(*a, file=sys.stderr, flush=True)


class CrestError(Exception):
    pass


# --- Crest MCP client ------------------------------------------------------
class Crest:
    def __init__(self):
        self.proc = subprocess.Popen(
            [CREST_HELPER, "mcp"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=None if DEBUG else subprocess.DEVNULL,
            text=True, bufsize=1,
        )
        self._id = 0
        self._rpc("initialize", {
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "meet-mute", "version": "3.0"},
        })
        self._rpc("notifications/initialized", notify=True)
        self.tools = {t["name"]: t for t in self._rpc("tools/list")["tools"]}
        log("tools:", json.dumps(
            {n: t.get("inputSchema", {}).get("properties", {}) for n, t in self.tools.items()}))
        self.call("identify", {
            self.param("identify", r"name", "name"): "Meet Mute",
            self.param("identify", r"colou?r", "color"): "#1A73E8",
        })

    def _rpc(self, method, params=None, notify=False):
        msg = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            msg["params"] = params
        if not notify:
            self._id += 1
            msg["id"] = self._id
        try:
            self.proc.stdin.write(json.dumps(msg) + "\n")
            self.proc.stdin.flush()
        except BrokenPipeError:
            raise CrestError("Crest helper exited. Is Crest running with agents enabled?")
        if notify:
            return None
        while True:
            line = self.proc.stdout.readline()
            if not line:
                raise CrestError("Crest helper closed the connection. Is Crest running with agents enabled?")
            resp = json.loads(line)
            if resp.get("id") == self._id:
                if "error" in resp:
                    raise CrestError(f"{method}: {resp['error']}")
                return resp["result"]

    def param(self, tool, pattern, default=None):
        for key in self.tools.get(tool, {}).get("inputSchema", {}).get("properties", {}):
            if re.search(pattern, key, re.I):
                return key
        return default

    def call(self, tool, args=None):
        result = self._rpc("tools/call", {"name": tool, "arguments": args or {}})
        log(f"--- {tool}({args}) ->\n", (text_of(result) or json.dumps(result.get("structuredContent")))[:4000])
        if result.get("isError"):
            raise CrestError(f"{tool} failed: {text_of(result)}")
        return result

    def close(self):
        try:
            self.proc.stdin.close()
            self.proc.wait(timeout=2)
        except Exception:
            self.proc.kill()


def text_of(result):
    return "\n".join(c.get("text", "") for c in result.get("content", []) if c.get("type") == "text")


def as_json(result):
    if result.get("structuredContent") is not None:
        return result["structuredContent"]
    try:
        return json.loads(text_of(result))
    except ValueError:
        return None


def walk(o):
    if isinstance(o, dict):
        yield o
        for v in o.values():
            yield from walk(v)
    elif isinstance(o, list):
        for v in o:
            yield from walk(v)


# --- Meet ------------------------------------------------------------------
def find_meet_tab(crest):
    """Return the tab ID of the open Meet call, or None."""
    for d in walk(as_json(crest.call("list_tabs"))):
        if any(isinstance(v, str) and MEET_URL.search(v) for v in d.values()):
            for k in ("id", "tabId", "tab_id", "uid"):
                if k in d:
                    return d[k]
    return None


def meet_mic(crest, tab_id):
    """Return (muted: bool, button_uid) for the Meet call, or (None, None)."""
    tab_key = crest.param("take_snapshot", r"tab")
    if not tab_key:
        raise CrestError("take_snapshot has no tab parameter; rerun with --debug.")
    snap = crest.call("take_snapshot", {tab_key: tab_id})

    found = None
    for d in walk(as_json(snap)):
        name = next((v for v in d.values() if isinstance(v, str) and MIC_LABEL.search(v)), None)
        if name and "uid" in d:
            found = (name, d["uid"])
            break
    if not found:  # text snapshot, e.g. uid=1_23 button "Turn off microphone (⌘ + d)"
        for line in text_of(snap).splitlines():
            m = re.search(r'uid[=:]\s*"?([\w.\-]+)', line)
            if m and MIC_LABEL.search(line):
                found = (line, m.group(1))
                break
    if not found:
        return None, None
    label, uid = found
    # Meet shows "Turn on microphone" while muted and "Turn off" while live.
    return MIC_LABEL.search(label).group(1).lower() == "on", uid


def click(crest, tab_id, uid):
    crest.call("click", {
        crest.param("click", r"^uid$|element", "uid"): uid,
        crest.param("click", r"tab", "tab"): tab_id,
    })


def read_after_click(crest, tab_id, before):
    """Read Meet's mic state from the UI right after the click.

    Usually the first read already shows the new state. Meet re-renders the
    button asynchronously, though, so if the label hasn't flipped yet, retry
    briefly (up to ~1s) before trusting it.
    """
    for attempt in range(6):
        if attempt:
            time.sleep(0.2)
        muted, _ = meet_mic(crest, tab_id)
        if muted is not None and muted != before:
            return muted
    # Label didn't change: the click may not have landed. Report what Meet says.
    return meet_mic(crest, tab_id)[0]


# --- Trace -----------------------------------------------------------------
def trace_running():
    return subprocess.run(["pgrep", "-xq", TRACE_PROCESS]).returncode == 0


def set_trace(muted):
    """Set Trace's mic to an absolute state. Returns a short status suffix."""
    if not trace_running():
        return ""
    name = TRACE_MUTE_SHORTCUT if muted else TRACE_UNMUTE_SHORTCUT
    r = subprocess.run(["shortcuts", "run", name], capture_output=True, text=True, timeout=10)
    log(f"shortcuts run {name!r} -> rc={r.returncode} {r.stderr.strip()}")
    # Trace's action may fail when nothing is recording; that's fine.
    return " · Trace synced" if r.returncode == 0 else ""


# --- main ------------------------------------------------------------------
def main():
    crest = Crest()
    try:
        tab = find_meet_tab(crest)
        if tab is None:
            return "No Meet call open in Crest"
        before, uid = meet_mic(crest, tab)
        if uid is None:
            return "Couldn't find Meet's mic button"
        click(crest, tab, uid)
        muted = read_after_click(crest, tab, before)
    finally:
        crest.close()

    if muted is None:
        return "Toggled Meet, but couldn't read its new state; Trace unchanged"
    if muted == before:
        return f"Meet didn't change (still {'muted' if muted else 'live'})" + set_trace(muted)
    return ("Muted" if muted else "Live") + set_trace(muted)


if __name__ == "__main__":
    try:
        print(main())  # last line becomes Raycast's HUD
    except CrestError as e:
        print(e)
        sys.exit(1)
