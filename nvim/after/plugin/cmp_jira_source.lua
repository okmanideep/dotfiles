local source = {}

source.new = function ()
    local self = setmetatable({ cache = {} }, { __index = source })

    return self
end

source.complete = function (_, ctx, _)
    print(vim.inspect(ctx))
end

source.is_available = function ()
    return false
end

require("cmp").register_source("jira", source.new())
