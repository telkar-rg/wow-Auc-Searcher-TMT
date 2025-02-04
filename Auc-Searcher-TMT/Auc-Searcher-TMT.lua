local ADDON_NAME, ADDON_TABLE = ...

-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Transmog")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "|cffFF8080T|cff80ff80M|cff8080ffT|r"

local L = ADDON_TABLE.Locale
if not L then
	print(ADDON_NAME,"ERROR with Locale")
	return
end

local TMT = _G["TransmogTracker"]
if not TMT then return end



function private.getTypes()
	if not private.typetable then
		private.typetable = {GetAuctionItemClasses()}
		private.typetable = {private.typetable[1], private.typetable[2]} 	-- we only need "weapons" and "armor"
		table.insert(private.typetable,1, QUICKBUTTON_NAME_EVERYTHING)
	end
	return private.typetable
end

function private.getSubTypes()
	local subtypetable, typenumber
	local typename = get("generalTMT.type")
	local typetable = private.getTypes()
	if typename ~= "All" then
		for i, j in pairs(typetable) do
			if j == typename then
				typenumber = i
				break
			end
		end
	end
	if typenumber then
		subtypetable = {GetAuctionItemSubClasses(typenumber-1)}-- subtract 1 because 1 is the "All" category
		
		if typenumber == 3 then 	-- if armor, then only wearables
			subtypetable[7] = nil
			subtypetable[8] = nil
			subtypetable[9] = nil
			subtypetable[10] = nil
		end
		table.insert(subtypetable, 1, QUICKBUTTON_NAME_EVERYTHING)
	else
		subtypetable = {[1]=QUICKBUTTON_NAME_EVERYTHING}
	end
	return subtypetable
end

function private.getQuality()
	local t = {{-1, QUICKBUTTON_NAME_EVERYTHING}}
	for i = 0, 6 do
	  local r, g, b, hex = GetItemQualityColor(i);
	  -- print(i, hex, getglobal("ITEM_QUALITY" .. i .. "_DESC"), string.gsub(hex,"|","!"));
	  table.insert(t, hex..getglobal("ITEM_QUALITY" .. i .. "_DESC").."|r" )
	end
	
	return t
	
	-- return {
			-- {-1, "All"},
			-- {0, "Poor"},
			-- {1, "Common"},
			-- {2, "Uncommon"},
			-- {3, "Rare"},
			-- {4, "Epic"},
			-- {5, "Legendary"},
			-- {6, "Artifact"},
		-- }
end

function private.getTimeLeft()
	return {
			{0, QUICKBUTTON_NAME_EVERYTHING},
			{1, format("< %s", SecondsToTime(30*60))},
			{2, SecondsToTime(2*60*60)},
			{3, AUCTION_DURATION_ONE},
			{4, AUCTION_DURATION_THREE},
		}
end

-- Set our defaults
default("generalTMT.name", "")
default("generalTMT.name.exact", false)
default("generalTMT.name.regexp", false)
default("generalTMT.name.invert", false)
default("generalTMT.type", "All")
default("generalTMT.subtype", "All")
default("generalTMT.quality", -1)
default("generalTMT.timeleft", 0)
default("generalTMT.ilevel.min", 0)
default("generalTMT.ilevel.max", 300)
default("generalTMT.ulevel.min", 0)
default("generalTMT.ulevel.max", 80)
default("generalTMT.seller", "")
default("generalTMT.seller.exact", false)
default("generalTMT.seller.regexp", false)
default("generalTMT.seller.invert", false)
default("generalTMT.minbid", 0)
default("generalTMT.minbuy", 0)
default("generalTMT.maxbid", 999999999)
default("generalTMT.maxbuy", 999999999)
default("generalTMT.hidePartial", false)

-- This function is automatically called when we need to create our search generals
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	-- Add the help
	gui:AddSearcher(L["Searcher_Title"], L["Searcher_Desc"], 100)

	-- gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,      L["Header_Title"])
	gui:AddControl(id, "Label",  colPos, 0, nil, L["Header_Desc"])
	gui:GetLast(id).clearance = 10;

	local last = gui:GetLast(id)
	gui:SetControlWidth(0.35)
	gui:AddControl(id, "Text",       0,   1, "generalTMT.name", "Item name")
	local cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.11, 0, "generalTMT.name.exact", "Exact")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.21, 0, "generalTMT.name.regexp", "Regexp")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.31, 0, "generalTMT.name.invert", "Invert")

	-- gui:SetLast(id, cont)

	-- last = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:SetControlWidth(0.35)
	gui:AddControl(id, "Text",       0.45,   1, "generalTMT.seller", "Seller name")
	cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.57, 0, "generalTMT.seller.exact", "Exact")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.67, 0, "generalTMT.seller.regexp", "Regexp")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.77, 0, "generalTMT.seller.invert", "Invert")
	
	
	
	
	

	gui:SetLast(id, cont)
	last = cont

	gui:AddControl(id, "Note",       0.0, 1, 100, 14, "Type:")
	gui:AddControl(id, "Selectbox",   0.0, 1, private.getTypes, "generalTMT.type", "ItemType")
	gui:SetLast(id, last)
	gui:AddControl(id, "Note",       0.3, 1, 100, 14, "SubType:")
	gui:AddControl(id, "Selectbox",   0.3, 1, private.getSubTypes, "generalTMT.subtype", "ItemSubType")
	
	
	cont = gui:GetLast(id)
	gui:SetLast(id, cont)
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.57, 0, "generalTMT.hidePartial", L["Label_HidePartial"])

	last = cont
	gui:SetLast(id, last)
	gui:AddControl(id, "Note",       0.0, 1, 100, 14, QUALITY..":")
	gui:AddControl(id, "Selectbox",   0.0, 1, private.getQuality(), "generalTMT.quality", "ItemQuality")
	gui:SetLast(id, last)
	gui:AddControl(id, "Note",       0.3, 1, 100, 14, CLOSES_IN..":")
	gui:AddControl(id, "Selectbox",  0.3, 1, private.getTimeLeft(), "generalTMT.timeleft", "TimeLeft")

	last = gui:GetLast(id)
	gui:SetControlWidth(0.25)
	gui:AddControl(id, "NumeriSlider",     0,   1, "generalTMT.ilevel.min", 0, 300, 1, "Min item level")
	gui:SetControlWidth(0.25)
	gui:AddControl(id, "NumeriSlider",     0,   1, "generalTMT.ilevel.max", 0, 300, 1, "Max item level")
	cont = gui:GetLast(id)

	gui:SetLast(id, last)
	gui:SetControlWidth(0.2)
	gui:AddControl(id, "NumeriSlider",     0.5, 0, "generalTMT.ulevel.min", 0, 80, 1, "Min user level")
	gui:SetControlWidth(0.2)
	gui:AddControl(id, "NumeriSlider",     0.5, 0, "generalTMT.ulevel.max", 0, 80, 1, "Max user level")


	gui:SetLast(id, cont)
	-- gui:AddControl(id, "MoneyFramePinned", 0, 1, "generalTMT.minbid", 0, 999999999, "Minimum Bid")
	gui:AddControl(id, "MoneyFramePinned", 0, 1, "generalTMT.minbid", 0, 999999999, format("%s %s", MINIMUM, BID) )
	gui:SetLast(id, cont)
	gui:AddControl(id, "MoneyFramePinned", 0.45, 1, "generalTMT.minbuy", 0, 999999999, format("%s %s", MINIMUM, BUYOUT_COST) )
	last = gui:GetLast(id)
	gui:AddControl(id, "MoneyFramePinned", 0, 1, "generalTMT.maxbid", 0, 999999999, format("%s %s", MAXIMUM, BID) )
	gui:SetLast(id, last)
	gui:AddControl(id, "MoneyFramePinned", 0.45, 1, "generalTMT.maxbuy", 0, 999999999, format("%s %s", MAXIMUM, BUYOUT_COST) )
end

function lib.Search(item)
	private.debug = ""
	if private.NameSearch("name", item[Const.NAME])
			and private.TypeSearch(item[Const.ITYPE], item[Const.ISUB])
			and private.TimeSearch(item[Const.TLEFT])
			and private.QualitySearch(item[Const.QUALITY])
			and private.LevelSearch("ilevel", item[Const.ILEVEL])
			and private.LevelSearch("ulevel", item[Const.ULEVEL])
			and private.NameSearch("seller", item[Const.SELLER])
			and private.PriceSearch("Bid", item[Const.PRICE])
			and private.PriceSearch("Buy", item[Const.BUYOUT]) then
		
		-- if item[Const.ITYPE] > 2 then return false, "nope" end
		if not item[Const.IEQUIP] then return false, "nope" end
		if item[Const.IEQUIP] == 2 then return false, "nope" end
		if item[Const.IEQUIP] == 11 then return false, "nope" end
		if item[Const.IEQUIP] == 12 then return false, "nope" end
		if item[Const.IEQUIP] == 18 then return false, "nope" end
		if item[Const.IEQUIP] == 24 then return false, "nope" end
		
		if item[Const.ITEMID] == 49916 then return false, "nope" end
		
		local itemid = item[Const.ITEMID];
		
		local known = TransmogTracker:checkItemId(itemId)
		if known then print(-1) return false, "nope" end
		
		local knownOther = TransmogTracker:checkUniqueId(itemId)
		if knownOther  then
			if get("generalTMT.hidePartial") then 
				print(-2)
				return false, "nope"
			end
			
			print(1,item[Const.LINK])
			return "1"
		end
		
			print(2,item[Const.LINK], TransmogTracker:checkItemId(itemId), itemid, type(itemid))
		return "2"
	else
		return false, private.debug
	end
end

function private.LevelSearch(levelType, itemLevel)
	local min = get("generalTMT."..levelType..".min")
	local max = get("generalTMT."..levelType..".max")

	if itemLevel < min then
		private.debug = levelType.." too low"
		return false
	end
	if itemLevel > max then
		private.debug = levelType.." too high"
		return false
	end
	return true
end

function private.NameSearch(nametype,itemName)
	local name = get("generalTMT."..nametype)

	-- If there's no name, then this matches
	if not name or name == "" then
		return true
	end

	-- Lowercase the input
	name = name:lower()
	itemName = itemName:lower()

	-- Get the matching options
	local nameExact = get("generalTMT."..nametype..".exact")
	local nameRegexp = get("generalTMT."..nametype..".regexp")
	local nameInvert = get("generalTMT."..nametype..".invert")

	-- if we need to make a non-regexp, exact match:
	if nameExact and not nameRegexp then
		-- If the name matches or we are inverted
		if name == itemName and not nameInvert then
			return true
		elseif name ~= itemName and nameInvert then
			return true
		end
		private.debug = nametype.." is not exact match"
		return false
	end

	local plain, text
	text = name
	if not nameRegexp then
		plain = 1
	elseif nameExact then
		text = "^"..name.."$"
	end

	local matches = itemName:find(text, 1, plain)
	if matches and not nameInvert then
		return true
	elseif not matches and nameInvert then
		return true
	end
	private.debug = nametype.." does not match critia"
	return false
end

function private.TypeSearch(itype, isubtype)
	local searchtype = get("generalTMT.type")
	if searchtype == "All" then
		return true
	elseif searchtype == itype then
		local searchsubtype = get("generalTMT.subtype")
		if searchsubtype == "All" then
			return true
		elseif searchsubtype == isubtype then
			return true
		else
			private.debug = "Wrong Subtype"
			return false
		end
	else
		private.debug = "Wrong Type"
		return false
	end
end

function private.TimeSearch(iTleft)
	local tleft = get("generalTMT.timeleft")
	if tleft == 0 then
		return true
	elseif tleft == iTleft then
		return true
	else
		private.debug = "Time left wrong"
		return false
	end
end

function private.QualitySearch(iqual)
	local quality = get("generalTMT.quality")
	if quality == -1 then
		return true
	elseif quality == iqual then
		return true
	else
		private.debug = "Wrong Quality"
		return false
	end
end

function private.PriceSearch(buybid, price)
	local minprice, maxprice
	if buybid == "Bid" then
		minprice = get("generalTMT.minbid")
		maxprice = get("generalTMT.maxbid")
	else
		minprice = get("generalTMT.minbuy")
		maxprice = get("generalTMT.maxbuy")
	end
	if (price <= maxprice) and (price >= minprice) then
		return true
	elseif price < minprice then
		private.debug = buybid.." price too low"
	else
		private.debug = buybid.." price too high"
	end
	return false
end

AucAdvanced.RegisterRevision("$URL: https://github.com/telkar-rg/wow-Auc-Searcher-DMF/blob/1.0/Auc-Searcher-TMT/Auc-Searcher-TMT-Locale.lua $", "$Rev: 10 $")
