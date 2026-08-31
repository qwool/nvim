vim.opt_local.commentstring = "# %s"
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true

vim.b.match_words = "\\<do\\>:\\<end\\>,{:}"

local function show_revo_output(stdout, stderr, exit_code)
  local output = {}
  local stderr_start

  for _, line in ipairs(stdout) do
    if line ~= "" then
      table.insert(output, line)
    end
  end

  if #stderr > 0 then
    stderr_start = #output + 1

    for _, line in ipairs(stderr) do
      if line ~= "" then
        table.insert(output, line)
      end
    end
  end

  if #output == 0 then
    output = { "No output" }
  end

  table.insert(output, "")

  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "revo-output"

  local width = 1

  for _, line in ipairs(output) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  width = math.min(width + 2, math.floor(vim.o.columns * 0.8))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = math.min(#output, 12),
    style = "minimal",
    border = "rounded",
    title = exit_code == 0 and " revo " or " revo error ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_cursor(win, { #output, 0 })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false

  if stderr_start then
    vim.api.nvim_buf_add_highlight(
      buf,
      -1,
      "DiagnosticError",
      stderr_start - 1,
      0,
      -1
    )
  end

  local close_window = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close_window, {
    buffer = buf,
    silent = true,
    nowait = true,
  })

  vim.keymap.set("n", "<Esc>", close_window, {
    buffer = buf,
    silent = true,
    nowait = true,
  })
end

vim.keymap.set({ "n", "x" }, "<leader>r", function()
  local mode = vim.fn.mode()
  local lines

  if mode == "v" or mode == "V" or mode == "\22" then
    local start_row = vim.fn.line("'<")
    local end_row = vim.fn.line("'>")

    lines = vim.api.nvim_buf_get_lines(
      0,
      start_row - 1,
      end_row,
      false
    )
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  local source = table.concat(lines, "\n")
  local stdout = {}
  local stderr = {}

  local job_id = vim.fn.jobstart({ "revo", "-D" }, {
    stdin = "pipe",
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout, line)
          end
        end
      end
    end,

    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr, line)
          end
        end
      end
    end,

    on_exit = function(_, exit_code)
      vim.schedule(function()
        show_revo_output(stdout, stderr, exit_code)
      end)
    end,
  })

  if job_id <= 0 then
    show_revo_output({}, { "Failed to start revo" }, 1)
    return
  end

  vim.fn.chansend(job_id, source)
  vim.fn.chanclose(job_id, "stdin")
end, {
  buffer = true,
  silent = true,
  desc = "Evaluate Revo code",
})

vim.treesitter.start(0, "revo")
