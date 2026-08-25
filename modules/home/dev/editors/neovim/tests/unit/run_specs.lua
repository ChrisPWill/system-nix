-- Runs every specs/*_spec.lua file and fails (non-zero exit, so
-- `nvim --headless -n -l run_specs.lua` reports failure to the Nix
-- check invoking it) if any spec errors. Specs are plain scripts that
-- error() on assertion failure — this runner's job is just to make sure
-- one spec's failure doesn't stop the others from running, and to give
-- a single pass/fail summary instead of an opaque crash.

-- Specs that exercise insert-mode features (argument_insert) otherwise
-- echo "-- INSERT --"/"-- (insert) --" mode messages into this output.
vim.o.showmode = false

local source = debug.getinfo(1, "S").source:sub(2)
local unit_dir = vim.fs.dirname(source)
local specs_dir = unit_dir .. "/specs"
local config_root = vim.fs.dirname(vim.fs.dirname(unit_dir)) .. "/config/lua"
package.path = unit_dir .. "/?.lua;" .. config_root .. "/?.lua;" .. config_root .. "/?/init.lua;" .. package.path

local specs = {}
for name, kind in vim.fs.dir(specs_dir) do
	if kind == "file" and name:match("_spec%.lua$") then
		table.insert(specs, name)
	end
end
table.sort(specs)

if #specs == 0 then
	print("No *_spec.lua files found in " .. specs_dir)
	os.exit(1)
end

local failures = {}
for _, name in ipairs(specs) do
	local ok, err = pcall(dofile, specs_dir .. "/" .. name)
	if ok then
		print("PASS " .. name)
	else
		print("FAIL " .. name .. ": " .. tostring(err))
		table.insert(failures, name)
	end
end

print(string.format("%d/%d specs passed", #specs - #failures, #specs))
if #failures > 0 then
	os.exit(1)
end
