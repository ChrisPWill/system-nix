local d = vim.diagnostic
local severity_order = {
	d.severity.ERROR,
	d.severity.WARN,
	d.severity.INFO,
	d.severity.HINT,
}

local function get_highest_severity(count)
	count = count or d.count()

	for _, s in ipairs(severity_order) do
		if count[s] and count[s] > 0 then
			return s
		end
	end

	return nil
end

local M = { order = severity_order, get_highest_severity = get_highest_severity }

function M.jump_next()
	local severity = get_highest_severity()
	d.jump({ count = vim.v.count1, severity = severity })
end

function M.jump_prev()
	local severity = get_highest_severity()
	d.jump({ count = -vim.v.count1, severity = severity })
end

function M.jump_all_next()
	d.jump({ count = vim.v.count1 })
end

function M.jump_all_prev()
	d.jump({ count = -vim.v.count1 })
end

return M
