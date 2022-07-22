local p = {}

local IconData = mw.loadData("Module:Icon/data")
local IconDataOverride = mw.loadData("Module:Icon/data/override")
local PolarityData = mw.loadData("Module:Polarity")
local terms = mw.loadData("Module:Icon/terms")
local TableUtil = require("Module:TableUtil")
local trans = require("Module:Translate")
local DamageTypesData = mw.loadData("Module:DamageTypes/data")
local DamageTypesTerms = mw.loadData("Module:DamageTypes/terms")
local FocusData = mw.loadData("Module:Focus/data")
local ResourceDataOrigin = mw.loadData("Module:Resources/data")
local ResourceData = ResourceDataOrigin["Resources"]
local CompanionData = mw.loadData('Module:Companions/data')['Companions']
local WeaponData = mw.loadData("Module:Weapons/data/preprocessing")["Weapons"] 
local WarframeData = mw.loadData('Module:Warframes/data')['Warframes']

function transPart(part, item)
    if item then
        if terms[item] then
            if terms[item][part] then
                return terms[item][part]
            end
        end
    end
    if terms[part] then
        return terms[part]
    end
    return trans.toChineseCI(part)
end

function p.Item(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Item(iconname, textexist, imagesize)
end

-- Extracting out to this function allows other Modules to call item text
-- Since any templates output by another module won't be parsed by the wiki
function p._Item(iconname, textexist, imagesize)
    local iconname = string.gsub(" " .. string.lower(iconname), "%W%l", string.upper):sub(2)
    local link = ""
    if IconData["Items"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = TableUtil.getValue(IconDataOverride, "Items", iconname, "Link") or
                   TableUtil.getValue(IconData, "Items", iconname, "Link")
        title = TableUtil.getValue(IconDataOverride, "Items", iconname, "title") or
                    trans.toChineseCI(IconData["Items"][iconname]["title"])
        iconname = TableUtil.getValue(IconDataOverride, "Items", iconname, "Image") or
                       TableUtil.getValue(IconData, "Items", iconname, "Image")
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end

        local imgText = "[[File:" .. iconname .. "|" .. imagesize .. "px"
        if (link ~= nil) then
            imgText = imgText .. "|link=" .. link .. (title and "|" .. title or "")
        elseif (title ~= nil) then
            imgText = imgText .. "|" .. title
        end
        imgText = imgText .. "]]"

        if (textexist == "text" or textexist == "Text") then
            if (link ~= nil) then
                return imgText .. "&thinsp;[[" .. link .. (title and "|" .. title or "") .. "]]"
            elseif (title ~= nil) then
                return imgText .. "&thinsp;" .. title
            else
                return imgText
            end
        end
        return imgText
    end
end

function p.Pol(frame)
    local iconname = frame.args[1]
    local color = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Pol(iconname, color, imagesize)
end

function p._Pol(iconname, color, imagesize)
    if PolarityData[iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]' -- white icon --black icon
    else
        if color == "white" then
            iconname = PolarityData[iconname]["icon"][2]
        else
            iconname = PolarityData[iconname]["icon"][1]
        end
        if (imagesize == nil or imagesize == "") then
            imagesize = "x21"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=Polarity]]"
    end
end

function p.Dis(frame)
    local name = frame.args[1]
    local color = frame.args[2]
    local size = frame.args.imgsize
    return p._Dis(name, color, size)
end

function p._Dis(name, color, size)
    local link = 'Riven_Mods#Disposition'
    if (color == nil or color == '') then
        color = 'black'
    end
    if (size == nil or size == '') then
        size = 27
    end
    assert(name ~= nil,
        'p._Dis(name, color, size): Invalid icon name "' .. (name or '') .. '" [[分类:Icon模块错误]]')

    local dots = ''
    name = tonumber(name)
    if (name < 0.7) then
        dots = '●○○○○'
    elseif (name < 0.9) then
        dots = '●●○○○'
    elseif (name < 1.109) then
        dots = '●●●○○'
    elseif (name < 1.309) then
        dots = '●●●●○'
    else
        dots = '●●●●●'
    end
    return '[[' .. link .. '|<span style="font-size:' .. size .. 'px; display:inline; position:relative; top:2px">' ..
               dots .. '</span>]]'
end
function p.Dis5(frame)
    local name = frame.args[1]
    local color = frame.args[2]
    local size = frame.args.imgsize
    return p._Dis5(name, color, size)
end

function p._Dis5(name, color, size)
    local link = "Riven_Mods#Disposition"
    local circle = '<span class="fa fa-circle"></span>'
    local circle_o = '<span class="fa fa-circle-o"></span>'
    local sp = "&thinsp;"
    if (color == nil or color == "") then
        color = "black"
    end
    if (size == nil or size == "") then
        size = 14
    end
    local head = "[[" .. link .. '|<span style="font-size:' .. size .. "px; color:" .. color ..
                     '; display:inline; position:relative; whitespace:nowrap;">'
    local tail = "</span>]]"
    if name == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        name = tonumber(name)
        if (name <= 1) then
            return head .. circle .. sp .. circle_o .. sp .. circle_o .. sp .. circle_o .. sp .. circle_o .. sp .. tail
        elseif (name <= 2) then
            return head .. circle .. sp .. circle .. sp .. circle_o .. sp .. circle_o .. sp .. circle_o .. sp .. tail
        elseif (name <= 3) then
            return head .. circle .. sp .. circle .. sp .. circle .. sp .. circle_o .. sp .. circle_o .. sp .. tail
        elseif (name <= 4) then
            return head .. circle .. sp .. circle .. sp .. circle .. sp .. circle .. sp .. circle_o .. sp .. tail
        else
            return head .. circle .. sp .. circle .. sp .. circle .. sp .. circle .. sp .. circle .. sp .. tail
        end
    end
end

function p.Affinity(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Affinity(iconname, textexist, imagesize)
end

function p._Affinity(iconname, textexist, imagesize)
    local link, name
    if IconData["Affinity"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = IconData["Affinity"][iconname]["Link"]
        name = TableUtil.getValue(IconDataOverride, "Affinity", iconname, "title") or
                   trans.toChineseCI(IconData["Affinity"][iconname]["title"]) or trans.toChineseCI(iconname)
        local imgname = IconData["Affinity"][iconname]["Image"]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end
        if (textexist == "text" or textexist == "Text") then
            return "[[File:" .. imgname .. "|" .. imagesize .. "px|link=" .. link .. "]]&thinsp;[[" .. link .. "|" ..
                       name .. "]]"
        end
        return "[[File:" .. imgname .. "|" .. imagesize .. "px|link=" .. link .. "]]"
    end
end

function p.Faction(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Faction(iconname, textexist, imagesize)
end

-- Extracting out to this function allows other Modules to call item text
-- Since any templates output by another module won't be parsed by the wiki
function p._Faction(iconname, textexist, imagesize)
    local iconname = string.gsub(" " .. string.lower(iconname), "%W%l", string.upper):sub(2)
    local link = ""
    if IconData["Factions"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = TableUtil.getValue(IconDataOverride, "Factions", iconname, "Link") or
                   TableUtil.getValue(IconData, "Factions", iconname, "Link")
        title = TableUtil.getValue(IconDataOverride, "Factions", iconname, "title") or
                    trans.toChineseCI(IconData["Factions"][iconname]["title"])
        iconname = TableUtil.getValue(IconDataOverride, "Factions", iconname, "Image") or
                       TableUtil.getValue(IconData, "Factions", iconname, "Image")
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end

        local imgText = "[[File:" .. iconname .. "|" .. imagesize .. "px"
        if (link ~= nil) then
            imgText = imgText .. "|link=" .. link .. (title and "|" .. title or "")
        elseif (title ~= nil) then
            imgText = imgText .. "|" .. title
        end
        imgText = imgText .. "]]"

        if (textexist == "text" or textexist == "Text") then
            if (link ~= nil) then
                return imgText .. "&thinsp;[[" .. link .. (title and "|" .. title or "") .. "]]"
            elseif (title ~= nil) then
                return imgText .. "&thinsp;" .. title
            else
                return imgText
            end
        end
        return imgText
    end
end

function p.Syndicate(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Syndicate(iconname, textexist, imagesize)
end

-- Extracting out to this function allows other Modules to call item text
-- Since any templates output by another module won't be parsed by the wiki
function p._Syndicate(iconname, textexist, imagesize)
    local iconname = string.gsub(" " .. string.lower(iconname), "%W%l", string.upper):sub(2)
    local link = ""
    if IconData["Factions"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = TableUtil.getValue(IconDataOverride, "Factions", iconname, "Link") or
                   TableUtil.getValue(IconData, "Factions", iconname, "Link")
        title = TableUtil.getValue(IconDataOverride, "Factions", iconname, "title") or
                    trans.toChineseCI(IconData["Factions"][iconname]["title"])
        iconname = TableUtil.getValue(IconDataOverride, "Factions", iconname, "Image") or
                       TableUtil.getValue(IconData, "Factions", iconname, "Image")
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end

        local imgText = "[[File:" .. iconname .. "|" .. imagesize .. "px"
        if (link ~= nil) then
            imgText = imgText .. "|link=" .. link .. (title and "|" .. title or "")
        elseif (title ~= nil) then
            imgText = imgText .. "|" .. title
        end
        imgText = imgText .. "]]"

        if (textexist == "text" or textexist == "Text") then
            if (link ~= nil) then
                return imgText .. "&thinsp;[[" .. link .. (title and "|" .. title or "") .. "]]"
            elseif (title ~= nil) then
                return imgText .. "&thinsp;" .. title
            else
                return imgText
            end
        end
        return imgText
    end
end

function p.Prime(frame)
    local primename = frame.args[1]
    local partname = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Prime(primename, partname, imagesize)
end

function p._Prime(primename, partname, imagesize)
    local link = ''
    local iconname = ''
    -- assert(IconData["Primes"][primename] ~= nil, 'p._Prime(primename, partname, imagesize): Invalid icon name "'..(primename or '')..'" [[Category:Icon Module error]]')
    -- local PrimeiconData = (((ConpanionData or WeaponData) or WarframeData) or ResourceData)
    local PrimeiconData
    if WeaponData[primename] then
        PrimeiconData = WeaponData
    elseif WarframeData[primename] then
        PrimeiconData = WarframeData
    elseif ResourceData[primename] then
        PrimeiconData = ResourceData
    elseif CompanionData[primename] then
        PrimeiconData = CompanionData
    end

    if (PrimeiconData[primename] == nil) then
        return '[[File:Panel.png|x' .. imagesize .. 'px]]'
    end

    link = PrimeiconData[primename]["Link"]
    iconname = PrimeiconData[primename]["Image"]
    if (imagesize == nil or imagesize == '') then
        imagesize = '32'
    end

    if partname ~= nil then
        partname = string.gsub(" " .. string.lower(partname), "%W%l", string.upper):sub(2)

        local result = ''
        if primename == "Forma" then
            result = "[[File:" .. iconname .. '|x' .. imagesize .. 'px|link=' .. link .. ']]'
            result = result .. '&nbsp;[[' .. link .. '#Acquisition|' .. primename .. " " .. partname .. ']]'
        else
        	local primename_inner = trans.toChineseCI(primename) or primename
            result = "[[File:" .. iconname .. '|x' .. imagesize .. 'px|link=' .. link .. ']]'
            result = result .. '&nbsp;[[' .. link .. '#Acquisition|' .. primename_inner .. " " .. partname .. ']]'
        end
        return result
    end

    return "[[File:" .. iconname .. '|x' .. imagesize .. 'px|link=' .. link .. ']]'
end

function p.Resource(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Resource(iconname, textexist, imagesize)
end

function p._Resource(iconname, textexist, imagesize)
    local link, name
    if ResourceData[iconname] == nil then
        if (textexist == "text" or textexist == "Text") then
            return "[[" .. iconname .. "|" .. trans.toChineseCI(iconname) .. "]]"
        end
        -- TODO: A placeholder icon and do this for all the item types
        return ""
    else
        link = ResourceData[iconname]["Link"]
        local pos = string.find(link, '|')
        local title = ResourceData[iconname]["title"] or link
        if pos then
            title = string.sub(link, pos + 1)
            link = string.sub(link, 1, pos - 1)
        end
        name = TableUtil.getValue(IconDataOverride, "Resources", iconname, "title") or trans.toChineseCI(title)
        iconname = ResourceData[iconname]["Image"]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x28"
        end
        if (textexist == "text" or textexist == "Text") then
            return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]&thinsp;[[" ..
                       link .. "|" .. name .. "]]"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]"
    end
end

function p.Parts(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Parts(iconname, textexist, imagesize)
end

function p._Parts(iconname, textexist, imagesize)
    local link, name
    if ResourceDataOrigin['GenericComponents'][iconname] == nil then
        if (textexist == "text" or textexist == "Text") then
            return "[[" .. iconname .. "|" .. trans.toChineseCI(iconname) .. "]]"
        end
        -- TODO: A placeholder icon and do this for all the item types
        return ""
    else
        link = ResourceDataOrigin['GenericComponents'][iconname]["Link"]
        local pos = string.find(link, '|')
        local title = ResourceDataOrigin['GenericComponents'][iconname]["title"] or link
        if pos then
            title = string.sub(link, pos + 1)
            link = string.sub(link, 1, pos - 1)
        end
        name = TableUtil.getValue(IconDataOverride, "Resources", iconname, "title") or trans.toChineseCI(title)
        iconname = ResourceDataOrigin['GenericComponents'][iconname]["Image"]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x28"
        end
        if (textexist == "text" or textexist == "Text") then
            return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]&thinsp;[[" ..
                       link .. "|" .. name .. "]]"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]"
    end
end

function p.test_Resource()
    local _, result = pcall(p._Resource, "Damaged Necramech Weapon Barrel", "Text")
    return result
end

function p.Fish(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize

    return p._Fish(iconname, textexist, imagesize)
end

function p._Fish(iconname, textexist, imagesize)
    local link, name
    if ResourceData[iconname] == nil then
        if (textexist == "text" or textexist == "Text") then
            return "[[" .. iconname .. "|" .. trans.toChineseCI(iconname) .. "]]"
        end
        return ""
    else
        link = ResourceData[iconname]["Link"]
        local pos = string.find(link, '|')
        local title = ResourceData[iconname]["title"] or link
        if pos then
            title = string.sub(link, pos + 1)
            link = string.sub(link, 1, pos - 1)
        end
        name = TableUtil.getValue(IconDataOverride, "Resources", iconname, "title") or trans.toChineseCI(title)
        iconname = ResourceData[iconname]["Image"]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x28"
        end
        if (textexist == "text" or textexist == "Text") then
            return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]&thinsp;[[" ..
                       link .. "|" .. name .. "]]"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "|" .. name .. "]]"
    end
end

function p.Proc(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local color = frame.args[3]
    local display_text = frame.args.text
    local imagesize = frame.args.imgsize
    return p._Proc(iconname, textexist, color, display_text, imagesize)
end

function p._Proc(iconname, textexist, color, display_text, imagesize)
    local link = ""
    local iconFile = ""
    local textcolor = ""
    local title = ""
    local span1 = ""
    local span2 = ""
    iconname = tooltipCheck(iconname, 'Proc')
    local dt_icon = DamageTypesData["Types"][iconname] or DamageTypesData["Health"][iconname] or
                        DamageTypesData["Procs"][iconname]

    if (string.upper(iconname) == "UNKNOWN") then
        return ""
    elseif not dt_icon then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        local spanTable = tooltipSpan(iconname, "Proc")
        if spanTable then
            span1 = spanTable[1]
            span2 = spanTable[2]
        end
        link = dt_icon.Link
        if display_text ~= nil and display_text ~= '' then
        	title = display_text
        else
        	title = DamageTypesTerms[dt_icon.Name] or trans.toChineseCI(dt_icon.Name)
        end
        --[[if color == "white" then
			iconFile = DamageTypesData["Types"][iconname]["Image"][2] --white icon --black icon
		else
			iconFile = DamageTypesData["Types"][iconname]["icon"][1]
		end]]
        iconFile = dt_icon.Icon
        if (imagesize == nil or imagesize == "") then
            imagesize = "x18"
        end
        local icon = iconFile and "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "]]" or ''
        if (textexist == "text" or textexist == "Text") then
            textcolor = (color ~= nil and color ~= '') and color or dt_icon.Color
            return span1 .. icon .. " [[" .. link .. '|<span class="tt-text" style="color:' .. textcolor .. ';">'
            	.. title .. "</span>]]" .. span2
        end
        return span1 .. icon .. span2
    end
end

function p.test_Proc()
    local flag, result = pcall(p._Proc, 'Poison', 'Text')
    return result
end

function p._Procs(iconname, textexist, color, imagesize, ignoreTextColor)
    local link = ""
    local iconFile = ""
    local textcolor = ""
    local title = ""
    local span1 = ""
    local span2 = ""
    local typedata = {}

    if (string.upper(iconname) == "UNKNOWN") then
        return ""
    elseif DamageTypesData["Procs"][iconname] == nil then
    	if DamageTypesData["Types"][iconname] == nil then
        	return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
        else
        	typedata = DamageTypesData["Types"][iconname]
        end
    else
    	typedata = DamageTypesData["Procs"][iconname]
    end
    
    if typedata ~= nil then
        local spanTable = tooltipSpan(iconname, "Proc")
        if spanTable then
            span1 = spanTable[1]
            span2 = spanTable[2]
        end
        local tooltip = typedata["title"]
        link = TableUtil.getValue(IconDataOverride, "Procs", iconname, "Link") or
                   typedata["Link"]
        title = TableUtil.getValue(IconDataOverride, "Procs", iconname, "title") or
                    trans.toChineseCI(typedata["title"])
        --[[if color == "white" then
			iconFile = DamageTypesData["Procs"][iconname]["icon"][2] --white icon --black icon
		else
			iconFile = DamageTypesData["Procs"][iconname]["icon"][1]
		end]]

        iconFile = typedata["Icon"]
        link = trans.toChineseCI(typedata["Link"])

        if (imagesize == nil or imagesize == "") then
            imagesize = "x18"
        end
        if (textexist == "text" or textexist == "Text") then
            textcolor = typedata["Color"]
            if (ignoreTextColor == nil or not ignoreTextColor) then
                if (tooltip ~= nil and tooltip ~= "") then
                    return span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "|" .. tooltip ..
                               "]] [[" .. link .. '|<span style="color:' .. textcolor .. ';">' .. title .. "</span>]]" ..
                               span2
                else
                    return
                        span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "]] [[" .. link ..
                            '|<span style="color:' .. textcolor .. ';">' .. title .. "</span>]]" .. span2
                end
            else
                if (tooltip ~= nil and tooltip ~= "") then
                    return span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "|" .. tooltip ..
                               "]] [[" .. link .. "|" .. title .. "]]" .. span2
                else
                    return
                        span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "]] [[" .. link ..
                            "|" .. title .. "]]" .. span2
                end
            end
        end
        if (tooltip ~= nil and tooltip ~= "") then
            return span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "|" .. tooltip .. "]]" ..
                       span2
        else
            return span1 .. "[[File:" .. iconFile .. "|" .. imagesize .. "px|link=" .. link .. "]]" .. span2
        end
    end
end

function p.Focus(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local color = frame.args[3]
    local icontype = frame.args[4]
    local imagesize = frame.args.imgsize
    local name = ""
    if FocusData["Focus"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        if icontype == "seal" then
            if color == "white" then
                iconname = FocusData["Focus"][iconname]["seal"][2]
            else
                iconname = FocusData["Focus"][iconname]["seal"][1]
            end
        else
            if color == "white" then
                iconname = FocusData["Focus"][iconname]["icon"][2]
            else
                iconname = FocusData["Focus"][iconname]["icon"][1]
            end
        end
        if (imagesize == nil or imagesize == "") then
            imagesize = "x20"
        end
        name = TableUtil.getValue(IconDataOverride, "Focus", frame.args[1], "title") or
                   trans.toChineseCI(FocusData["Focus"][frame.args[1]]["title"]) or trans.toChineseCI(frame.args[1])
        if (textexist == "text" or textexist == "Text") then
            textcolor = FocusData["Focus"][frame.args[1]]["color"]
            return "[[File:" .. iconname .. "|" .. imagesize .. "px|sub|link=Focus]]&thinsp;[[Focus|" .. name .. "]]"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=Focus]]"
    end
end

function p.Way(frame)
    local iconname = frame.args[1]
    local imagesize = frame.args.imgsize
    local link = ""
    if FocusData["Ways"][iconname] == nil then
        return '<span style="color:red;">Missing<br>Icon</span>'
    else
        iconname = FocusData["Ways"][iconname]
    end
    if (imagesize == nil or imagesize == "") then
        imagesize = "x18"
    end
    return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=" .. link .. "]]"
end

function p.HUD(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local color = frame.args[3]
    local imagesize = frame.args.imgsize
    local link = ""
    if IconData["Heads-Up Display"][iconname] == nil then
        return "[[" .. iconname .. "]]" -- white icon --black icon
    else
        link = IconData["Heads-Up Display"][iconname]["Link"]
        if color == "white" then
            iconname = IconData["Heads-Up Display"][iconname]["Image"][2]
        else
            iconname = IconData["Heads-Up Display"][iconname]["Image"][1]
        end
        if (imagesize == nil or imagesize == "") then
            imagesize = "x20"
        end
        if (textexist == "text" or textexist == "Text") then
            return
                "[[File:" .. iconname .. "|" .. imagesize .. "px|link=Heads-Up Display]][[Heads-Up Display|" .. link ..
                    "]]"
        end
        return "[[File:" .. iconname .. "|" .. imagesize .. "px|link=Heads-Up Display]]"
    end
end

function p.Flag(frame)
    local iconname = frame.args[1]
    local tooltip = frame.args[2]
    local dest = frame.args[3]
    local textexist = frame.args[4]
    if IconData["Flags"][iconname] == nil then
        return '<span style="color:red;">无效</span>'
    else
        iconname = IconData["Flags"][iconname]
        if tooltip == nil then
            tooltip = ""
        end
        if dest == nil then
            dest = ""
        end
        if (textexist == "text" or textexist == "Text") then
            return
                "[[File:" .. iconname .. "|" .. tooltip .. "|16px|link=" .. dest .. "]] [[" .. dest .. "|" .. tooltip ..
                    "]]"
        end
        return "[[File:" .. iconname .. "|" .. tooltip .. "|16px|link=" .. dest .. "]]"
    end
end

function p.Melee(frame)
    local AttackType = frame.args[1]
    local ProcType = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Melee(AttackType, ProcType, imagesize)
end

function p._Melee(AttackType, ProcType, imagesize)
    if (AttackType == nil or AttackType == "") then
        AttackType = "DEFAULT"
    else
        AttackType = string.upper(AttackType)
    end
    if (ProcType == nil or ProcType == "") then
        ProcType = "DEFAULT"
    else
        ProcType = string.upper(ProcType)
    end
    if (imagesize == nil or imagesize == "") then
        imagesize = "x22"
    end

    if (IconData["Melee"][ProcType] == nil or IconData["Melee"][ProcType][AttackType] == nil) then
        return '<span style="color:red;">Invalid</span>'
    end

    local icon = IconData["Melee"][ProcType][AttackType].icon
    local link = IconData["Melee"][ProcType][AttackType].link
    local title = IconData["Melee"][ProcType][AttackType].title
    local tooltip = IconData["Melee"][ProcType][AttackType].tooltip
    if (icon == nil or icon == "") then
        return '<span style="color:red;">Invalid</span>'
    end

    local result = "[[File:" .. icon
    if (tooltip ~= nil and tooltip ~= "") then
        result = result .. "|" .. tooltip
    end
    result = result .. "|" .. imagesize .. "px"
    if link ~= nil then
        result = result .. "|link=" .. link
    end
    if title ~= nil then
        result = result .. "|" .. title
    end
    result = result .. "]]"
    return result
end

function p.Zaw(frame)
    local zawname_input = frame.args[1]
    local textexist = frame.args[2]
    local imagesize_input = frame.args.imgsize
    return p._Zaw(zawname_input, textexist, imagesize_input)
end

function p._Zaw(zawname, textexist, imagesize)
    zawname = string.gsub(" " .. string.lower(zawname), "%W%l", string.upper):sub(2)
    local link = ""
    if IconData["Zaws"][zawname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = IconData["Zaws"][zawname]["Link"]
        local title = TableUtil.getValue(IconDataOverride, "Zaws", iconname, "title") or
                          trans.toChineseCI(IconData["Zaws"][iconname]["title"])
        zawname = IconData["Zaws"][zawname]["Image"]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end

        local imgText = "[[File:" .. zawname .. "|" .. imagesize .. "px"
        if (link ~= nil) then
            imgText = imgText .. "|link=" .. link
        elseif (title ~= nil) then
            imgText = imgText .. "|" .. title
        end
        imgText = imgText .. "]]"

        if (textexist == "text" or textexist == "Text") then
            if (link ~= nil) then
                if (title ~= nil) then
                    return imgText .. " [[" .. link .. "|" .. title .. "]]"
                else
                    return imgText .. " [[" .. link .. "]]"
                end
            elseif (title ~= nil) then
                return imgText .. " " .. title
            else
                return imgText
            end
        end
        return imgText
    end
end

function p.Buff(frame)
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Buff(iconname, textexist, imagesize)
end

function p._Buff(iconname, textexist, imagesize)
    local link, name
    if IconData["Buff"][iconname] == nil then
        return '<span style="color:red;">无效</span>[[分类:Icon模块错误]]'
    else
        link = IconData["Buff"][iconname]["Link"]
        name = TableUtil.getValue(IconDataOverride, "Buff", iconname, "title") or
                   trans.toChineseCI(IconData["Buff"][iconname]["title"]) or trans.toChineseCI(iconname)
        apairs = TableUtil.getValue(IconDataOverride, "Buff", iconname, "Image")
        local imgname = apairs[2]
        if (imagesize == nil or imagesize == "") then
            imagesize = "x26"
        end
        if (textexist == "text" or textexist == "Text") then
            return "[[File:" .. imgname .. "|" .. imagesize .. "px|link=" .. link .. "]]&thinsp;[[" .. link .. "|" ..
                       name .. "]]"
        end
        return "[[File:" .. imgname .. "|" .. imagesize .. "px|link=" .. link .. "]]"
    end
end

function tooltipCheck(name, typename)
    local procList = {"Impact", "Puncture", "Slash", {"Cold", "Freeze"}, {"Electricity", "Electric"}, {"Heat", "Fire"},
                      {"Toxin", "Poison"}, "Void", "Blast", "Corrosive", "Gas", "Magnetic", "Radiation", "Viral", "True"}
    if typename == "Proc" then
        for i, Name in pairs(procList) do
            if type(Name) == "table" then
                if Name[1] == name or Name[2] == name then
                    name = Name[1]
                    return name
                end
            elseif type(Name) == "string" then
                if Name == name then
                    return name
                end
            end
        end
    end
    return name
end

function tooltipSpan(name, typename)
    local iconName = tooltipCheck(name, typename)
    local span = {}
    if iconName and typename == "Proc" then
        span[1] = '<span class="huiji-tt dt-tooltip" data-type="DamageType" data-name="' .. iconName .. '">'
        span[2] = "</span>"
        return span
    end
    return nil
end

function p.Test2(par1, par2)
    local spans = tooltipSpan(par1, par2)
    return spans[1] .. spans[2]
end

function p.Test(frame)
    return p._Proc(frame.args[1])
end

-- 仅用于Cost检测是否存在对应Resource/Item图标，没有则返回no--
function p.CheckExist(frame)
    local object = frame
    if IconData["Items"][object] == nil and ResourceData[object] == nil and ResourceDataOrigin["GenericComponents"][object] == nil then
        return "no"
    end
end

-- 仅用于DropTable检测是否存在对应Resource图标，有则返回yes--
function p.CheckExistResource(frame)
    local object = frame
    if ResourceData[object] ~= nil then
        return "yes"
    end
end

-- 用于在页面上检测图标是否存在的函数，存在则返回“yes”，不存在则范围空值
function p.checkIcon(frame)
    local type, item = frame.args[1], frame.args[2]
    if type == "Resource" then
        type = "Resources"
    elseif type == "Item" then
        type = "Items"
    end
    if TableUtil.getValue(IconData, type, item) ~= nil then
        return "yes"
    else
        return ""
    end
end

return p
