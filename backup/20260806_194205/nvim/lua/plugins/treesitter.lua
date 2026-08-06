return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()
		require("nvim-treesitter").install({
			"lua",
			"python",
			"javascript",
			"typescript",
			"html",
			"css",
			"json",
			"bash",
		})
	end,
}
