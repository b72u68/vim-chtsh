local cheat = {}

local base_url = "https://cht.sh"
local filetype = vim.bo.filetype

cheat.default_options = {
    include_comments = 1,
    query_include_language = 0,
}

function cheat.get_command(query, options)
    local url, tag

    local include_comments = options.include_comments or cheat.default_options.include_comments
    local query_include_language = options.no_comments or cheat.default_options.query_include_language

    if include_comments == 0 then
        tag = "\\?QT"
    else
        tag = "\\?T"
    end

    if query_include_language == 1 then
        local language
        local first_whitespace = string.find(query, "%s")

        if first_whitespace ~= nil then
            language = string.sub(query, 1, first_whitespace - 1)
            query = (string.sub(query, first_whitespace - 1)):gsub("%s", "+")
            url = string.format("%s/%s/%s%s",
                base_url,
                language,
                query,
                tag
            )
        end
    else
        query = query:gsub("%s", "+")

        if filetype == "tex" then
            filetype = "latex"
        end

        url = string.format("%s/%s/%s%s",
            base_url,
            filetype,
            query,
            tag
        )
    end

    return url
end

function cheat.get_result(query, options)
    local url = cheat.get_command(query, options)

    local command = "!curl --silent " .. url
    local result = vim.api.nvim_exec(command, true)

    local lines = {}
    local line = ""

    for i=1,string.len(result) do
        local c = result:sub(i, i)

        if c == "\n" then
            if line:gsub("%s+", "") ~= "" then
                table.insert(lines, line)
            end
            line = ""
        else
            line = line .. c
        end
    end

    return { unpack(lines, 2) }
end

return cheat
