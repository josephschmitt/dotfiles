return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- Show hidden files by default
      sources = {
        explorer = {
          ignored = true,
          layout = { preset = "sidebar" },
          actions = {
            toggle_preview = {
              action = function(picker)
                local current = picker.layout.preview
                if current then
                  picker:set_layout({ preview = false })
                else
                  picker:set_layout("sidebar")
                end
              end,
            },
            explorer_focus = {
              action = function(picker)
                vim.cmd("cd " .. picker:dir())
              end,
            },
            copy_file_path = {
              action = function(_, item)
                if not item then
                  return
                end

                local vals = {
                  ["BASENAME"] = vim.fn.fnamemodify(item.file, ":t:r"),
                  ["EXTENSION"] = vim.fn.fnamemodify(item.file, ":t:e"),
                  ["FILENAME"] = vim.fn.fnamemodify(item.file, ":t"),
                  ["PATH"] = item.file,
                  ["PATH (CWD)"] = vim.fn.fnamemodify(item.file, ":."),
                  ["PATH (HOME)"] = vim.fn.fnamemodify(item.file, ":~"),
                  ["URI"] = vim.uri_from_fname(item.file),
                }

                local options = vim.tbl_filter(function(val)
                  return vals[val] ~= ""
                end, vim.tbl_keys(vals))
                if vim.tbl_isempty(options) then
                  vim.notify("No values to copy", vim.log.levels.WARN)
                  return
                end
                table.sort(options)
                vim.ui.select(options, {
                  prompt = "Choose to copy to clipboard:",
                  format_item = function(list_item)
                    return ("%s: %s"):format(list_item, vals[list_item])
                  end,
                }, function(choice)
                  local result = vals[choice]
                  if result then
                    vim.fn.setreg("+", result)
                    Snacks.notify.info("Yanked `" .. result .. "`")
                  end
                end)
              end,
            },
            search_in_directory = {
              action = function(_, item)
                if not item then
                  return
                end
                local dir = vim.fn.fnamemodify(item.file, ":p:h")
                Snacks.picker.grep({
                  cwd = dir,
                  cmd = "rg",
                  args = {
                    "-g",
                    "!.git",
                    "-g",
                    "!node_modules",
                    "-g",
                    "!dist",
                    "-g",
                    "!build",
                    "-g",
                    "!coverage",
                    "-g",
                    "!.DS_Store",
                    "-g",
                    "!.docusaurus",
                    "-g",
                    "!.dart_tool",
                  },
                  show_empty = true,
                  hidden = true,
                  ignored = true,
                  follow = false,
                  supports_live = true,
                })
              end,
            },
            diff = {
              action = function(picker)
                picker:close()
                local sel = picker:selected()
                if #sel > 0 and sel then
                  Snacks.notify.info(sel[1].file)
                  vim.cmd("tabnew " .. sel[1].file)
                  vim.cmd("vert diffs " .. sel[2].file)
                  Snacks.notify.info("Diffing " .. sel[1].file .. " against " .. sel[2].file)
                  return
                end

                Snacks.notify.info("Select two entries for the diff")
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["y"] = "copy_file_path",
                ["S"] = "search_in_directory",
                ["D"] = "diff",
                ["<A-c>"] = {
                  desc = "toggle_auto_close",
                  function()
                    local current = Snacks.config.picker.sources.explorer.auto_close
                    Snacks.config.picker.sources.explorer.auto_close = not current

                    -- Refresh the view by closing and reopening the explorer
                    vim.cmd("lua Snacks.picker.explorer()")
                    vim.cmd("lua Snacks.picker.explorer()")

                    local message = "Explorer auto_close: "
                      .. (Snacks.config.picker.sources.explorer.auto_close and "Enabled" or "Disabled")
                    if vim.notify then
                      vim.notify(message, vim.log.levels.INFO, { title = "Snacks Explorer" })
                    else
                      vim.api.nvim_echo({ { message, "None" } }, false, {})
                    end
                  end,
                },
              },
            },
          },
          auto_close = true,
          include = { "node_modules" },
        },
        files = {
          hidden = true,
        },
        git_status = {
          win = {
            input = {
              keys = {
                ["<Tab>"] = "select_and_next",
              },
            },
          },
        },
      },
    },
    terminal = {
      win = {
        style = {
          height = 0.3,
        },
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        require("snacks").picker.files({ follow = true })
      end,
      desc = "Smart Find Files",
    },
    {
      "<leader>;",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
  },
}
