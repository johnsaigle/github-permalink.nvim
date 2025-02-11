local M = {}

-- Cache for storing git information
local cache = {
	root = nil,
	remote_url = nil,
	commit_hash = nil
}

-- Helper function to run git commands
local function git_command(cmd)
	local handle = io.popen(cmd)
	if not handle then return nil end

	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "") -- Trim whitespace
end

-- Get git repository root
local function get_git_root()
	if cache.root then return cache.root end

	local root = git_command("git rev-parse --show-toplevel")
	if root then
		cache.root = root
		return root
	end
	return nil
end

-- Get current commit hash
local function get_commit_hash()
	if cache.commit_hash then return cache.commit_hash end

	local hash = git_command("git rev-parse HEAD")
	if hash then
		cache.commit_hash = hash
		return hash
	end
	return nil
end

-- Extract GitHub organization and repository from remote URL
local function get_github_info()
	if cache.remote_url then return cache.remote_url end

	local remote_url = git_command("git config --get remote.origin.url")
	if not remote_url then return nil end

	-- Handle different Git URL formats
	local org, repo
	if remote_url:match("^https://") then
		org, repo = remote_url:match("github.com/([^/]+)/([^/]+)%.git$")
	else
		org, repo = remote_url:match("git@github%.com:([^/]+)/([^/]+)%.git$")
	end

	if org and repo then
		cache.remote_url = { org = org, repo = repo }
		return cache.remote_url
	end
	return nil
end

-- Generate GitHub permalink
function M.generate_permalink()
	local root = get_git_root()
	local github_info = get_github_info()
	local commit_hash = get_commit_hash()

	if not (root and github_info and commit_hash) then
		vim.notify("Unable to generate GitHub permalink. Make sure you're in a Git repository.",
			vim.log.levels.ERROR)
		return
	end

	-- Get current buffer's file path relative to git root
	local current_file = vim.fn.expand('%:p')
	local relative_path = current_file:sub(#root + 2) -- +2 to account for trailing slash

	-- Get visual selection line numbers
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Construct the GitHub URL, beginning with just the first line
	local url = string.format(
		"https://github.com/%s/%s/blob/%s/%s#L%d",
		github_info.org,
		github_info.repo,
		commit_hash,
		relative_path,
		start_line
	)

	-- Add the end_line if more than one line is selected.
	if not start_line == end_line then
		url = string.format("url-L%d", end_line)
	end

	-- Copy to system clipboard
	vim.fn.setreg('+', url)
	vim.notify("Permalink: " .. url, vim.log.levels.INFO)
end

-- Setup function to be called when loading the plugin
function M.setup(opts)
	-- Create user command
	vim.api.nvim_create_user_command('GitHubPermalink', function()
		M.generate_permalink()
	end, {
		range = true,
		desc = 'Generate GitHub permalink for selected lines'
	})

	-- Optional: Add keymapping
	if opts and opts.mapping then
		vim.keymap.set('v', opts.mapping, ':GitHubPermalink<CR>', {
			silent = true,
			desc = 'Generate GitHub permalink for selected lines'
		})
	end
end

return M

