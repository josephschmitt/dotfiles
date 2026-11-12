-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config
-- Muscle memory carried over from tmux/Herdr: alt+hjkl, alt+1..9, and a ctrl+s
-- prefix. See README.md for the full key table. Reload with `rex config reload`
-- (Rex doesn't watch this file), check with `rex config check` / `rex keymap`.
--
-- `require` resolves siblings of this file.
require("actions") -- Lua actions: new session, PR, session by index, selecting from scripts
require("popups")  -- floating popups: shells, editor, lazygit, yazi, pickers
require("keys")    -- every rex.bind
