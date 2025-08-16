return {
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvimtools/none-ls-extras.nvim" },
        opts = function()
            local nls = require("null-ls")
            nls.setup {
                sources = {
                    nls.builtins.formatting.black.with { extra_args = { "--fast" } },
                    require("none-ls.diagnostics.ruff"),
                    nls.builtins.formatting.google_java_format,
                },
            }
        end
    },
}
