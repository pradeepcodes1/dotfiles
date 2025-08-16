  local cmp = require("cmp")
        cmp.setup({
             sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'copilot' },  -- Add this line
                { name = 'buffer' },
                { name = 'path' },
            }),
             mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous item
        ["<C-j>"] = cmp.mapping.select_next_item(), -- Next item
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
        ["<C-e>"] = cmp.mapping.abort(), -- Close completion
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection

        -- Special <Tab> mapping to navigate snippets or select next item
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

})