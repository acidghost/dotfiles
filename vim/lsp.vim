if has('nvim-0.5')
" neovim lsp
lua << EOF
local nvim_lsp = require('lspconfig')

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>led', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>lep', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>len', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>leq', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    --Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, opts)
    -- vim.keymap.set('n', '<leader>lvd', '<cmd>vs<CR><Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.keymap.set('n', '<leader>lvd', function()
        vim.cmd("vs")
        vim.lsp.buf.definition()
    end, opts)
    vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>lk', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>lwl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>lx', vim.lsp.buf.references, opts)
    vim.keymap.set("n", '<leader>lf', vim.lsp.buf.format, opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
    clangd = {};
    -- fsautocomplete = {};
    gopls = {};
    hls = {};
    pyright = {};
    rust_analyzer = {
        ['rust-analyzer'] = {
            cargo = {
                loadOutDirsFromCheck = true
            },
            procMacro = {
                enable = true
            },
        }
    };
    tsserver = {};
    efm = {
        rootMarkers = {".git/"},
        languages = {
            python = {
                { formatCommand = "black --quiet -", formatStdin = true },
            },
            sh = {
                { formatCommand = "shfmt --filename=${INPUT} -s -bn -i=4", formatStdin = true },
            },
        },
    };
}
for lsp, settings in pairs(servers) do
    local setup = {
        on_attach = on_attach,
        flags = { debounce_text_changes = nil },
        settings = settings,
    }
    if lsp == "efm" then
        setup.init_options = { documentFormatting = true }
    end
    nvim_lsp[lsp].setup(setup)
end
EOF
end

" deoplete
" let g:deoplete#enable_at_startup = 1
" set completeopt-=preview

if has('nvim-0.5')

" nvim-cmp
set completeopt=menu,menuone,noselect
lua <<EOF
local cmp = require'cmp'
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-j>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ['<C-k>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})
-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
EOF

" nvim-lspfuzzy
lua require('lspfuzzy').setup {}

end
