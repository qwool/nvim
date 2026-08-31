-- https://gist.github.com/t-mart/610795fcf7998559ea80
-- https://www.reddit.com/r/neovim/comments/1dc78r4/custom_netrw_workflow_settings_maps_etc/

-- vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 1
vim.g.netrw_liststyle = 1
vim.g.netrw_hide = 1
vim.g.netrw_preview = 1

vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>")
function ToggleNetRW()
	if vim.bo.filetype == "netrw" then
		vim.api.nvim_command("Rex")
		if vim.bo.filetype == "netrw" then
			vim.api.nvim_command("bdel")
		end
	else
		vim.api.nvim_command("Ex")
	end
end

WinBarNetRW = function()
	return table.concat({
		vim.fn.getcwd(),
		"%=",
		" NETRW ",
		"%<",
	})
end
vim.api.nvim_command("command! ToggleNetRW lua ToggleNetRW()")
vim.api.nvim_create_autocmd("filetype", {
	pattern = "netrw",
	desc = "Better mappings for netrw",
	callback = function()
		vim.opt_local.winbar = "%!v:lua.WinBarNetRW()"
		vim.api.nvim_command("setlocal buftype=nofile")
		vim.api.nvim_command("setlocal bufhidden=wipe")

		local bind = function(lhs, rhs)
			vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true })
		end
		local unbind = function(lhs)
			-- idk im just ignorig the error
			pcall(function()
				vim.keymap.del("n", lhs, { buffer = true })
			end)
		end

		bind("n", "%")
		bind("a", "%")
		bind("q", "<cmd>ToggleNetRW<cr>")
		bind("<leader>e", "<cmd>ToggleNetRW<cr>")
		bind("<Esc>", "<cmd>ToggleNetRW<cr>")
		-- bind("r", "R")
		bind("h", "-")
		bind("H", "u")
		bind("l", "<cr>")
		unbind("qL")
		unbind("qF")
		unbind("qf")
		unbind("qb")
	end,
})
