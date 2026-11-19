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

require("lze").load({
	{
		"octo.nvim",
		enabled = nixCats("review") or false,
		cmd = "Octo",
		after = function()
			require("octo").setup({ picker = "snacks" })
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
	vim.system(
		{ "git", "fetch", remote, ("pull/%s/head"):format(number) },
		{ text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				notify("git fetch failed: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
				return
			end
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
		vim.cmd(("Octo pr edit %s%s"):format(repo and (repo .. " ") or "", number))
	end)
end

local function search(query)
	load_octo()
	vim.cmd("Octo search " .. query)
end

local function start_review()
	local pr = current_pr()
	if not pr then
		return
	end
	fetch_head(pr.number, function()
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
		run_in_terminal({ "gh", "pr", "checks", tostring(pr.number), "-R", pr.repo })
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
id=$(gh pr checks "$1" -R "$2" --json state,link --jq '[.[] | select(.state == "FAILURE")][0].link // ""' | sed -E 's#.*/runs/([0-9]+).*#\1#')
case "$id" in
  ""|*[!0-9]*) echo "No failing checks on PR $1"; read -r _ ;;
  *) gh run view "$id" -R "$2" --log-failed | less -R ;;
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
	vim.system(
		{ "git", "fetch", remote, ("pull/%s/head:refs/remotes/%s/%s"):format(pr.number, remote, ref) },
		{ text = true, cwd = root },
		vim.schedule_wrap(function(fetched)
			if fetched.code ~= 0 then
				notify("git fetch failed: " .. vim.trim(fetched.stderr or ""), vim.log.levels.ERROR)
				return
			end
			local add = vim.uv.fs_stat(vim.fs.joinpath(root, ".jj"))
					and { "jj", "workspace", "add", dir, "-r", ("%s@%s"):format(ref, remote) }
				or { "git", "worktree", "add", "--detach", dir, ("refs/remotes/%s/%s"):format(remote, ref) }
			vim.system(
				add,
				{ text = true, cwd = root },
				vim.schedule_wrap(function(created)
					if created.code ~= 0 then
						notify("Workspace creation failed: " .. vim.trim(created.stderr or ""), vim.log.levels.ERROR)
						return
					end
					vim.cmd.tcd(dir)
					notify("Checked out PR " .. pr.number .. " in " .. dir)
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
