local json = require("pub/json")
local temp = require("data/Blueprints_data")

local function appendFile(fileName, content)
    local f = assert(io.open(fileName, 'w'))
    f:write(content)
    f:close()
end


local function test(A)

     --print(A)
    appendFile('test.json', json.encode(temp))--temp就是要转换的数据
    return 0;
end

test(1)
