local treesitterspec = {  -- Highlight, edit, and navigate code
	'nvim-treesitter/nvim-treesitter',
	branch = 'main',
	build = ':TSUpdate'
}

return { -- Additional text objects via treesitter
	'nvim-treesitter/nvim-treesitter-textobjects',
	branch = 'main',
	dependencies = { treesitterspec }
}
