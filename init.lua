-- Ensure Packer is installed
local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    print("Installing Packer... Restart Neovim after installation!")
    vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", packer_path})
    vim.cmd("packadd packer.nvim")
end

-- Basic options
vim.cmd("set cursorline")
vim.opt.number = true
vim.opt.relativenumber = false

-- Keymaps
vim.api.nvim_set_keymap("c", "w!!", "w !sudo tee % >/dev/null", { noremap = true, silent = true })

-- Load Packer
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    print("Packer is not installed! Run :PackerSync after installing it.")
    return
end

-- Plugin setup
packer.startup(function(use)
    use "wbthomason/packer.nvim"
    use { "williamboman/mason.nvim" }
    use { "williamboman/mason-lspconfig.nvim" }
    use { "neovim/nvim-lspconfig" }
    use { "hrsh7th/nvim-cmp" }
    use { "hrsh7th/cmp-nvim-lsp" }
    use { "nvim-telescope/telescope.nvim" }
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use { "saadparwaiz1/cmp_luasnip" }
    use { "mhartington/formatter.nvim" }
    use { "nvim-lua/plenary.nvim" }
    use { "RRethy/base16-nvim" }
    use { "windwp/nvim-autopairs" }
    use { "sphamba/smear-cursor.nvim" }
    use { "ray-x/lsp_signature.nvim" }
    use { "folke/tokyonight.nvim" }
end)

-- Defer colorscheme and custom highlights
vim.schedule(function()
    local ok = pcall(vim.cmd, "colorscheme tokyonight-night")
    if ok then
        -- Dimmed italic comments
        vim.api.nvim_set_hl(0, "Comment", { fg = "#5c5c5c", italic = true })

        -- Darker background tweaks
        vim.api.nvim_set_hl(0, "Normal",       { bg = "#0a0a0a", fg = "#c0c0c0" })
        vim.api.nvim_set_hl(0, "NormalNC",     { bg = "#0a0a0a" })
        vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#111111" })
        vim.api.nvim_set_hl(0, "Visual",       { bg = "#222222" })
        vim.api.nvim_set_hl(0, "Pmenu",        { bg = "#101010", fg = "#c0c0c0" })
        vim.api.nvim_set_hl(0, "FloatBorder",  { bg = "#0a0a0a", fg = "#5c5c5c" })
        vim.api.nvim_set_hl(0, "NormalFloat",  { bg = "#0a0a0a" })
    else
        print("tokyonight-night not found. Run :PackerSync to install it.")
    end
end)

-- Smear Cursor setup
require("smear_cursor").setup({})

-- Treesitter
require("nvim-treesitter.configs").setup({
    ensure_installed = { "glsl", "c" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

-- Telescope keybindings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- LSP Signature Hints
require("lsp_signature").setup({
    bind = true,
    floating_window = true,
    hint_enable = true,
})

-- Mason & LSP config
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "clangd" },
    automatic_installation = true,
})

-- LSP configurations
local lspconfig = require("lspconfig")

lspconfig.clangd.setup({
    cmd = {
        "clangd",
        "--query-driver=C:/msys64/mingw64/bin/gcc.exe",
        "--compile-commands-dir=.",
        "--header-insertion=iwyu",
        "--include-directory=C:/msys64/mingw64/include/",
    },
    on_attach = function()
        print("Clangd attached")
    end,
})

for _, server in ipairs({ "lua_ls", "clangd" }) do
    lspconfig[server].setup({})
end

-- nvim-cmp setup
local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})

-- Formatter
require("formatter").setup({
    filetype = {
        c = { require("formatter.filetypes.c").clangformat },
        cpp = { require("formatter.filetypes.cpp").clangformat },
    }
})
vim.cmd([[autocmd BufWritePost * FormatWrite]])

-- Autopairs
require("nvim-autopairs").setup({
    check_ts = true,
    disable_filetype = { "TelescopePrompt" },
    fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        end_key = "$",
        before_key = "h",
        after_key = "l",
        cursor_pos = "right",
        manual_position = true,
        highlight = "PmenuSel",
        highlight_grey = "Comment",
    },
})

-- Connect cmp to autopairs
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
