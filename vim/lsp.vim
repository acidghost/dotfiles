if has('nvim-0.5')
" neovim lsp
lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    set_keymap('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    set_keymap('n', '<leader>ld', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    set_keymap('n', '<leader>lvd', '<cmd>vs<CR><Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    set_keymap('n', '<leader>lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    set_keymap('n', '<leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    set_keymap('n', '<leader>lk', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    set_keymap('n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    set_keymap('n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    set_keymap('n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    set_keymap('n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    set_keymap('n', '<leader>lx', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    set_keymap('n', '<leader>led', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    set_keymap('n', '<leader>lep', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    set_keymap('n', '<leader>len', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    set_keymap('n', '<leader>leq', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    set_keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

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
        cargo = {
            loadOutDirsFromCheck = true
        },
        procMacro = {
            enable = true
        },
    };
    tsserver = {};
}
for lsp, settings in pairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = { debounce_text_changes = nil },
        settings = settings,
    }
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
        { name = 'cmdline' },
    })
})
EOF

" nvim-lspfuzzy
lua require('lspfuzzy').setup {}

end
