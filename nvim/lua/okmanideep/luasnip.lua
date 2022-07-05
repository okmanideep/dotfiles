local ls = require "luasnip"

ls.config.set_config {
    -- This tells LuaSnip to remember to keep around the last snippet.
    -- You can jump back into it even if you move outside of the selection.
    history = true,

    -- This one is cool cause if you have dynamic snippets, it updates as you type!
    updateevents = "TextChanged,TextChangedI",

    -- Autosnippets
    enable_autosnippets = true,
}

local next = function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end

local prev = function ()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end

vim.keymap.set({ "i", "s" }, "<c-j>", next, { silent = true })
vim.keymap.set({ "i", "s" }, "<c-k>", prev, { silent = true })
