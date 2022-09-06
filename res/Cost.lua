local p = {}
 
local WeaponModule = require( 'Module:Weapons' )
local WarframeModule = require( 'Module:Warframes' )
local Icon = require( "Module:Icon" )
local Shared = require( "Module:Shared" )
local Void = require( "Module:Void" )
local ResearchData = require( "Module:Research/data" )
local BlueprintData = require( "Module:Blueprints/data" )
local trans = require("Module:Translate")
local SmwBuild = {}
local SmwResearch = {}

function p.getLabLink(factionName)
    if(ResearchData["Labs"][factionName] == nil) then
        return "[[Research|研究]]"
    else
        local labName = ResearchData["Labs"][factionName].Name
        return "[[Research#"..labName.."|"..trans.toChineseCI(labName).."研究]]"
    end
end


function p.getResearch(itemName)
	return ResearchData["Research"][itemName]
end

local function addSmwBuild(item, amount)
	local index = #SmwBuild / 2 + 1
	SmwBuild[#SmwBuild + 1] = 'build' .. index .. '=' .. item
	SmwBuild[#SmwBuild + 1] = 'build' .. index .. 'amount=' .. amount
end

local function addSmwResearch(item, amount)
	local index = #SmwResearch / 2 + 1
	SmwResearch[#SmwResearch + 1] = 'research' .. index .. '=' .. item
	SmwResearch[#SmwResearch + 1] = 'research' .. index .. 'amount=' .. amount
end

local function buildItemText(Item, getResearch)
    if(Item == nil) then
        return " "
    end
	
	-- adding smw properties
	if getResearch then
		addSmwResearch(Item.Name, Item.Count)
	else
		addSmwBuild(Item.Name, Item.Count)
	end
	
    if(Item.Type == "Resource") or (Item.Type == nil) then
    	if (Icon.CheckExist(Item.Name) == 'no') then
    		return trans.toChineseCI(Item.Name).."<br/>"..Shared.formatnum(Item.Count)
    	else
            return Icon._Resource(Item.Name, nil, 'x32').."<br/>"..Shared.formatnum(Item.Count)
        end
    elseif(Item.Type == "Item") then
    	if (Icon.CheckExist(Item.Name) == 'no') then
    		return trans.toChineseCI(Item.Name).."<br/>"..Shared.formatnum(Item.Count)
    	else
            return Icon._Parts(Item.Name, nil, 'x32').."<br/>"..Shared.formatnum(Item.Count)
        end
    elseif(Item.Type == "PrimePart") then
        return Icon._Parts("Prime "..Item.Name, nil, 'x32').."<br/>"..Shared.formatnum(Item.Count)
    elseif(Item.Type == "Weapon") then
        local itemWeapon = WeaponModule.getWeapon(Item.Name)
        if(itemWeapon.Image ~= nil) then
            return '[[File:'..itemWeapon.Image..'|36px|link='..itemWeapon.Name..']]<br/>'..Shared.formatnum(Item.Count)..'[[分类:合成武器]]'
        else
            return "[MISSING IMAGE: "..Item.Name.."]<br/>"..Shared.formatnum(Item.Count)..'[[分类:合成武器]]'
        end
    end
    
end
 
function p.buildWeaponCostBox(frame)
    local WeaponName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = BlueprintData["Blueprints"][WeaponName]
    
    assert(Weapon ~= nil, "函数p.buildWeaponCostBox(frame):当前未找到或不存在 "..WeaponName.." 的铸造数据，请确认模块:Blueprints/data的内容")
 
    local rowStart = '\n| rowspan="2" style="height:50px; width:50px;" |'
    local smallPart = '\n| style="text-align:left; padding: 0em 0.25em;" |'
    local lowRow = '\n| colspan="3" |<small>'
    if(Weapon.Parts ~= nil) then
        local primeParts = {}
        local foundryTable = '{| class="foundrytable" style="float:left;margin:auto;width:50%;"'
        foundryTable = foundryTable..'\n!colspan=6|[[Foundry|铸造]]需求'
        foundryTable = foundryTable..'\n|-'
        foundryTable = foundryTable..rowStart
        if(Weapon.Credits ~= nil) then
            foundryTable = foundryTable..Icon._Resource("Credits").."<br/>"..Shared.formatnum(Weapon.Credits)
        else
            foundryTable = foundryTable..'N/A'
        end
 
        for i=1, 4 do
            foundryTable = foundryTable..rowStart..buildItemText(Weapon.Parts[i])
            if(Weapon.Parts[i] ~= nil and Weapon.Parts[i].Type == "PrimePart") then
                if(primeParts[Weapon.Parts[i].Name] == nil) then
                    primeParts[Weapon.Parts[i].Name] = 1
                end 
            end
        end
 
        foundryTable = foundryTable..smallPart
        if(Weapon.Time ~= nil) then
            foundryTable = foundryTable.."用时："..Weapon.Time.."小时"
        else
            foundryTable = foundryTable..'N/A'
        end
        foundryTable = foundryTable..'\n|-'..smallPart
        if(Weapon.Rush ~= nil) then
            foundryTable = foundryTable..'加速：'..Icon._Resource("Platinum",nil, 20)..' '..Weapon.Rush
        else
            foundryTable = foundryTable..'N/A'
        end
        foundryTable = foundryTable..'\n|-'..lowRow..Icon._Item("Market", "text", 22)..'价格：'..Icon._Resource("Platinum", nil, 20)..' '
        if(Weapon.MarketCost ~= nil) then
            foundryTable = foundryTable..Weapon.MarketCost
        else
            foundryTable = foundryTable.."N/A"
        end
        foundryTable = foundryTable..'</small>'..lowRow..Icon._Item("Blueprint", "text", 22)..'价格：'..Icon._Resource("Credits", nil, 22)..' '
        if(Weapon.BPCost ~= nil) then
            foundryTable = foundryTable..Shared.formatnum(Weapon.BPCost)
        else
            foundryTable = foundryTable.."N/A"
        end
        foundryTable = foundryTable..'</small>'
 
        if(Shared.tableCount(primeParts) > 0) then
            local itemName = WeaponName
            foundryTable = foundryTable..'\n|-\n| colspan="6" | '
            foundryTable = foundryTable..'<div class="mw-collapsible mw-collapsed" style="width:100%;text-align:center;">'
            foundryTable = foundryTable.."'''部件出处'''"
            foundryTable = foundryTable..'\n<div class="mw-collapsible-content">'
            foundryTable = foundryTable..'\n{| style="width:100%;"\n|-\n|蓝图\n| style="line-height:25px;" |'..Void.item({args = {"PC", itemName, "Blueprint"}})
            for partName, i in Shared.skpairs(primeParts) do
                foundryTable = foundryTable..'\n|-\n|'..Icon._Parts("Prime "..partName)..'\n| style="line-height:25px;" |'..Void.item({args = {"PC", itemName, partName}})
            end
            foundryTable = foundryTable..'\n|}'
            foundryTable = foundryTable..'\n古纪 / 前纪 / 中纪 / 后纪指的是[[虚空遗物]]<br/><i class="fa fa-square text-disable" aria-hidden="true"></i> 已[[Prime宝库|入库]]的遗物 / <i class="fa fa-square text-success" aria-hidden="true"></i> 未入库的遗物<br/><i class="fa fa-square text-primary" aria-hidden="true"></i> [[虚空商人]]携带的遗物</div></div>'
        end
        
		local weapRes = p.getResearch(WeaponName)
		if(weapRes) then
            foundryTable = foundryTable..'\n|-\n! colspan=6| '..p.getLabLink(weapRes.Lab)
            if(weapRes.Affinity ~= nil) then
                foundryTable = foundryTable..' '..Icon._Affinity("Clan").." "..Shared.formatnum(weapRes.Affinity)
            end
            
            foundryTable = foundryTable..'\n|-'..rowStart
            --Adding Credit costs
            if(weapRes.Credits ~= nil) then
                foundryTable = foundryTable..Icon._Resource("Credits").."<br/>"..Shared.formatnum(weapRes.Credits)
            else
                foundryTable = foundryTable..'N/A'
            end
            
            --Adding part costs
            for i=1, 4 do
                foundryTable = foundryTable..rowStart..buildItemText(weapRes.Resources[i], true)
            end
            
            --Adding the time, market, and rush cost
            foundryTable = foundryTable..smallPart
            if(weapRes.Time ~= nil) then
                foundryTable = foundryTable.."时间："..Shared.formatnum(weapRes.Time).."小时"
            else
                foundryTable = foundryTable..'N/A'
            end
            foundryTable = foundryTable..'\n|-'..smallPart
            if(weapRes.Prereq ~= nil) then
                foundryTable = foundryTable..'前提条件：[['..weapRes.Prereq..'|'..trans.toChineseCI(weapRes.Prereq)..']]'
            else
                foundryTable = foundryTable..'前提条件：N/A'
            end
            
            --Adding notes about clan sizes
            foundryTable = foundryTable..'\n|-\n| colspan = 6 |<small>'
            foundryTable = foundryTable..'[[File:LeaderBadgeGhostHolo.png|x26px|link=Clan#Clan Tier|幽灵氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x1</span>]] &nbsp; '
            foundryTable = foundryTable..'[[File:LeaderBadgeShadowHolo.png|x26px|link=Clan#Clan Tier|暗影氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x3</span>]] &nbsp; '
            foundryTable = foundryTable..'[[File:LeaderBadgeStormHolo.png|x26px|link=Clan#Clan Tier|风暴氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x10</span>]] &nbsp; '
            foundryTable = foundryTable..'[[File:LeaderBadgeMountainHolo.png|x26px|link=Clan#Clan Tier|山脉氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x30</span>]] &nbsp; '
            foundryTable = foundryTable..'[[File:LeaderBadgeMoonHolo.png|x26px|link=Clan#Clan Tier|月亮氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x100</span>]]'
            foundryTable = foundryTable..'</small>'
        end
        foundryTable = foundryTable..'\n|}<div style="clear:left; margin:0; padding:0;"></div>'
        
        -- merge SmwBuild and SmwResearch then set smw properties
        local smwTable = {}
        for k,v in pairs(SmwBuild) do
        	smwTable[k] = v
        end
        for k,v in pairs(SmwResearch) do
        	smwTable[k] = v
        end
        local smwResult = mw.smw.set(smwTable)
    	return smwResult and foundryTable or foundryTable .. smwResult.error
    end
end

function p.buildWarframeCostBox(frame)
	local name = frame.args ~= nil and frame.args[1] or frame
	local MainBp = BlueprintData['Suits'][name] or error('p.buildWarframeCostBox(frame): Main blueprint not found in [[Module:Blueprints/data]]')
	local NeuroBp = BlueprintData['Suits'][name..' Neuroptics'] or error('p.buildWarframeCostBox(frame): Neuroptics blueprint not found in [[Module:Blueprints/data]]')
	local ChassisBp = BlueprintData['Suits'][name..' Chassis'] or error('p.buildWarframeCostBox(frame): Chassis blueprint not found in [[Module:Blueprints/data]]')
	local SystemsBp = BlueprintData['Suits'][name..' Systems'] or error('p.buildWarframeCostBox(frame): Systems blueprint not found in [[Module:Blueprints/data]]')

	local rowStart = '\n| rowspan="2" style="height:50px; width:50px;" |'
	local smallPart = '\n| style="text-align:left; padding: 0em 0.25em;" |'
	local lowRow = '\n| colspan="3" |<small>'
	local foundryTable = '{| class="foundrytable" style="float:left;margin:auto"'
	foundryTable = foundryTable..'\n!colspan=6|[[Foundry|铸造]]需求'
	foundryTable = foundryTable..'\n|-'
	foundryTable = foundryTable..rowStart
	--Adding Credit costs
	if (MainBp.Credits ~= nil) then
		foundryTable = foundryTable..Icon._Resource("Credits").."<br/>"..Shared.formatnum(MainBp.Credits)
	else
		foundryTable = foundryTable..'N/A'
	end

	--Adding part costs
	for i = 1, 4 do
		foundryTable = foundryTable..rowStart..buildItemText(MainBp.Parts[i])
	end

	--Adding the time, market, and rush cost
	foundryTable = foundryTable..smallPart
	if (MainBp.Time ~= nil) then
		foundryTable = foundryTable.."时间: "..MainBp.Time..(MainBp.TimeUnit or " 小时")
	else
		foundryTable = foundryTable..'N/A'
	end
	foundryTable = foundryTable..'\n|-'..smallPart
	
	if(MainBp.Rush ~= nil) then
		foundryTable = foundryTable..'加速: '..Icon._Resource("Platinum", nil, 20)..' '..MainBp.Rush
	else
		foundryTable = foundryTable..'N/A'
	end
	foundryTable = foundryTable..'\n|-'..lowRow..Icon._Item("Market", "text", 22)..' 价格: '..Icon._Resource("Platinum", nil, 20)..' '
	
	if (MainBp.MarketCost ~= nil) then
		foundryTable = foundryTable..MainBp.MarketCost
	else
		foundryTable = foundryTable.."N/A"
	end
	
	foundryTable = foundryTable..'</small>'..lowRow..Icon._Item("Blueprint", "text", 22)..' 价格:'
	
	if (MainBp.BPCost ~= nil) then
		foundryTable = foundryTable..Icon._Resource("Credits", nil, 22)
		foundryTable = foundryTable..Shared.formatnum(MainBp.BPCost)
	--This is for Baruuk
	elseif (MainBp.BPStanding ~= nil) then
		foundryTable = foundryTable..Icon._Resource("Standing", nil, 20)
		foundryTable = foundryTable..Shared.formatnum(MainBp.BPStanding)
	else
		foundryTable = foundryTable.."N/A"
	end
	foundryTable = foundryTable..'</small>'

	-- Add Warframe part component costs
	for _, partBp in ipairs({ NeuroBp, ChassisBp, SystemsBp })do
		foundryTable = foundryTable..'\n|-'
		foundryTable = foundryTable..'\n|colspan=6|'.. trans.toChineseCI(partBp.Name)
		foundryTable = foundryTable..'\n|-'

		foundryTable = foundryTable..rowStart
		--Adding Credit costs
		if (partBp.Credits ~= nil) then
			foundryTable = foundryTable..Icon._Resource("Credits").."<br/>"..Shared.formatnum(partBp.Credits)
		else
			foundryTable = foundryTable..'N/A'
		end

		--Adding part costs
		for i = 1, 4 do
			foundryTable = foundryTable..rowStart..buildItemText(partBp.Parts[i])
		end

		--Adding the time, market, and rush cost
		foundryTable = foundryTable..smallPart
		if(partBp.Time ~= nil) then
			foundryTable = foundryTable.."时间: "..partBp.Time.." 小时"
		else
			foundryTable = foundryTable..'N/A'
		end
		foundryTable = foundryTable..'\n|-'..smallPart
		if (partBp.Rush ~= nil) then
			foundryTable = foundryTable..'加速: '..Icon._Resource("Platinum",nil, 20)..' '..partBp.Rush
		else
			foundryTable = foundryTable..'N/A'
		end

		foundryTable = foundryTable
		end

	--Adding Research costs if needed
	local wfRes = p.getResearch(name)
	if (wfRes) then
		local resParts = {[1] = "Blueprint", [2] = "Neuroptics", [3] = "Chassis", [4] = "Systems"}

		foundryTable = foundryTable..'\n|-\n| colspan=6| <div class="mw-collapsible mw-collapsed">'..p.getLabLink(wfRes.Lab)
		foundryTable = foundryTable..'<div class="mw-collapsible-content">\n{| class="foundrytable" style="max-width:100%;"'

		for _, partName in ipairs(resParts) do
			local research
			if (partName ~= "Blueprint") then
				research = p.getResearch(name..' '..partName)
			else
				research = wfRes
			end

			if(research.Resources ~= nil) then
				foundryTable = foundryTable..'\n|colspan=6|'..partName
				if(research.Affinity ~= nil) then
					foundryTable = foundryTable..' • '..Icon._Affinity("Clan").." "..Shared.formatnum(research.Affinity)
				end

				foundryTable = foundryTable..'\n|-'..rowStart
				--Adding Credit costs
				if(research.Credits ~= nil) then
					foundryTable = foundryTable..Icon._Resource("Credits").."<br/>"..Shared.formatnum(research.Credits)
				else
					foundryTable = foundryTable..'N/A'
				end

				--Adding part costs
				for i=1, 4 do
					foundryTable = foundryTable..rowStart..buildItemText(research.Resources[i])
				end

				--Adding the time, market, and rush cost
				foundryTable = foundryTable..smallPart
				if(research.Time ~= nil) then
					foundryTable = foundryTable.."时间: "..Shared.formatnum(research.Time).." 小时"
				else
					foundryTable = foundryTable..'N/A'
				end
				foundryTable = foundryTable..'\n|-'..smallPart
				if(research.Prereq ~= nil) then
					foundryTable = foundryTable..'Prereq: [['..research.Prereq..']]'
				else
					foundryTable = foundryTable..'Prereq: N/A'
				end

				foundryTable = foundryTable..'\n|-'
			end
		end

		--Adding notes about clan sizes
		foundryTable = foundryTable..'\n|-\n| colspan = 6 |<small>'
        foundryTable = foundryTable..'[[File:LeaderBadgeGhostHolo.png|x26px|link=Clan#Clan Tier|幽灵氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x1</span>]] &nbsp; '
        foundryTable = foundryTable..'[[File:LeaderBadgeShadowHolo.png|x26px|link=Clan#Clan Tier|暗影氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x3</span>]] &nbsp; '
        foundryTable = foundryTable..'[[File:LeaderBadgeStormHolo.png|x26px|link=Clan#Clan Tier|风暴氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x10</span>]] &nbsp; '
        foundryTable = foundryTable..'[[File:LeaderBadgeMountainHolo.png|x26px|link=Clan#Clan Tier|山脉氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x30</span>]] &nbsp; '
        foundryTable = foundryTable..'[[File:LeaderBadgeMoonHolo.png|x26px|link=Clan#Clan Tier|月亮氏族]] [[Clan#Clan Tier Multiplier|<span title="Clan Tier Multiplier">x100</span>]]'
        foundryTable = foundryTable..'</small>'

		foundryTable = foundryTable..'\n|}</div></div>'
	end
	
	foundryTable = foundryTable..'\n|}<div style="clear:left; margin:0; padding:0;"></div>[[Category:Automatic Cost Table]]'
	return foundryTable
end

function p.getResearch(itemName)
    return ResearchData["Research"][itemName]
end

return p
