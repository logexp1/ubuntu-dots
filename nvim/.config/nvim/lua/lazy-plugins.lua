-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.

local function load_kickstart_plugins()
	local plugins = {}
	local plugin_path = vim.fn.stdpath("config") .. "/lua/kickstart/plugins"

	-- Check if directory exists
	if vim.fn.isdirectory(plugin_path) == 1 then
		local all_files = vim.fn.readdir(plugin_path)

		local files = {}
		for _, file in ipairs(all_files) do
			if file:match("%.lua$") then
				table.insert(files, file)
			end
		end

		for _, file in ipairs(files) do
			local plugin_name = file:gsub("%.lua$", "")

			local success, plugin = pcall(require, "kickstart.plugins." .. plugin_name)
			if success then
				table.insert(plugins, plugin)
			else
				print("Failed to load " .. plugin_name .. ": " .. plugin)
			end
		end
	end

	return plugins
end
-- Function to automatically load all plugins from kickstart.plugins directory

-- Build the plugin spec
local plugin_spec = {
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically

	-- Automatically load all plugins from kickstart/plugins/
	unpack(load_kickstart_plugins()),
}

require("lazy").setup(plugin_spec, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
