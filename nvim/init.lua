local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--config",
    "credential.helper=store",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
	
require("lazy").setup({
  "folke/which-key.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
  {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      init = function()
        -- disable rtp plugin, as we only need its queries for mini.ai
        -- In case other textobject modules are enabled, we will load them
        -- once nvim-treesitter is loaded
        require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        load_textobjects = true
      end,
    },
  },
  cmd = { "TSUpdateSync" },
  keys = {
    { "<c-space>", desc = "Increment selection" },
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
  ---@type TSConfig
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
      "cpp",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      ---@type table<string, boolean>
      local added = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if added[lang] then
          return false
        end
        added[lang] = true
        return true
      end, opts.ensure_installed)
    end
    require("nvim-treesitter.configs").setup(opts, {
      autotag = {
          enable = true,
        } 
    })

    if load_textobjects then
      -- PERF: no need to load the plugin, if we only need its queries for mini.ai
      if opts.textobjects then
        for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
          if opts.textobjects[mod] and opts.textobjects[mod].enable then
            local Loader = require("lazy.core.loader")
            Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
            local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
            require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
            break
          end
        end
      end
    end
  end,
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lua/plenary.nvim" },
  { "dense-analysis/ale"},
  { "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
  },
  { "feline-nvim/feline.nvim"},
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { "sbdchd/neoformat"},
  {
  "neoclide/coc.nvim",
  config = function()
    vim.cmd([[autocmd FileType * silent! call CocStart()]])
  end,
  -- Other plugins
  },
  { "norcalli/nvim-colorizer.lua"},
  { "themaxmarchuk/tailwindcss-colors.nvim"},
  { "akinsho/toggleterm.nvim", version = "*"},
  { "ThePrimeagen/vim-be-good"},
  {
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
  },
  { "RRethy/vim-illuminate", },


})

vim.cmd([[colorscheme catppuccin-mocha]])
vim.cmd('set number')
require('feline').setup()
require("catppuccin").setup({
    integrations = {
        nvimtree = true,
        treesitter = true,
	telescope = {
		enabled = true,
	},
	which_key = false,
    }
})
require('colorizer').setup()
require('toggleterm').setup()
local builtin = require('telescope.builtin')

-- Function to run Prettier using CoC command
function Prettier()
  vim.cmd("CocCommand prettier.formatFile")
end

-- Map the command
vim.cmd("command! -nargs=0 Prettier :lua Prettier()")

-- Vim Related configs or keybinds --

-- Set tab width to 2 spaces
vim.o.tabstop = 2 
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Ignore case in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight search results as you type
vim.o.incsearch = true

-- Enable line wrapping
vim.wo.wrap = true

-- Keybinds
vim.g.mapleader = ','
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>q', ':q<CR>', {noremap=true, silent=true})
vim.keymap.set('n', '<leader>tt', ':ToggleTerm size=10 dir= direction=horizontal<CR>', {noremap=true, silent=true})
vim.keymap.set('n', '<leader>ts', ':2ToggleTerm size=10 dir=~ direction=horizontal<CR>', {noremap=true, silent=true})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

