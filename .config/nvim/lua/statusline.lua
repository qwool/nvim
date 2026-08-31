-- hl pattern: %#HLGroup#text%*
local hi_pattern = '%%#%s#%s%%*'

local cmp = {
	mode = function()
		local mode = vim.api.nvim_get_mode().mode
		local modes = {
			n = 'NORMAL',
			i = 'INSERT',
			ic = 'INSERT',
			v = 'VISUAL',
			V = 'V-LINE',
			['\22'] = 'V-BLOCK',
			c = 'COMMAND',
			R = 'REPLACE',
			t = 'TERMINAL',
			nt = 'NORMAL'
		}
		local name = modes[mode] or mode

		local hl = {
			n = 'Bold',
			i = 'StringBold',
			ic = 'StringBold',
			v = 'LabelBold',
			V = 'LabelBold',
			['\22'] = 'LabelBold',
			c = 'FunctionBold',
			R = 'WarningMsgBold',
			nt = 'Removed',
			t = 'RemovedBold'
		}

		return hi_pattern:format(hl[mode] or 'StatusLine', ' ' .. name .. ' ')
	end,


	diagnostic_status = function()
		local ok = ' λ '
		local ignore = { ['c'] = true, ['t'] = true }
		local mode = vim.api.nvim_get_mode().mode
		if ignore[mode] then return ok end

		local levels = vim.diagnostic.severity
		local errors = #vim.diagnostic.get(0, { severity = levels.ERROR })
		local warnings = #vim.diagnostic.get(0, { severity = levels.WARN })

		local result = ''
		if errors > 0 then
			result = result .. hi_pattern:format('DiagnosticError', ' ✘ ' .. errors)
		end
		if warnings > 0 then
			result = result .. hi_pattern:format('DiagnosticWarn', ' ▲ ' .. warnings)
		end
		if result == '' then
			result = ok
		end
		return result
	end,


	position = function()
		return ' %3l:%-2c '
	end,


	filename = function()
		return '%t'
	end,

	setup = function()
		-- set the hl groups
		-- TODO: rerun on every theme change
		vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

		for _, group in ipairs({ "String", "Label", "Function", "WarningMsg", "Removed" }) do
			local ok, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
			if ok then
				vim.api.nvim_set_hl(0, group .. "Bold", { fg = hl.foreground, bg = hl.background or "NONE", bold = true })
			end
		end
		-- build the statusline
		local statusline = {
			' %{%v:lua._statusline_component("mode")%} ',
			'%{%v:lua._statusline_component("diagnostic_status")%} ',
			'%{%v:lua._statusline_component("filename")%} ',
			'%r', '%m',
			'%=',
			'%{&filetype} ',
			'%{%v:lua._statusline_component("position")%}'
		}
		-- to unalias stuff
		function _G._statusline_component(name)
			return _G._statusline_cmp[name]()
		end

		vim.o.statusline = table.concat(statusline, '')
		vim.o.laststatus = 2
	end
}
_G._statusline_cmp = cmp
return cmp
