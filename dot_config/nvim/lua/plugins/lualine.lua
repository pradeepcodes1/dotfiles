return {
  { "nvim-lualine/lualine.nvim", 
  config =  function()
    require('lualine').setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {''},
    lualine_x = {},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}
end
},

}