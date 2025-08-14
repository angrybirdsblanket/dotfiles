return {
  -- Mason for managing external tools
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip'
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() else fallback() end
          end, { "i", "s" }),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item() else fallback() end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
        snippet = {
          expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
        },
      })
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
      -- Diagnostics
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      vim.o.updatetime = 250
      vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

      local lsp_defaults = require('lspconfig').util.default_config
      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
          vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        end,
      })

      require('mason-lspconfig').setup({
        ensure_installed = {
          "pyright",
          "clangd",
          "eslint",
          "ts_ls",          -- JS/TS
          "omnisharp",
          "rust_analyzer",
          "kotlin_language_server", -- ✅ add Kotlin
        },
        handlers = {
          -- default handler
          function(server_name)
            require('lspconfig')[server_name].setup({})
          end,

          -- OmniSharp
          ["omnisharp"] = function()
            require('lspconfig').omnisharp.setup({
              cmd = { "omnisharp", "--languageserver" },
              enable_roslyn_analyzers = true,
              organize_imports_on_format = true,
              enable_import_completion = true,
            })
          end,

          -- ESLint (use the LSP, don't override with pnpm)
          ["eslint"] = function()
            require('lspconfig').eslint.setup({
              settings = {
                -- keep defaults; Mason provides vscode-eslint-language-server
              },
            })
          end,

          -- Kotlin: clean init (no bad init_options)
          ["kotlin_language_server"] = function()
            local util = require('lspconfig').util
            require('lspconfig').kotlin_language_server.setup({
              root_dir = util.root_pattern(
                "settings.gradle", "settings.gradle.kts",
                "build.gradle", "build.gradle.kts",
                "gradlew", "pom.xml", ".git"
              ),
              -- If you really want storagePath, make sure it's an OBJECT:
              -- init_options = { storagePath = vim.fn.stdpath("cache") .. "/kotlin" },
            })
          end,
        },
      })
    end,
  },
}
