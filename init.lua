local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
	print("Installing Packer... Restart Neovim after installation!")
	vim.fn.system({"git","clone","--depth","1","https://github.com/wbthomason/packer.nvim",packer_path})
	vim.cmd("packadd packer.nvim")
end
vim.cmd("set cursorline")
vim.opt.number = true
vim.opt.relativenumber = true
--keymaps
vim.api.nvim_set_keymap("c","w!!","w !sudo tee % >/dev/null",{noremap = true,silent = true})
--load packer
require("packer").startup(function(use)
	use "wbthomason/packer.nvim"
	use {"williamboman/mason.nvim"}
	use {"williamboman/mason-lspconfig.nvim"}
	use {"neovim/nvim-lspconfig"}
	use {"hrsh7th/nvim-cmp"}
	use {"hrsh7th/cmp-nvim-lsp"}
	use {"nvim-telescope/telescope.nvim"}
	use {"nvim-treesitter/nvim-treesitter"}
	use {"saadparwaiz1/cmp_luasnip"}
	use {"mhartington/formatter.nvim"}
	use {"nvim-lua/plenary.nvim"}
	use {"RRethy/base16-nvim"}
	use {"windwp/nvim-autopairs"}
	use {"sphamba/smear-cursor.nvim"}
	use {"ray-x/lsp_signature.nvim"}
end)
require('smear_cursor').setup({})
vim.cmd("colorscheme base16-black-metal-gorgoroth")

require('nvim-treesitter.configs').setup{
	ensure_installed = {"glsl"},
	highlight = {
		enable = true,
	},
}

local builtin = require('telescope.builtin')
vim.keymap.set('n','<leader>ff',builtin.find_files,{})
vim.keymap.set('n','<leader>fg',builtin.live_grep,{})
vim.keymap.set('n','<leader>fb',builtin.buffers,{})
vim.keymap.set('n','<leader>fh',builtin.help_tags,{})

require("lsp_signature").setup({
	bind = true,
	floating_window = true,
	hint_enable = true,
})
--mason setup
require("mason").setup()

--mason lsp config
require("mason-lspconfig").setup({
	ensure_installed = {"lua_ls","clangd"},
	automatic_installation = true,
})

--lsp setup
local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
	cmd = {"clangd"},
	on_attach = function (client,bufnr)
		print("Clangd attached")
	end
})
local servers = {"lua_ls","clangd"}
for _, server in ipairs(servers) do
	lspconfig[server].setup({})
end

local cmp = require("cmp")
cmp.setup({
	mapping= {
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({select = true}),
	},
	sources = {
		{name = "nvim_lsp"},
		{name = "luasnip"},
	}
})

require("formatter").setup({
	filetype = {
		c = {require("formatter.filetypes.c").clangformat},
		cpp = {require("formatter.filetypes.cpp").clangformat},
	}
})
vim.cmd([[autocmd BufWritePost * FormatWrite]])

require("nvim-autopairs").setup({
	check_ts = true,
	disable_filetype  = {"TelescopePrompt"},
	fast_wrap = {
		map = '<M-e>',
		chars = { '{','[','(','"',"'"},
		end_key = '$',
		before_key = 'h',
		after_key = 'l',
		cursor_pos = 'right',
		manual_position = true,
		highlight = 'PmenuSel',
		highlight_grey = 'Comment'
	}
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done",cmp_autopairs.on_confirm_done())
