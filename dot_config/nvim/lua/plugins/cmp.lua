return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
            --   config = function()
            --     local cmp = require("cmp")
            --     cmp.setup({
            --          sources = cmp.config.sources({
            --             { name = 'nvim_lsp' },
            --             { name = 'copilot' },  -- Add this line
            --             { name = 'buffer' },
            --             { name = 'path' },
            --         }),
            --     })
            --     end
        }
    },
}

