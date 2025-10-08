return {
  {
    "stevearc/conform.nvim",
    -- Ensure this plugin is loaded, or handle it as per your lazy.nvim setup
    -- For example, you might have it as part of a larger formatting extra in LazyVim
    opts = {
      formatters_by_ft = {
        xml = { "xmlformatter" }, -- Replace with the actual formatter name
        ui = { "xmlformatter" },
      },
      -- You can add other global conform options here if needed
    },
  },
}
