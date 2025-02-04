local ADDON_NAME, ADDON_TABLE = ...

ADDON_TABLE.Locale = {}

local L = ADDON_TABLE.Locale
local GAME_LOCALE = GetLocale()
local Version = GetAddOnMetadata(ADDON_NAME, "Version")

L["Searcher_Title"] = 	"|cffFF8080Trans|cff80ff80mog|cff8080ffTracker|r"
L["Searcher_Desc"] = 	"Search for Transmog Visuals"
L["Header_Title"] = 	format("|cffFF8080Trans|cff80ff80mog|cff8080ffTracker|r (%s) - search criteria", Version)
L["Header_Desc"] = 		"Scan: unknown or partially known Transmog Visuals (based on the \"General\" Searcher)"
L["Label_HidePartial"] = "Ignore items whose \nVisualsare unlocked \nby other known items"
-- L["Label_HidePartial_desc"] = "Ignore items whose Visuals are \nunlocked by other known items."


-- if true then return end -- debug
if GAME_LOCALE == "deDE" then
	-- L["Searcher_Title"] = 	"TransmogTracker"
	L["Searcher_Desc"] = 	"Suche nach Transmog Aussehen"
	L["Header_Title"] = 	format("|cffFF8080Trans|cff80ff80mog|cff8080ffTracker|r (%s) - Suchkriterium", Version)
	L["Header_Desc"] = 		"Scanne: nicht oder teilweise bekannte Transmog-Aussehen (basiert auf \"General\" Searcher)"
	L["Label_HidePartial"] = "Ignoriere Items, \nderen Aussehen über \nandere Items bereits \nfreigeschaltet sind."
	-- L["Label_HidePartial_desc"] = "Ignoriere Items, deren Aussehen über \nandere Items bereits freigeschaltet sind."

end

AucAdvanced.RegisterRevision("$URL: https://github.com/telkar-rg/wow-Auc-Searcher-DMF/blob/1.0/Auc-Searcher-TMT/Auc-Searcher-TMT-Locale.lua $", "$Rev: 10 $")
