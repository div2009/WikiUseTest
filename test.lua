print("hello world");
local function printtable(tab)
    for k, v in pairs(tab) do
        local k_type = type(k)
        local v_type = type(v)
        print("k_type=",k_type)
        print("v_type=",v_type)
        local key = (k_type == "string" and   k  ) or (k_type == "number" and " ")
        local value = (v_type == "table" and printtable(v)) or (v_type == "boolean" and tostring(v)) or (v_type == "string" and   v  ) or (v_type == "number" and v)
        local str = string.format('%s = %s\n',key,value)
        print(str)
        


        


    end

end

local function test(A)

    --print(A);
    local a = "ACG"
    local i = 100
    local tab = { "ggg" }

    local t = (a == "ACG" and "\"" .. i .. "\":") or (a == "number" and "")
    tab[#tab + 1] = a and i and tostring(t) .. "xxxx" or nil

    -- print(t)
    printtable(tab)

    return 0;
end

test(1)
