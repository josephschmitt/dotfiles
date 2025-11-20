local EXPLORER_AUTO_CLOSE_WIDTH = 150

-- Helper function to determine if explorer should auto-close based on window width
local function should_auto_close()
  return vim.o.columns <= EXPLORER_AUTO_CLOSE_WIDTH
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- Show hidden files by default
      sources = {
        explorer = {
          ignored = false,
          layout = { preset = "sidebar" },
          auto_close = should_auto_close(),
          include = { "node_modules" },
          win = {
            list = {
              keys = {
                ["S"] = "search_in_directory",
                ["D"] = "diff",
                ["<A-c>"] = "toggle_auto_close",
              },
            },
          },
          actions = {
            explorer_focus = {
              action = function(picker)
                vim.cmd("cd " .. picker:dir())
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
            toggle_auto_close = {
              desc = "toggle_auto_close",
              action = function()
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
        files = {
          hidden = true,
          formatters = {
            file = {
              filename_first = true,
            },
          },
        },
        git_status = {
          win = {
            input = {
              keys = {
                ["<Tab>"] = "select_and_next", -- Allow selecting files in git status window
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
        require("snacks").picker.smart({
          follow = true,
          formatters = {
            file = {
              filename_first = true,
            },
          },
        })
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
    {
      "<leader>e",
      function()
        Snacks.config.picker.sources.explorer.auto_close = should_auto_close()
        Snacks.picker.explorer()
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>E",
      function()
        Snacks.config.picker.sources.explorer.auto_close = should_auto_close()
        Snacks.picker.explorer({ cwd = vim.uv.cwd() })
      end,
      desc = "Explorer Snacks (cwd)",
    },
  },
}
