-- init.lua

-- Ensure Packer is installed
local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    print("Installing Packer... Restart Neovim after installation!")
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", packer_path })
    vim.cmd("packadd packer.nvim")
end

-- Basic options
vim.cmd("set cursorline")
vim.opt.number = true
vim.opt.relativenumber = false

-- Keymaps
vim.api.nvim_set_keymap("c", "w!!", "w !sudo tee % >/dev/null", { noremap = true, silent = true })

-- Plugin setup
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    print("Packer is not installed! Run :PackerSync after installing it.")
    return
end

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
    use { "jose-elias-alvarez/null-ls.nvim" }

end)

-- Colorscheme and highlights
vim.schedule(function()
    local ok = pcall(vim.cmd, "colorscheme tokyonight-night")
    if ok then
        vim.api.nvim_set_hl(0, "Comment", { fg = "#5c5c5c", italic = true })
        vim.api.nvim_set_hl(0, "Normal", { bg = "#0a0a0a", fg = "#c0c0c0" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "#0a0a0a" })
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "#111111" })
        vim.api.nvim_set_hl(0, "Visual", { bg = "#222222" })
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "#101010", fg = "#c0c0c0" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#0a0a0a", fg = "#5c5c5c" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#0a0a0a" })
    else
        print("tokyonight-night not found. Run :PackerSync to install it.")
    end
end)

-- Smear Cursor
require("smear_cursor").setup({})

-- Treesitter
require("nvim-treesitter.configs").setup({
    ensure_installed = { "glsl", "c", "cpp", "c_sharp" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- LSP Signature
require("lsp_signature").setup({
    bind = true,
    floating_window = true,
    hint_enable = true,
})

-- Mason & LSP config
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "clangd"},
    automatic_installation = true,
})

-- Common LSP setup
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end



-- clangd for C/C++
lspconfig.clangd.setup({
    cmd = {
        "clangd",
        "--query-driver=C:/msys64/ucrt64/bin/gcc.exe",
        "--compile-commands-dir=.",
        "--header-insertion=iwyu"
    },
    on_attach = on_attach,
    capabilities = capabilities,
})

-- lua_ls for Lua
lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
})

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

-- Formatter setup
require("formatter").setup({
    filetype = {
        c = { require("formatter.filetypes.c").clangformat },
        cpp = { require("formatter.filetypes.cpp").clangformat },
        csharp = {
            function()
                return {
                    exe = "dotnet-csharpier",
                    args = { "--write-stdout" },
                    stdin = true,
                }
            end,
        },
    }
})
vim.cmd([[autocmd BufWritePost *.c,*.cpp,*.h,*.cs FormatWrite]])

-- Autopairs setup
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

-- Connect autopairs to cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

