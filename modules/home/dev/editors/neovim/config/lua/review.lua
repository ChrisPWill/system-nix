-- PR review commands, loaded only by the `review` build (nixcats-package.nix).
-- Octo does the reviewing; these wrappers cover what it leaves to the user:
-- getting the PR's commits locally, choosing a verdict, reading CI logs and
-- starting a checkout that does not disturb the working copy.
local utils = require("utils")

-- Octo reads file contents with `git show <sha>:<path>`, so a PR's head commit
-- must exist locally before its review can open.
local remote = "origin"

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "PR review" })
end

-- Octo's virtual buffers (octo://..., and <cwd>/octo/null) would each get a swap
-- file in one shared directory, named after the buffer. Two sessions reviewing
-- from the same repo then collide with "swap file exists", and a session that
-- exits uncleanly leaves stale ones behind. Reviews don't edit files, so there
-- is nothing for a swap file to recover.
vim.o.swapfile = false

local progress_count = 0

-- A notification that is replaced in place: slow steps read as "working", then
-- as done or failed, instead of as silence. Returns finish(message?, level?);
-- calling it with no message just closes the notification.
local function progress(title)
	progress_count = progress_count + 1
	local id = "pr-review-" .. progress_count
	local finished = false
	local function show(message, level, timeout)
		Snacks.notifier.notify(
			message,
			level or vim.log.levels.INFO,
			{ id = id, title = "PR review", timeout = timeout }
		)
	end
	show(title .. "…", vim.log.levels.INFO, 0)
	return function(message, level)
		if finished then
			return
		end
		finished = true
		if message then
			show(message, level, 3000)
		else
			Snacks.notifier.hide(id)
		end
	end
end

-- Octo loads asynchronously and reports nothing, so close the notification when
-- the expected UI appears, or after a while if it never does (e.g. on error).
local function finish_when(finish, event, pattern)
	local autocmd = vim.api.nvim_create_autocmd(event, {
		pattern = pattern,
		once = true,
		callback = function()
			finish()
		end,
	})
	vim.defer_fn(function()
		pcall(vim.api.nvim_del_autocmd, autocmd)
		finish()
	end, 15000)
end

require("lze").load({
	{
		"octo.nvim",
		enabled = nixCats("review") or false,
		cmd = "Octo",
		after = function()
			-- Octo defaults to nvim-web-devicons, which this config does not
			-- install; mini.icons already provides the same icons.
			require("lze").trigger_load("mini.nvim")
			local icons = require("mini.icons")
			icons.setup()
			require("octo").setup({
				picker = "snacks",
				file_panel = {
					icons = function(name)
						local icon, hl = icons.get("file", name)
						return icon, hl
					end,
				},
			})
		end,
	},
})

local function load_octo()
	require("lze").trigger_load("octo.nvim")
end

-- The PR in the current Octo buffer, or else the one under review (diff
-- windows are not Octo buffers).
local function current_pr()
	load_octo()
	local buffer = require("octo.utils").get_current_buffer()
	if buffer and buffer:isPullRequest() then
		return { number = buffer.number, repo = buffer.repo, in_buffer = true }
	end
	local review = require("octo.reviews").get_current_review()
	if review then
		return { number = review.pull_request.number, repo = review.pull_request.repo }
	end
	notify("Open a PR first (:PR <number>)", vim.log.levels.WARN)
end

local function pr_url(pr)
	return ("https://github.com/%s/pull/%s"):format(pr.repo, pr.number)
end

local function fetch_head(number, on_done)
	local finish = progress(("Fetching PR %s"):format(number))
	vim.system(
		{ "git", "fetch", remote, ("pull/%s/head"):format(number) },
		{ text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				local url = vim.trim(vim.fn.system({ "git", "remote", "get-url", remote }))
				local message = result.stderr:find("couldn't find remote ref", 1, true)
						and ("PR %s not found on %s (%s). Run this from a clone of the PR's repo."):format(
							number,
							remote,
							url
						)
					or ("git fetch failed: " .. vim.trim(result.stderr or ""))
				finish(message, vim.log.levels.ERROR)
				return
			end
			finish()
			on_done()
		end)
	)
end

-- `new` opens an empty buffer; a plain split copies the current one, and a
-- terminal cannot start in a modified or Octo-owned buffer.
local function run_in_terminal(cmd, split)
	vim.cmd(split or "botright 20new")
	vim.fn.jobstart(cmd, { term = true })
	vim.cmd.startinsert()
end

-- Accepts "123" or a GitHub PR URL. The repo is nil for a bare number, meaning
-- "the repo in the current directory".
local function parse_pr(arg)
	if arg:match("^%d+$") then
		return nil, tonumber(arg)
	end
	load_octo()
	local _, repo, number, kind = require("octo.utils").parse_url(arg)
	if kind == "pull" then
		return repo, tonumber(number)
	end
end

local function open_pr(arg)
	if arg == "" then
		load_octo()
		picker_opened(progress("Loading PRs"))
		vim.cmd("Octo pr list")
		return
	end
	local repo, number = parse_pr(arg)
	if not number then
		notify("Expected a PR number or URL, got: " .. arg, vim.log.levels.ERROR)
		return
	end
	fetch_head(number, function()
		load_octo()
		finish_when(progress(("Opening PR %s"):format(number)), "BufEnter", "octo://*")
		vim.cmd(("Octo pr edit %s%s"):format(repo and (repo .. " ") or "", number))
	end)
end

local function picker_opened(finish)
	finish_when(finish, "FileType", "snacks_picker*")
end

local function search(query)
	load_octo()
	picker_opened(progress("Searching PRs"))
	vim.cmd("Octo search " .. query)
end

local function start_review()
	local pr = current_pr()
	if not pr then
		return
	end
	fetch_head(pr.number, function()
		finish_when(progress(("Starting review of PR %s"):format(pr.number)), "BufEnter", "*OctoChangedFiles*")
		require("octo.reviews").start_or_resume_review()
	end)
end

-- Octo's submit window waits for a verdict key. Preselecting the verdict lets
-- the body be written first and sent with <CR>.
local function submit_as(event, label)
	load_octo()
	local review = require("octo.reviews").get_current_review()
	if not review or review.id == -1 then
		notify("Start or resume a review first (:PRReview)", vim.log.levels.WARN)
		return
	end
	review:collect_submit_info()
	vim.keymap.set("n", "<CR>", function()
		review:submit(event)
	end, { buffer = 0, desc = "Submit review as " .. label })
	pcall(
		vim.api.nvim_win_set_config,
		0,
		{ title = (" %s: write a body, <CR> to send "):format(label), title_pos = "center" }
	)
end

local function checks()
	local pr = current_pr()
	if not pr then
		return
	end
	if pr.in_buffer then
		vim.cmd("Octo pr checks")
	else
		run_in_terminal({
			"bash",
			"-c",
			'echo "Fetching checks…"; gh pr checks "$1" -R "$2"',
			"_",
			tostring(pr.number),
			pr.repo,
		})
	end
end

-- Shows the log of the first failing job's run, which is where CI failures are
-- actually explained.
local function failing_logs()
	local pr = current_pr()
	if not pr then
		return
	end
	local script = [[
echo "Finding the failing job…"
id=$(gh pr checks "$1" -R "$2" --json state,link --jq '[.[] | select(.state == "FAILURE")][0].link // ""' | sed -E 's#.*/runs/([0-9]+).*#\1#')
case "$id" in
  ""|*[!0-9]*) echo "No failing checks on PR $1"; read -r _ ;;
  *) echo "Fetching log of run $id…"; gh run view "$id" -R "$2" --log-failed | less -R ;;
esac
]]
	run_in_terminal({ "bash", "-c", script, "_", tostring(pr.number), pr.repo })
end

-- A separate workspace keeps the working copy untouched, unlike
-- `gh pr checkout`, which moves it onto the PR's branch.
local function checkout()
	local pr = current_pr()
	if not pr then
		return
	end
	local root = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-toplevel" }))
	if vim.v.shell_error ~= 0 then
		notify("Not inside a git repository", vim.log.levels.ERROR)
		return
	end
	local dir = vim.fs.joinpath(vim.fs.dirname(root), ("%s-pr-%s"):format(vim.fs.basename(root), pr.number))
	if vim.uv.fs_stat(dir) then
		vim.cmd.tcd(dir)
		notify("Workspace already exists, switched to " .. dir)
		return
	end

	local ref = ("pr-%s"):format(pr.number)
	local finish = progress(("Fetching PR %s"):format(pr.number))
	local function fail(prefix, result)
		finish(prefix .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
	end
	vim.system(
		{ "git", "fetch", remote, ("pull/%s/head:refs/remotes/%s/%s"):format(pr.number, remote, ref) },
		{ text = true, cwd = root },
		vim.schedule_wrap(function(fetched)
			if fetched.code ~= 0 then
				fail("git fetch failed: ", fetched)
				return
			end
			finish()
			finish = progress("Creating workspace")
			local add = vim.uv.fs_stat(vim.fs.joinpath(root, ".jj"))
					and { "jj", "workspace", "add", dir, "-r", ("%s@%s"):format(ref, remote) }
				or { "git", "worktree", "add", "--detach", dir, ("refs/remotes/%s/%s"):format(remote, ref) }
			vim.system(
				add,
				{ text = true, cwd = root },
				vim.schedule_wrap(function(created)
					if created.code ~= 0 then
						fail("Workspace creation failed: ", created)
						return
					end
					vim.cmd.tcd(dir)
					finish(("Checked out PR %s in %s"):format(pr.number, dir))
				end)
			)
		end)
	)
end

local function copy_url()
	local pr = current_pr()
	if not pr then
		return
	end
	local url = pr_url(pr)
	vim.fn.setreg("+", url)
	notify("Copied " .. url)
end

-- The skill lives in the user's agent config, so this only works where the
-- claude CLI is installed.
local function guide()
	local pr = current_pr()
	if not pr then
		return
	end
	if vim.fn.executable("claude") == 0 then
		notify("claude CLI not found on PATH", vim.log.levels.ERROR)
		return
	end
	run_in_terminal({ "claude", "/pr-review-guide " .. pr_url(pr) }, "botright vnew")
end

local commands = {
	PR = { open_pr, { nargs = "?", desc = "Open a PR by number or URL (no argument: list PRs)" } },
	PRInbox = {
		function()
			search("is:pr is:open review-requested:@me")
		end,
		{ desc = "PRs waiting on your review" },
	},
	PRMine = {
		function()
			search("is:pr is:open author:@me")
		end,
		{ desc = "Your open PRs" },
	},
	PRReview = { start_review, { desc = "Start or resume a review of the open PR" } },
	PRApprove = {
		function()
			submit_as("APPROVE", "Approve")
		end,
		{ desc = "Submit the review as an approval" },
	},
	PRRequestChanges = {
		function()
			submit_as("REQUEST_CHANGES", "Request changes")
		end,
		{ desc = "Submit the review requesting changes" },
	},
	PRChecks = { checks, { desc = "CI check status" } },
	PRLogs = { failing_logs, { desc = "Log of the first failing CI job" } },
	PRCheckout = { checkout, { desc = "Check the PR out into a separate workspace" } },
	PRUrl = { copy_url, { desc = "Copy the PR URL" } },
	PRGuide = { guide, { desc = "Run the pr-review-guide skill on the PR" } },
}

for name, spec in pairs(commands) do
	vim.api.nvim_create_user_command(name, function(opts)
		spec[1](opts.args)
	end, spec[2])
end

local maps = {
	{ "i", "PRInbox", "PR inbox" },
	{ "m", "PRMine", "My PRs" },
	{ "r", "PRReview", "Start or resume review" },
	{ "a", "PRApprove", "Approve" },
	{ "x", "PRRequestChanges", "Request changes" },
	{ "c", "PRChecks", "CI checks" },
	{ "l", "PRLogs", "Failing CI log" },
	{ "w", "PRCheckout", "Checkout into workspace" },
	{ "u", "PRUrl", "Copy PR URL" },
	{ "g", "PRGuide", "Review guide (agent)" },
}
for _, map in ipairs(maps) do
	utils.nmap("<leader>R" .. map[1], "<cmd>" .. map[2] .. "<CR>", map[3])
end
