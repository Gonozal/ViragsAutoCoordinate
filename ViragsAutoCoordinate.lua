-----------------------------------------------------------------------------------------------
-- Client Lua Script for ViragsAutoCoordinate
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinate Module Definition
-----------------------------------------------------------------------------------------------



------------!-------------------------------------------------------------------!-------
------------!-- WARNING! THE CODE IS VERY MESSY! DON'T HAVE TIME TO REFACTOR! --!-------
------------!-------------------------------------------------------------------!-------

--TODO refactor code



local ViragsAutoCoordinate = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
local PATTERN_LIST_SMALL = 2
local PATTERN_LIST_BIG = 1
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local SavedConfig = {}
local knTopLevelHeight = 0
local listItemIndex 
local listItemParent 
local selectedListItem
local itemHeight = 0
local IsCraftingQue = false
local IsCraftingQueItem = false
local currentItemIndex
local tCurrentSchematic

local tCurrentSchematicId

local bHasEnoughMaterials

local tSuccessChance

local targetItemLooted

local additivesPathFailCounter = 0

local tWndCatalysts = {}
local wndSize = 1

local tMatches
local tPaths
local tIds
local tCurrentCraftResults
local tCraftResults
local tAllowedAdditives

local tick = 0
local elapsed = 0

local postCraftIteration = 0

local iteration = 0

local tListAdditives

local nMaxAdditives = 3

local doAdditives = false
local craftingStopped = true
local readyToCraft = false
local craftingStarted = false
local craftingFinished = false
local postCraftCounter = 0	

local onCraftedItemTimer

local wndNames = { {patternList = "ItemPatterns" ,listItem = "PatternListItem"},
 { patternList = "ItemPatternsMini" , listItem = "PatternListItemMini"} }

local karEvalColors =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
}

local ktItemRarityToBorderSprite =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Silver",
	[Item.CodeEnumItemQuality.Average] 			= "CRB_Tooltips:sprTooltip_SquareFrame_White",
	[Item.CodeEnumItemQuality.Good] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Green",
	[Item.CodeEnumItemQuality.Excellent] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Blue",
	[Item.CodeEnumItemQuality.Superb] 			= "CRB_Tooltips:sprTooltip_SquareFrame_Purple",
	[Item.CodeEnumItemQuality.Legendary] 		= "CRB_Tooltips:sprTooltip_SquareFrame_Orange",
	[Item.CodeEnumItemQuality.Artifact]		 	= "CRB_Tooltips:sprTooltip_SquareFrame_Pink",
}

local ktstrAxisToIcon =
{
	[CraftingLib.CodeEnumTradeskill.Architect] =
	{
		"sprCoord_Icon_ArchitectFunction",
		"sprCoord_Icon_ArchitectSynthetic",
		"sprCoord_Icon_ArchitectForm",
		"sprCoord_Icon_ArchitectOrganic",
		"sprCoord_Icon_NorthEastArrow",
		"sprCoord_Icon_SouthEastArrow",
		"sprCoord_Icon_NorthWestArrow",
		"sprCoord_Icon_SouthWestArrow",
	},
	[CraftingLib.CodeEnumTradeskill.Augmentor] =
	{
		"sprCoord_Icon_TechWater",
		"sprCoord_Icon_TechWind",
		"sprCoord_Icon_TechFire",
		"sprCoord_Icon_TechEarth",
		"sprCoord_Icon_NorthEastArrow",
		"sprCoord_Icon_SouthEastArrow",
		"sprCoord_Icon_NorthWestArrow",
		"sprCoord_Icon_SouthWestArrow",
	},
	[CraftingLib.CodeEnumTradeskill.Cooking] =
	{
		"sprCoord_Icon_CookingSpicy",
		"sprCoord_Icon_CookingSavory",
		"sprCoord_Icon_CookingSour",
		"sprCoord_Icon_CookingSweet",
		"sprCoord_Icon_NorthEastArrow",
		"sprCoord_Icon_SouthEastArrow",
		"sprCoord_Icon_NorthWestArrow",
		"sprCoord_Icon_SouthWestArrow",
	},
}

local kTradeskills =
{
	[CraftingLib.CodeEnumTradeskill.Survivalist]	=	{strName = "Survivalist",	strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Survivalist"},
	[CraftingLib.CodeEnumTradeskill.Architect]		=	{strName = "Architect",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Architect"},
	[CraftingLib.CodeEnumTradeskill.Fishing]		=	{strName = "Fishing",		strIcon = ""},
	[CraftingLib.CodeEnumTradeskill.Mining]			=	{strName = "Mining",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Miner"},
	[CraftingLib.CodeEnumTradeskill.Relic_Hunter]	=	{strName = "Relic Hunter",	strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_RelicHunter"},
	[CraftingLib.CodeEnumTradeskill.Cooking]		=	{strName = "Cooking",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Cooking"},
	[CraftingLib.CodeEnumTradeskill.Outfitter]		=	{strName = "Outfitter",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Outfitter"},
	[CraftingLib.CodeEnumTradeskill.Armorer]		=	{strName = "Armorer",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Armorer"},
	[CraftingLib.CodeEnumTradeskill.Farmer]			=	{strName = "Farmer",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Farmer"},
	[CraftingLib.CodeEnumTradeskill.Weaponsmith]	=	{strName = "Weaponsmith",	strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_WeaponCrafting"},
	[CraftingLib.CodeEnumTradeskill.Tailor]			=	{strName = "Tailor",		strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Tailor"},
	[CraftingLib.CodeEnumTradeskill.Runecrafting]	=	{strName = "Runecrafting",	strIcon = ""},
	[CraftingLib.CodeEnumTradeskill.Augmentor]		=	{strName = "Technologist",	strIcon = "IconSprites:Icon_Achievement_UI_Tradeskills_Technologist"},
}
local kTradeskillTiers =
{
	[CraftingLib.CodeEnumTradeskillTier.Zero]			=	"-",
	[CraftingLib.CodeEnumTradeskillTier.Apprentice]		=	"Apprentice",
	[CraftingLib.CodeEnumTradeskillTier.Artisan]		=	"Artisan",
	[CraftingLib.CodeEnumTradeskillTier.Expert]			=	"Expert",
	[CraftingLib.CodeEnumTradeskillTier.GrandMaster]	=	"Grandmaster",
	[CraftingLib.CodeEnumTradeskillTier.Journeyman]		=	"Journeyman",
	[CraftingLib.CodeEnumTradeskillTier.Master]			=	"Master",
	[CraftingLib.CodeEnumTradeskillTier.Novice]			=	"Novice",
}

local ktAdditiveAxisToAllowed =
{
	{true,true,true,false,false},	-- East
	{true,true,false,true,false},	-- North
	{true,false,true,true,false},	-- West
	{false,true,true,true,false},	-- South
	{true,true,false,false,true},	-- North East
	{false,true,true,false,true},	-- South East
	{true,false,false,true,true},	-- North West
	{false,false,true,true,true},	-- South West
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------


function ViragsAutoCoordinate:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function ViragsAutoCoordinate:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Lib:ApolloFixes-1.0"
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinate OnLoad
-----------------------------------------------------------------------------------------------
function ViragsAutoCoordinate:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("ViragsAutoCoordinate.xml")
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ViragsAutoCoordinateForm", nil, self)
	if self.wndMain == nil then
		Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
		return
	end
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	Apollo.RegisterEventHandler("NextFrame", "OnNextFrame", self)
	
	self.timers     = {
		additives   = { elapsed = 0, divisor = 1000,    func = "OnTimerAdditives", time = 0.2}
	}
end

function ViragsAutoCoordinate:OnNextFrame()
    self:UpdateTimers()
end

function ViragsAutoCoordinate:UpdateTimers()
    -- Get the amount of time since last update
    elapsed = (os.clock() - tick)

    for name, timer in pairs(self.timers) do
		
		-- Update the elapsed time for the timer.
		timer.elapsed = timer.elapsed + elapsed
		-- Check if its time to fire our timer
		if timer.elapsed >= timer.time then
			-- Make sure our func exists before attempting to fire it
			if self[timer.func] and type(self[timer.func] == "function") then
				-- Fire the timers func
				self[timer.func](self, elapsed, "t")
			end
			-- Reset the timers elapsed time
			timer.elapsed = 0
		end
    end

    -- Save the last tick.
    tick = os.clock()
end

function ViragsAutoCoordinate:OnTimerAdditives(elapsed, somethingElse)
	if craftingStopped then 
		self.Stop = true
		doAdditives = false
		craftingStopped = true
		readyToCraft = false
		craftingStarted = false
		craftingFinished = false
		return
	end
	
	if doAdditives and not GameLib.GetPlayerUnit():IsCasting() then
		if not CraftingLib.GetCurrentCraft() then 
			return
		end
		local idSchematic = tCurrentSchematicId
		local tSchematicInfo = CraftingLib.GetSchematicInfo(idSchematic)
		
		local nAdditiveCount = CraftingLib.GetCurrentCraft().nAdditiveCount
		tListAdditives = CraftingLib.GetAvailableAdditives(tSchematicInfo.eTradeskillId, idSchematic)
		local bComplete = false
		local idx
		idx = (1 + nAdditiveCount)
		self:CompleteAdditiveSub(idx, nAdditiveCount, tListAdditives, bComplete)
		iteration = iteration + 1
	elseif readyToCraft and not GameLib.GetPlayerUnit():IsCasting() then
		self:CompleteCrafting()	
	elseif craftingStarted  then
		if not GameLib.GetPlayerUnit():IsCasting() then
			craftingStarted = false
			craftingFinished = true
		end
	elseif craftingFinished then
		if  postCraftCounter < 2 and not GameLib.GetPlayerUnit():IsCasting() then
			postCraftCounter = postCraftCounter + 1
		elseif postCraftCounter == 2 and not GameLib.GetPlayerUnit():IsCasting() then
			self:OnCraftingComplete()
			postCraftCounter = postCraftCounter + 1
		elseif postCraftCounter == 3 and not GameLib.GetPlayerUnit():IsCasting() then
			postCraftCounter = 0
			self:OnCraftingAutoResume()
		end
	end
end

-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinate OnDocLoaded
-----------------------------------------------------------------------------------------------
function ViragsAutoCoordinate:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    
		
	    self.wndMain:Show(false, true)
		Apollo.RegisterEventHandler("GenericEvent_StartCraftingGrid", "OnGenericEvent_StartCraftingGrid", self)
		Apollo.RegisterEventHandler("CraftingInterrupted",	"OnViragsAutoCoordinateStop", self)
		Apollo.RegisterEventHandler("GenericEvent_InitializeSchematicsTree", "OnInitializeSchematicsTree", self)
		Apollo.RegisterEventHandler("ObscuredAddonVisible", "OnObscuredAddonVisible", self)
		Apollo.RegisterEventHandler("CloseVendorWindow",	"AddPattern", self)
		Apollo.RegisterEventHandler("AlwaysShowTradeskills", "OnAlwaysShowTradeskills", self)
		Apollo.RegisterEventHandler("ChannelUpdate_Crafting", "OnCraftedItem", self)
		Apollo.RegisterEventHandler("ChannelUpdate_Loot", "OnLootItem", self)
		bHasEnoughMaterials = false
		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		self.Count = 0
		currentItemIndex = 0
		self.Stop = false 
		self.wndItems = self.wndMain:FindChild("ItemsNumber")
		targetItemLooted = false
		tMatches = {}
		tCraftResults = {}
	 	tAllowedAdditives = {}
		if tSuccessChance == nil then tSuccessChance = {} end

		local wndAvailableCatalysts = self.wndMain:FindChild("AvailableCatalysts")
		for id = 1, 4 do
			tWndCatalysts[id] = wndAvailableCatalysts:FindChild("Catalyst" .. id)
		end
 		
		-- Do additional Addon initialization here
	end
end

--------------------EVENTS BEGIN--------------------

function ViragsAutoCoordinate:OnGenericEvent_StartCraftingGrid(idSchematic)
	GameLib:Disembark()
	Apollo.GetAddon("CraftingGrid").OnCloseBtn = self.OnGridCloseBtn
	self:OnViragsAutoCoordinateOn()
	self:AttachCoordinateBoardOverlay()
end

function ViragsAutoCoordinate:OnDisembarkV()
	self.disembarkTimer = ApolloTimer.Create(3.0, false, "OnDisembarkV", self)
	self.disembarkTimer:Start()

end
function ViragsAutoCoordinate:OnInitializeSchematicsTree()	
	--self.wndMain:Show(true)
	--self.wndMain:ToFront()
	self.schemTimer = ApolloTimer.Create(0.2, false, "OnInitializeSchematicsTreeWait", self)
	--self:AttachtTradeskillsOverlay()
	--self:AddPattern()
end

function ViragsAutoCoordinate:OnInitializeSchematicsTreeWait()	
	self:AttachtTradeskillsOverlay()
	self:AddPattern()
end

function ViragsAutoCoordinate:OnCraftedItem(eType, tEventArgs)
	if  (IsCraftingQue == true or IsCraftingQueItem == true and self.wndMain:IsShown()) then
	--self:ViragsPrint("OnCraftedItem, " .. tEventArgs.itemNew:GetName() .. ", " .. tCurrentSchematic.strName)
		if  (tCurrentSchematic ~= nil and tEventArgs.itemNew ~= nil) and tEventArgs.itemNew:GetName() == tCurrentSchematic.strName then
			--self:ViragsPrint(tEventArgs.itemNew:GetName() .. ", " .. tCurrentSchematic.strName)
			if self.wndMain and self.wndMain:FindChild("SuccessCheckBox"):IsChecked() then
				targetItemLooted = true
			end
			local nS = tSuccessChance[tCurrentSchematic.strName].nSuccessCrafts
			tSuccessChance[tCurrentSchematic.strName].nSuccessCrafts = nS + 1
			tCurrentCraftResults.bSuccess = true
			
			
		end
		craftingStarted = false
		craftingFinished = true
	end
end

function ViragsAutoCoordinate:ViragsPrint(msg)
    if msg == nil then return end
    ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_System, msg, "Virag's Auto Coordinate")
end

--------------------EVENTS END--------------------

-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinate Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function ViragsAutoCoordinate:OnToggleAutoCoordinate()
	self.wndMain:FindChild("PatternsButton"):SetCheck(true)
	self:OnPatternsButtonCheck()
	if self.bIsResultsOpen == true then self:OnShowCraftResults() end
	if self.wndMain:IsVisible() then	
		self.wndMain:Show(false)
	else 
		self.wndMain:ToFront()
		self.wndMain:Show(true)
	end
end



function ViragsAutoCoordinate:OnViragsAutoCoordinateOn()
	self.wndMain:Invoke()
	self.wndMain:Show(true)
	
    --Apollo.GetAddon("CraftingGrid").OnAdditiveClick= self.OnAdditiveClick;
	Apollo.GetAddon("CraftingGrid").OnPreviewStartCraftBtn = self.OnPreviewStartCraftBtn;
end

local wndHandlerLocal
local wndControlLocal


function ViragsAutoCoordinate:OnPreviewStartCraftBtn(wndHandler, wndControl) -- PreviewStartCraftBtn, data is idSchematic
	local aVirags = Apollo.GetAddon("ViragsAutoCoordinate")
	local tCatalyst = aVirags.tCurrentCatalyst
	local idSchematic = wndHandler:GetData()
	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	wndHandlerLocal = wndHandler
	wndControlLocal = wndControl
	
	if not tCurrentCraft or tCurrentCraft.nSchematicId == 0 then -- Start if it hasn't started already (i.e. just clicking craft button)
		local IsChecked = aVirags.wndMain:FindChild("CatalystsCheckBox"):IsChecked()
		if IsChecked and aVirags.isSubSchematic == true and tCatalyst~= nil and tCatalyst:GetBackpackCount() > 0 then		
			CraftingLib.CraftItem(idSchematic, tCatalyst) 
		else
			CraftingLib.CraftItem(idSchematic, self.wndMain:FindChild("CatalystGlobalList"):GetData()) 
		end
	end

	-- We need a complete redraw for catalysts
	if self.wndMain:FindChild("CatalystGlobalList"):GetData() then
		self.bFullDestroyNeeded = true
	end
	Event_FireGenericEvent("GenericEvent_StartCraftingGrid", idSchematic)

end


function ViragsAutoCoordinate:OnViragsAutoCoordinateStop()
	self.Stop = true
	doAdditives = false
	craftingStopped = true
	readyToCraft = false
	craftingStarted = false
	craftingFinished = false
	postCraftCounter = 0	
	
	--IsCraftingQue = false
	--IsCraftingQueItem = false
	if self.timer == nil then
		return
	end
    --self.timer:Stop()
	
end



function ViragsAutoCoordinate:StartCrafting()
    SocketRecording = false
	self.Stop = false
	craftingStopped = false

	self.wndMain:FindChild("SoketsNumber"):SetText(tCurrentSchematic.strName)
	local carbineCraft = Apollo.GetAddon("CraftingGrid")
	local wndCarbineCraft = carbineCraft.wndMain		
	local carbineStartCraftButton
	
	if self.Count == 0 then
   		self:ViragsPrint("Items number is 0.")
		return
	end
	
	if GameLib.GetEmptyInventorySlots() == 0 then
		self:ViragsPrint("Inventory is full, crafting stopped.")
		doAdditives = false
		return
	end
	
	if wndCarbineCraft ~= nil then
		if wndCarbineCraft:FindChild("BGNoMaterialsBlocker"):IsShown() then
			self:ViragsPrint("No materials, crafting stopped.")
			doAdditives = false
			return
		end
		if not tCurrentSchematic.bIsAutoCraft then
			if(wndCarbineCraft:FindChild("BGPreviewOnlyBlocker"):IsShown()) then
				carbineStartCraftButton = wndCarbineCraft:FindChild("PreviewStartCraftBtn")	
				carbineCraft:OnPreviewStartCraftBtn(carbineStartCraftButton , carbineStartCraftButton )
			else
				self.StartCraftingTimer = ApolloTimer.Create(0.25, false, "StartCrafting", self)
			end
		end
	end
	
	tCurrentCraftResults = {}
	tMatches = {}
    self:AddAdditives()
	--self:CompleteCrafting()
end



function ViragsAutoCoordinate:AddAdditives() 
	local carbineCraft = Apollo.GetAddon("CraftingGrid")
	local idSchematic = tCurrentSchematicId
	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	local tSchematicInfo = CraftingLib.GetSchematicInfo(idSchematic)
	local bCurrentCraftStarted = tCurrentCraft and tCurrentCraft.nSchematicId == idSchematic
	local nTargetX = 0
	local nTargetY = 0
	local fRadius = 0
	nMaxAdditives = tSchematicInfo.nMaxAdditives
	doAdditives = false
	readyToCraft = false
	
	for idx, tCurrSubRecipe in pairs(tSchematicInfo.tSubRecipes) do
		--local bHitThisSubSchematic = bCurrentCraftStarted and tCurrentCraft.nSubSchematicId == tCurrSubRecipe.nSchematicId
		local item = tCurrSubRecipe.itemOutput

	
		--self:ViragsPrint (tCurrentSchematic.strName .. " " ..  tCurrSubRecipe.strName)
		if tCurrentSchematic.strName == tCurrSubRecipe.strName then
			nTargetX = tCurrSubRecipe.fVectorX 
			nTargetY = tCurrSubRecipe.fVectorY
			fRadius = tCurrSubRecipe.fRadius
			tCurrentCraftResults.strName = tCurrSubRecipe.strName
		end
	end

	--tCurrentCraft.nAdditiveCount < tSchematicInfo.nMaxAdditives
	tMatches[1] = { x = 0, y = 0, xT = nTargetX, yT = nTargetY, fT = fRadius}
	tListAdditives = CraftingLib.GetAvailableAdditives(tSchematicInfo.eTradeskillId, idSchematic)
	
	
	if fRadius > 0 then
		if tCurrentCraft == nil then return end
		doAdditives = true
	else 
		readyToCraft = true
	end
	
end

local tMCurrentCraft

function ViragsAutoCoordinate:squareDist(pos1, pos2)
	return (pos1.fVectorX - pos2.fVectorX)^2 + (pos1.fVectorY - pos2.fVectorY)^2
end

function ViragsAutoCoordinate:addAdditive(currentPos, additive)
	return {fVectorX = currentPos.fVectorX + additive.fVectorX, fVectorY = currentPos.fVectorY + additive.fVectorY}
end

function ViragsAutoCoordinate:filterAdditives(targetPos, additives)
	local targetDistance = targetPos.fVectorX ^ 2 + targetPos.fVectorY ^ 2
	local returnList = {}
	for i, additive in ipairs(additives) do
		if (additive.fVectorX^2 + additive.fVectorY^2) * 10 > targetDistance then
			if math.abs(targetPos.fVectorX) > math.abs(targetPos.fVectorY) then
				if additive.fVectorX * targetPos.fVectorX > 0 and additive.fVectorY * targetPos.fVectorY >= 0 then
					returnList[i] = additive
				else
					returnList[i] = false
				end
			else
				if additive.fVectorX * targetPos.fVectorX >= 0 and additive.fVectorY * targetPos.fVectorY > 0 then
					returnList[i] = additive
				else
					returnList[i] = false
				end
			end
		end
	end
	
	return returnList
end

 function  ViragsAutoCoordinate:compact(tbl)
     local newtbl= {}
     for i,v in pairs(tbl) do
         if v ~= false then
			newtbl[#newtbl+1]=i
         end
     end
     return newtbl
 end
 
 function  ViragsAutoCoordinate:table_contains(tbl, element)
  for _, value in pairs(tbl) do
    if value == element then
      return true
    end
  end
  return false
end

function ViragsAutoCoordinate:findPathStep(stepNum, maxStepNum, currentPos, targetPos, additives, chosenAdditives, reducedAdditiveList)
	local filteredAdditiveList
	local validPaths = {}
	local futureAdditives
	local additiveRadius
	local currentDist = self:squareDist(currentPos, targetPos)
	local futureDist
	local isNoPermutation
	if stepNum >= maxStepNum then 
		return false
	end
	
	if(stepNum == 0) then
		filteredAdditiveList = self:filterAdditives(targetPos, additives)
		reducedAdditiveList  = self:compact(filteredAdditiveList)
	else
		filteredAdditiveList = additives
	end
	
	
	for i, additive in ipairs(filteredAdditiveList) do
		futureAdditives = {}
		isNoPermutation = 	chosenAdditives[#chosenAdditives] == nil or (
								(stepNum <= 1 or i >= chosenAdditives[#chosenAdditives]) and 
								(stepNum ~= 1 or #chosenAdditives == 0 or 
									i >= chosenAdditives[#chosenAdditives] or 
									not self:table_contains(reducedAdditiveList, chosenAdditives[#chosenAdditives])
								)
							)
							
		if additive ~= false and isNoPermutation then
			for n, v in ipairs(chosenAdditives) do
				futureAdditives[#futureAdditives+1] = v
			end
			futureAdditives[#futureAdditives+1] = i
			additiveRadius = 0
			local newPos = self:addAdditive(currentPos, additive)
			futureDist = self:squareDist(newPos, targetPos)
			
			if futureDist < targetPos.radius^2 then
				for n, currentAdditive in ipairs(futureAdditives) do
					additiveRadius = additiveRadius + additives[currentAdditive].radius^2
				end
				validPaths[#validPaths+1] = {additives = futureAdditives, position = newPos, additiveRadius = math.sqrt(additiveRadius), dist = math.sqrt(futureDist)}
			else
				for n, currentAdditive in ipairs(futureAdditives) do
					additiveRadius = additiveRadius + additives[currentAdditive].radius^2
				end
				if futureDist + additiveRadius < targetPos.radius^2 then
				 	validPaths[#validPaths+1] = {additives = futureAdditives, position = newPos, additiveRadius = math.sqrt(additiveRadius), dist = math.sqrt(futureDist)}
				elseif(futureDist < currentDist) then
					childPaths = self:findPathStep(stepNum+1, maxStepNum, newPos, targetPos, additives, futureAdditives, reducedAdditiveList)
					if childPaths ~= false then
						for k, v in pairs(childPaths) do
							validPaths[k] = v
						end
					end
				end
			end
		end	
	end
	if validPaths ~= {}	 then
		return validPaths
	else
		return false
	end
end

function ViragsAutoCoordinate:CompleteAdditiveSub(idx, nAdditiveCount, tListAdditives, bComplete)
	local simplifiedAdditives = {}
	local additiveInfo
	for i, additive in pairs(tListAdditives) do
		additiveInfo = additive:GetAdditiveInfo()
		simplifiedAdditives[i] = {fVectorX = additiveInfo.fVectorX, fVectorY = additiveInfo.fVectorY, radius = additiveInfo.fRadius}
	end

	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	
	local currentPos = {fVectorX = tCurrentCraft.fVectorX, fVectorY = tCurrentCraft.fVectorY}
	local target = {fVectorX = tMatches[1].xT, fVectorY = tMatches[1].yT, radius = tMatches[1].fT}
	
	if self:squareDist(currentPos, target) < target.radius^2 then
		doAdditives = false
		readyToCraft = true
	else
		local paths = self:findPathStep(idx - 1, nMaxAdditives, currentPos, target, simplifiedAdditives, {}, {})
		
		if paths == false then
			doAdditives = false
			readyToCraft = true
			return
		end
		
		local closestDist = 1000
		local minAdditives = 10
		local closestPath = {}
		for i, path in pairs(paths) do
			local tempAdditives = path.additives
			if #tempAdditives <= minAdditives then
				if path.dist + path.additiveRadius / 2 < closestDist then
					closestPath = path
					closestDist = path.dist + path.additiveRadius / 2
				end
			end
		end

		
		if closestPath.additiveRadius ~= nil then
			if GameLib.GetPlayerCurrency():GetAmount() > tListAdditives[closestPath.additives[1]]:GetBuyPrice():GetAmount() then
				CraftingLib.AddAdditive(tListAdditives[closestPath.additives[1]])
				tMCurrentCraft = CraftingLib.GetCurrentCraft()	
			else
				doAdditives = false
				self:ViragsPrint("Not enough money.")
			end
			return
		else 
			doAdditives = false
			readyToCraft = true
		end
	end
end

function ViragsAutoCoordinate:table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, self:table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function ViragsAutoCoordinate:softResume()
	if not self.stop then
		doAdditives = true
	end
end



function ViragsAutoCoordinate:CompleteCrafting()
	readyToCraft = false
	local idSchematic = tCurrentSchematicId--carbineCraft.wndMain:GetData()
	local tSchematicInfo = CraftingLib.GetSchematicInfo(idSchematic)
	
	if tSchematicInfo.bIsAutoCraft then
		local nCraftAtOnceMax = tSchematicInfo.nCraftAtOnceMax 
		--self:ViragsPrint(nCraftAtOnceMax .. ", " .. self.Count)
		local nToCraft = math.min(self.Count, nCraftAtOnceMax, self:GetAvailable(idSchematic, tSchematicInfo))
		self.Count = self.Count - nToCraft + 1
		if bHasEnoughMaterials == true then
			CraftingLib.CraftItem(tSchematicInfo.nSchematicId, nil, nToCraft)
			craftingStarted = true
		end
	else 
		local carbineCraft = Apollo.GetAddon("CraftingGrid")
		if carbineCraft.wndMain ~= nil then
			local carbineCompleteCraftButton = carbineCraft.wndMain:FindChild("CraftBtn")
			carbineCraft:OnCraftBtn(carbineCompleteCraftButton, carbineCompleteCraftButton)
			craftingStarted = true
		else 
			self:ViragsPrint("Could not find Coordinate Board window, crafting stopped.")
			return
		end
	end
end

function ViragsAutoCoordinate:OnCraftingComplete()
	tSuccessChance[tCurrentSchematic.strName].nCrafts = tSuccessChance[tCurrentSchematic.strName].nCrafts + 1
	self:SuccessCheck()
	self:RefreshPattern(currentItemIndex)
	if self.wndCraftResults then 
		table.insert(tCraftResults, 1, tCurrentCraftResults)
		self:AddCraftResult() 
	end
	
	if self.Stop then
		if self.Count == 0 then
			table.remove(self.SavedConfig, currentItemIndex)
			self:AddPattern()
			
			if IsCraftingQue == true then 
				IsCraftingQue = false
			end
			
			if IsCraftingQueItem == true then 
				IsCraftingQueItem = false
			end
			
			self.listItemParent = nil
			self.selectedListItem = nil
			self.listItemIndex = nil
			self.tCurrentCatalyst = nil
	
					
		end
		self:ViragsPrint("Crafting complete.")
		doAdditives = false
		return
	end
end

function ViragsAutoCoordinate:OnCraftingAutoResume()
	doAdditives = true

	if self.Count >= 1 then
				
		self:StartCrafting()
		return
	elseif self.Count <= 0 then
		if IsCraftingQue == true then 
			self:ViragsPrint("Que next item.")
			table.remove(self.SavedConfig, 1)
			
			self:AddPattern()

			self:OnCraftQue()
			return
		end
		
		if IsCraftingQueItem == true then 
			table.remove(self.SavedConfig, currentItemIndex)
			self:AddPattern()
			IsCraftingQueItem = false
		end
		
		self.listItemParent = nil
		self.selectedListItem = nil
		self.listItemIndex = nil
		self.tCurrentCatalyst = nil

		self:ViragsPrint("Crafting complete.")
		doAdditives = false
	end
end

function ViragsAutoCoordinate:SuccessCheck()
	local successCheck = self.wndMain:FindChild("SuccessCheckBox"):IsChecked()
	if successCheck == false then 
		self.Count = self.Count - 1 
	elseif successCheck == true and targetItemLooted == true then
		self.Count = self.Count - 1
		targetItemLooted = false
	end
end


function ViragsAutoCoordinate:RefreshPattern(nConfig)
	local config = self.SavedConfig[nConfig]
	if config ~= nil then
		config.wndListItem:FindChild("ItemsToCraftBox"):SetText(self.Count)
		config.itemsToCraft = self.Count
		self:AddPattern()
	end
end

-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinateForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function ViragsAutoCoordinate:OnOK()
	self:StartCrafting()
end

-- when the Cancel button is clicked
function ViragsAutoCoordinate:OnCancel()
	self:OnViragsAutoCoordinateStop()
end


function ViragsAutoCoordinate:OnClose( wndHandler, wndControl, eMouseButton )
	self:OnViragsAutoCoordinateStop()
	self.wndMain:Close()
end

function ViragsAutoCoordinate:OnCountChanged(wndHandler, wndControl, strText )
	local item = wndHandler:GetName()
	local wndEdit = nil
	local count = nil
	
	if item == "ItemsNumber" then 
		wndEdit = self.wndItems
		count = self:ValidateInput(strText, 9001)
	else 
		wndEdit = self.wndAttrStep 
		count = self:ValidateInput(strText, 100)
	end
	
	if count then wndHandler:SetText(count) end
end

function ViragsAutoCoordinate:OnQueItemsCountChanged( wndHandler, wndControl, strText )
	local count = self:ValidateInput(strText, 9001)
	local key = wndHandler:GetData()
	if count then 
		wndHandler:SetText(self:ValidateInput(strText, 9001))
		self.SavedConfig[key].itemsToCraft = count
	else 
		self.SavedConfig[key].itemsToCraft = tonumber(strText)
	end
	self:RefreshMaterialsWnd(wndHandler:GetParent():GetParent(),
	CraftingLib.GetSchematicInfo(self.SavedConfig[key].nSchematicId),
	self.SavedConfig[key].itemsToCraft)
	
end

function  ViragsAutoCoordinate:ValidateInput(strText, num) 
	local count =  tonumber(strText)	
	if count == nil or count <= 0 then 
		count = 0 
		return count
	elseif count > num then
		count = num
		return count
	end
	return nil
end

function ViragsAutoCoordinate:OnPickerUp(wndHandler, wndControl)
	local parent = wndHandler:GetParent():GetName()
	if parent == "PickerItems" then
		local wndNumber = wndHandler:GetParent():GetParent():FindChild("ItemsNumber")
		wndNumber:SetText(tonumber(wndNumber:GetText()) + 1)
		--self.wndItems:SetText(tonumber(self.wndItems:GetText()) + 1)
	elseif parent == "SchematicItems" then
		local wndSchematics = wndHandler:GetParent():GetParent()
		local wndSchematic = wndSchematics:FindChild("Schematic")
		local tSubSchematics = wndSchematic:GetData()[1]
		if tSubSchematics then
			local nCurrentSchematic = wndSchematic:GetData()[2]
			local chosenSchematic = tSubSchematics[nCurrentSchematic + 1]	
			if chosenSchematic then
				wndSchematic:SetData({ tSubSchematics, nCurrentSchematic + 1, chosenSchematic } )
				wndSchematic:SetText(chosenSchematic.itemOutput:GetName())
				wndSchematics:FindChild("Icon"):SetSprite(chosenSchematic.itemOutput:GetIcon())
			else 
				wndSchematic:SetData({ tSubSchematics, 1, tSubSchematics[1]})
				wndSchematic:SetText(tSubSchematics[1].itemOutput:GetName())
				wndSchematics:FindChild("Icon"):SetSprite(tSubSchematics[1].itemOutput:GetIcon())

			end
		end
	else 
		self.wndAttrStep:SetText(tonumber(self.wndAttrStep:GetText()) + 1)
	end
end

function ViragsAutoCoordinate:OnPickerDown(wndHandler, wndControl)	
	local parent = wndHandler:GetParent():GetName()
	local wndPicker = nil
	if parent == "PickerItems" then 
		wndPicker = wndHandler:GetParent():GetParent():FindChild("ItemsNumber")	
		if (tonumber(wndPicker:GetText()) > 1 ) then
			wndPicker:SetText(tonumber(wndPicker:GetText()) - 1)
		end
	elseif parent == "SchematicItems" then
		local wndSchematics = wndHandler:GetParent():GetParent()
		local wndSchematic = wndSchematics:FindChild("Schematic")
		local tSubSchematics = wndSchematic:GetData()[1]
		if tSubSchematics then
			local nCurrentSchematic = wndSchematic:GetData()[2]
			local chosenSchematic = tSubSchematics[nCurrentSchematic - 1]	
			if chosenSchematic then
				wndSchematic:SetData({ tSubSchematics, nCurrentSchematic - 1, chosenSchematic })
				wndSchematic:SetText(chosenSchematic.itemOutput:GetName())
				wndSchematics:FindChild("Icon"):SetSprite(chosenSchematic.itemOutput:GetIcon())
			else 
				local n = table.getn(tSubSchematics)
				wndSchematic:SetData({tSubSchematics, n, tSubSchematics[n] })
				wndSchematic:SetText(tSubSchematics[n].itemOutput:GetName())
				wndSchematics:FindChild("Icon"):SetSprite(tSubSchematics[n].itemOutput:GetIcon())
			end
		end
	else 
		wndPicker = self.wndAttrStep 
		if (tonumber(wndPicker:GetText()) > 1 ) then
			wndPicker:SetText(tonumber(wndPicker:GetText()) - 1)
		end
	end

	
end



function ViragsAutoCoordinate:OnCatalystCheck( wndHandler, wndControl, eMouseButton )
	local config = self.SavedConfig[self.listItemIndex]
	if config and wndHandler:GetData() then
		config.chosenCatalyst = wndHandler:GetData()[2]
		if wndHandler:GetData()[1] ~= nil then
			config.tChosenCatalyst = wndHandler:GetData()[1]
		end
	end
	wndHandler:FindChild("IsChecked"):Show(true)
end

function ViragsAutoCoordinate:OnCatalystUncheck( wndHandler, wndControl, eMouseButton )
	local config = self.SavedConfig[self.listItemIndex]
	if config then
		config.chosenCatalyst = nil
	end
	wndHandler:FindChild("IsChecked"):Show(false)
end

function ViragsAutoCoordinate:OnShowCraftResults( wndHandler, wndControl, eMouseButton )
	self.wndCraftResults = self.wndMain:FindChild("CraftResults")

	if not self.wndCraftResults then
		self.wndCraftResults = Apollo.LoadForm(self.xmlDoc, "CraftResults", self.wndMain, self)
		if self.craftResultPosition ~= nil then
			self.wndCraftResults:Move(self.craftResultPosition.left, self.craftResultPosition.top, self.wndCraftResults:GetWidth(), self.wndCraftResults:GetHeight())
		else
			self.wndCraftResults:Move(0, self.wndMain:GetHeight() + 150, self.wndCraftResults:GetWidth(), self.wndCraftResults:GetHeight())
		end
		if self.wndCraftResultsPosition ~= nil then
			self.wndCraftResults:Move(self.wndCraftResultsPosition.left, self.wndCraftResultsPosition.top, self.wndCraftResults:GetWidth(), self.wndCraftResults:GetHeight())
			self.wndCraftResultsPosition = nil
			self.bIsResultsOpen = true
		end
	end
	
end

-----------------------------------------------------------------------------------------------
-- Save Patterns Begin
-----------------------------------------------------------------------------------------------

function ViragsAutoCoordinate:OnCraftQueItem()
	if GameLib.GetPlayerUnit():IsCasting() then
		self:ViragsPrint("Can not craft, while casting.")
		return
	end
	
	if GameLib.GetPlayerUnit():IsMounted() then
		self:ViragsPrint("Dismount to start crafting.")
		return
	end
	
	if not self.listItemParent then
		self:ViragsPrint("Please Select the Que Item.")
		return
	end
	--PreviewStartCraftBtn
	local item = self.selectedListItem
	if CraftingLib.GetCurrentCraft() ~= nil then
		self:ViragsPrint ("Finish current craft to start crafting.")
		return
		--CraftingLib.CraftItem(item.nSchematicId)
	end
	IsCraftingQueItem = true
	IsCraftingQue = false
	config = self.SavedConfig[self.listItemIndex]
	
	if config == nil then return end
 
	local item = config.wndListItem:GetData()
	self.tCurrentCatalyst = config.tChosenCatalyst
	self.isSubSchematic = config.isSubSchematic 
	self:GetAvailable(config.nSchematicId, CraftingLib.GetSchematicInfo(config.nSchematicId))
	
	if not bHasEnoughMaterials then
		self:ViragsPrint("Not enough materials.")
		doAdditives = false
		return
	end

	if not CraftingLib.GetSchematicInfo(config.nSchematicId).bIsAutoCraft then
		Event_FireGenericEvent("GenericEvent_StartCraftingGrid", item.nSchematicId)
		local carbineCraft = Apollo.GetAddon("CraftingGrid")	
		local carbineCraftPreviewBtn = carbineCraft.wndMain:FindChild("PreviewStartCraftBtn")
		carbineCraftPreviewBtn:SetData(config.nSchematicId)
		--carbineCraft:OnPreviewStartCraftBtn(carbineCraftPreviewBtn, carbineCraftPreviewBtn)
	end
	
	tCurrentSchematic = config.tSubInfo
	tCurrentSchematicId = config.nSchematicId
	currentItemIndex = self.listItemIndex
	
	if tSuccessChance[tCurrentSchematic.strName] == nil then
		tSuccessChance[tCurrentSchematic.strName] = { nCrafts = 0, nSuccessCrafts = 0 }
	end
	
	local tradeskills = Apollo.GetAddon("TradeskillContainer")
	if tradeskills ~= nil and tradeskills.wndMain:IsVisible() then
		tradeskills:OnClose()
	end
	
	self.Count = tonumber(config.wndListItem:FindChild("ItemsToCraftBox"):GetText())
	self:StartCrafting()
end




function ViragsAutoCoordinate:OnCraftQue()
	--GameLib:Disembark()
	--self:ViragsPrint("On craft queue.")

		
	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	if GameLib.GetPlayerUnit():IsCasting() then
		self:ViragsPrint("Can not craft, while casting.")
		return
	end
	
	if GameLib.GetPlayerUnit():IsMounted() then
		self:ViragsPrint("Dismount to start crafting.")
		return
	end

	if table.getn(self.SavedConfig) == 0 then
		self:ViragsPrint("No patterns to craft, crafting stopped.")
		IsCraftingQue = false
		--CraftQueIndex = 0
		return
	end
	
	if tCurrentCraft ~= nil and CraftingLib.GetSchematicInfo(tCurrentCraft.nSchematicId).bIsAutoCraft then
		self.timer = ApolloTimer.Create(1.0, false, "OnCraftQue", self)
		self:ViragsPrint ("Refreshing crafting information.")
		return
	end
	
	if tCurrentCraft ~= nil and not CraftingLib.GetSchematicInfo(tCurrentCraft.nSchematicId).bIsAutoCraft then
		--self:Rover("gg", CraftingLib.GetCurrentCraft()) 
		--self:Rover("gg2", CraftingLib.GetSchematicInfo(tCurrentCraft.nSchematicId))
		self:ViragsPrint ("Finish current craft to start crafting.")
		return
	end
	config = self.SavedConfig[ 1 ]
	IsCraftingQue = true
	IsCraftingQueItem = false
	--self:Rover("config gg2", CraftingLib.GetSchematicInfo(config.nSchematicId))
	tCurrentSchematic = config.tSubInfo
	local item = config.wndListItem:GetData()
	tCurrentSchematicId = config.nSchematicId
	self.tCurrentCatalyst = config.tChosenCatalyst
	self.isSubSchematic = config.isSubSchematic 
	self.listItemIndex = 1
	currentItemIndex = 1
	
	if tSuccessChance[tCurrentSchematic.strName] == nil then
		tSuccessChance[tCurrentSchematic.strName] = { nCrafts = 0, nSuccessCrafts = 0 }
	end
	
	self:GetAvailable(config.nSchematicId, CraftingLib.GetSchematicInfo(config.nSchematicId))
	if not bHasEnoughMaterials then
		self:ViragsPrint("Not enough materials.")
		doAdditives = false
		return
	end
	
	if not CraftingLib.GetSchematicInfo(config.nSchematicId).bIsAutoCraft then
		Event_FireGenericEvent("GenericEvent_StartCraftingGrid", config.nSchematicId)
		local carbineCraft = Apollo.GetAddon("CraftingGrid")	
		local carbineCraftPreviewBtn = carbineCraft.wndMain:FindChild("PreviewStartCraftBtn")
		carbineCraftPreviewBtn:SetData(config.nSchematicId)	
		--carbineCraft:OnPreviewStartCraftBtn(carbineCraftPreviewBtn, carbineCraftPreviewBtn)
	end

	self.Count = tonumber(config.wndListItem:FindChild("ItemsToCraftBox"):GetText())
	local tradeskills = Apollo.GetAddon("TradeskillContainer")
	if tradeskills ~= nil and tradeskills.wndMain:IsVisible() then
		tradeskills:OnClose()
	end
	self:StartCrafting()

end

function ViragsAutoCoordinate:OnPatternsButtonCheck()
	--self.SavedConfig = {}
	self:AddPattern()
	
	self.wndMain:FindChild(wndNames[wndSize].patternList):Show(true)
end

function ViragsAutoCoordinate:OnPatternsButtonUncheck()
	self.wndMain:FindChild(wndNames[wndSize].patternList):Show(false)
end

function ViragsAutoCoordinate:AttachCoordinateBoardOverlay()
	local carbineGrid = Apollo.GetAddon("CraftingGrid")
	if not carbineGrid then return end
	local wndParent = carbineGrid.wndMain:FindChild("CraftingGridForm")
	local wndShowCoordinate = wndParent:FindChild("CircuitToggle")
	
	if not wndShowCoordinate then
		wndShowCoordinate = Apollo.LoadForm(self.xmlDoc, "CoordinateToggle",
		 wndParent , self)
		local closeLeft, closeTop, closeRight, closeBottom = wndParent:FindChild("CloseBtn"):GetAnchorOffsets()
		local circuitTOffsetLeft = 48
		--if Apollo.GetAddon("ViragsAutoCoordinate") == nil then
		--	circuitTOffsetLeft = 96
		--end
		wndShowCoordinate:SetAnchorOffsets(closeLeft - circuitTOffsetLeft, closeTop + 15, closeLeft, closeTop + 63)		
	end


end

function ViragsAutoCoordinate:AttachtTradeskillsOverlay()
	--[[if not self.wndMain:IsShown() then 
		self.wndMain:Show(true) 
		self.wndMain:ToFront()
	end]]
	local carbineTradeskills = Apollo.GetAddon("TradeskillSchematics")
	if not carbineTradeskills then return end
	carbineTradeskills.OnBottomItemCheck = self.OnBottomItemCheck
	local wndContainer = Apollo.FindWindowByName("TradeskillContainerForm")
	local wndParent = carbineTradeskills.wndMain:FindChild("RightBottomCraftPreview")--RightBottomCraftBtn")	
	local listItem = Apollo.LoadForm(self.xmlDoc, "PatternListItem", nil, self)
	
	itemHeight = listItem:GetHeight()
	listItem:Destroy()
	
	local wndOverlay = carbineTradeskills.wndMain:FindChild("ViragsAutoCircuitOverlay")
	local wndShowCoordinate = wndContainer:FindChild("CoordinateToggle")
	
	--if wndShowCoordinate ~= nil then
	--	wndShowCoordinate:Destroy()
	--end
	
	if not wndShowCoordinate then
		wndShowCoordinate = Apollo.LoadForm(self.xmlDoc, "CoordinateToggle",
		 wndContainer , self)
		local closeLeft, closeTop, closeRight, closeBottom = wndContainer:FindChild("CloseButton"):GetAnchorOffsets()
		local circuitTOffsetLeft = 48
		local circuitTOffsetRight = 0
		if Apollo.GetAddon("ViragsAutoCircuit") ~= nil then
			circuitTOffsetLeft = 96
			circuitTOffsetRight = 48
		end
		wndShowCoordinate:SetAnchorOffsets(closeLeft - circuitTOffsetLeft, closeTop - 5, closeLeft - circuitTOffsetRight, closeTop + 43)

	end
	
	if wndOverlay ~= nil then
		wndOverlay:Destroy()
		wndOverlay = nil
	end
	if not wndOverlay then
		wndOverlay = Apollo.LoadForm(self.xmlDoc, "ViragsAutoCircuitOverlay",
		  wndParent, self)		
		local offsetLeft, offsetTop  = 20, 5
		local overlayLeft, overlayTop, overlayRight, overlayBottom = wndOverlay:GetAnchorOffsets()
		wndOverlay:SetAnchorOffsets(overlayLeft + offsetLeft, overlayTop + offsetTop, overlayRight + offsetLeft, overlayBottom + offsetTop)
	end
	
	wndOverlay:SetData(wndParent:GetParent())
	wndOverlay:ToFront()
	if wndParent:GetParent():GetData() ~= nil then
		nSchematicId = wndParent:GetParent():GetData().nSchematicId
		tSchematicInfo = CraftingLib.GetSchematicInfo(nSchematicId)
		local tTradeskillInfo = CraftingLib.GetTradeskillInfo(tSchematicInfo.eTradeskillId)		
		local bCoordCraft = tTradeskillInfo.bIsCoordinateCrafting
		
		
		if not bCoordCraft then 
			self.wndTradeskillsHandler = nil
			self.wndTradeskillsHandlerData = nil
			Apollo.GetAddon("ViragsAutoCoordinate"):DetachTradeskillsOverlay()
			local viragsAutoCircuit = Apollo.GetAddon("ViragsAutoCircuit")
			if viragsAutoCircuit then
				viragsAutoCircuit:AttachtTradeskillsOverlay()
			end	 
		else
			--self:ViragsPrint(tSchematicInfo.strName .. " Attacht")
			
			local tSubSchematics = { tSchematicInfo }
			local index = 1
			for idx, tCurrSubRecipe in pairs(tSchematicInfo.tSubRecipes) do
				if not tCurrSubRecipe.bIsUndiscovered and tCurrSubRecipe.bIsKnown then
					index = index + 1
					tSubSchematics[index] = tCurrSubRecipe
				end
			end
			local itemCurrent = tSchematicInfo.itemOutput
			local strIcon = itemCurrent:GetIcon()		
			local wndIcon = wndOverlay:FindChild("Schematics"):FindChild("Icon")
			wndIcon:SetSprite(strIcon)
			wndOverlay:FindChild("Schematics"):FindChild("Schematic"):SetText(tSchematicInfo.strName)
			wndOverlay:FindChild("Schematics"):FindChild("Schematic"):SetData({ tSubSchematics, 1, tSubSchematics[1] })
	
			Tooltip.GetItemTooltipForm(self, wndIcon, itemCurrent, {bPrimary = true, bSelling = false})
		end
	end

	
	carbineTradeskills.wndOverlay = wndOverlay
	--[[if self.wndTradeskillsHandler ~= nil then
		self.wndTradeskillsHandler:SetData(self.wndTradeskillsHandlerData)
		carbineTradeskills:OnBottomItemCheck(self.wndTradeskillsHandler, self.wndTradeskillsHandler)
	end]]
end

function ViragsAutoCoordinate:DetachTradeskillsOverlay()
	local carbineTradeskills = Apollo.GetAddon("TradeskillSchematics")
	if not carbineTradeskills then return end
	local wndOverlay = carbineTradeskills.wndOverlay
	if wndOverlay ~= nil then
		carbineTradeskills.wndOverlay:Destroy()
		carbineTradeskills.wndOverlay = nil
	end
end

function ViragsAutoCoordinate:OnBottomItemCheck(wndHandler, wndControl) -- BottomItemBtn, data is tSchematic
	local tSchematicInfo = CraftingLib.GetSchematicInfo(wndHandler:GetData().nSchematicId)
	local tTradeskillInfo = CraftingLib.GetTradeskillInfo(tSchematicInfo.eTradeskillId)		
	self.bCoordCraft = tTradeskillInfo.bIsCoordinateCrafting
	
	
	
	Apollo.GetAddon("ViragsAutoCoordinate").wndTradeskillsHandler = wndHandler
	Apollo.GetAddon("ViragsAutoCoordinate").wndTradeskillsHandlerData = wndHandler:GetData()
	
	self.wndTradeskillsHandler = wndHandler
	self.wndTradeskillsHandlerData = wndHandler:GetData()

	-- Search and View All both use this UI button
	if self.wndLastBottomItemBtnBlue then -- TODO HACK
		self.wndLastBottomItemBtnBlue:SetTextColor(ApolloColor.new("UI_BtnTextGoldListNormal"))
	end

	if wndHandler:FindChild("BottomItemBtnText") then
		self.wndLastBottomItemBtnBlue = wndHandler:FindChild("BottomItemBtnText")
		wndHandler:FindChild("BottomItemBtnText"):SetTextColor(ApolloColor.new("UI_BtnTextGoldListPressed"))
	end



	self:DrawSchematic(wndHandler:GetData())
	self:OnTimerCraftingStationCheck()
	
	--[[tSchematicI = CraftingLib.GetSchematicInfo(Apollo.FindWindowByName("RightSide"):GetData().nSchematicId)
	self:ViragsPrint(tSchematicI.strName .. " Bottom")]]
	
	if not self.bCoordCraft then 
		Apollo.GetAddon("ViragsAutoCoordinate"):DetachTradeskillsOverlay()
		local viragsAutoCircuit = Apollo.GetAddon("ViragsAutoCircuit")
		if viragsAutoCircuit then
			viragsAutoCircuit:AttachtTradeskillsOverlay()
		end	 
	else
		--if (self.wndOverlay == nil) then
			Apollo.GetAddon("ViragsAutoCoordinate"):AttachtTradeskillsOverlay() 
			--return
		--end
	end

	
	if self.wndOverlay ~= nil and self.wndOverlay:FindChild("Schematics") ~= nil then	
		local tSubSchematics = { tSchematicInfo }
		local index = 1
		for idx, tCurrSubRecipe in pairs(tSchematicInfo.tSubRecipes) do
			if not tCurrSubRecipe.bIsUndiscovered and tCurrSubRecipe.bIsKnown then
				index = index + 1
				tSubSchematics[index] = tCurrSubRecipe
				--SendVarToRover("item " .. idx, tCurrSubRecipe , Apollo.GetAddon("Rover").ADD_ALL)
				--self:ViragsPrint(tCurrSubRecipe.strName)
			end	
			--self:ViragsPrint(" - " .. tCurrSubRecipe.strName)	
			--self:ViragsPrint(tCurrSubRecipe.fDiscoveryDistanceMin)
		end
		
		local itemCurrent = tSchematicInfo.itemOutput
		local strIcon = itemCurrent:GetIcon()		
		local wndIcon = self.wndOverlay:FindChild("Schematics"):FindChild("Icon")
		wndIcon:SetSprite(strIcon)
		self.wndOverlay:FindChild("Schematics"):FindChild("Schematic"):SetText(tSchematicInfo.strName)
		self.wndOverlay:FindChild("Schematics"):FindChild("Schematic"):SetData({ tSubSchematics, 1, tSubSchematics[1] })
		Tooltip.GetItemTooltipForm(self, wndIcon, itemCurrent, {bPrimary = true, bSelling = false})
	end
end


function ViragsAutoCoordinate:OnObscuredAddonVisible(strName)
	if strName == "TradeskillSchematics" then
		local tTradeskillSchematics = Apollo.GetAddon("TradeskillSchematics")
		if tTradeskillSchematics ~= nil then
			self.timer = ApolloTimer.Create(0.5, false, "AttachtTradeskillsOverlay", self)
			self.timer:Start()
		end
	end
	--[[if strName == "TradeskillContainer" then
		self.containerTimer = ApolloTimer.Create(0.5, false, "AttachtTradeskillsContainerOverlay", self)
		self.containerTimer:Start()
		
	end]]
end

function ViragsAutoCoordinate:OnSavePattern(wndHandler, wndControl)
	self.wndMain:FindChild("PatternsButton"):SetCheck(true)
	self:OnPatternsButtonCheck()
	self:OnShowCraftResults()
	self.wndMain:Show(true)
	local tSchematicInfo = nil
	local nSchematicId 	= nil
	local wndParent = wndHandler:GetParent()
	local wndSchematic = wndParent:FindChild("Schematics"):FindChild("Schematic")
	local isSubSchematic = true
	if wndParent:GetData() == nil then
		local carbineCraft = Apollo.GetAddon("Crafting")	
		local tSchematic = CraftingLib.GetCurrentCraft()
		tSchematicInfo = carbineCraft.tSchematicInfo
		nSchematicId = carbineCraft.tSchematicInfo.nSchematicId
	else 
		nSchematicId = wndParent:GetData():GetData().nSchematicId
		tSchematicInfo = CraftingLib.GetSchematicInfo(nSchematicId)
	end

	
	if wndSchematic:GetData() ~= nil then
		tSchematicInfo = wndSchematic:GetData()[3]
		if tSchematicInfo.tSubRecipes and #tSchematicInfo.tSubRecipes > 0 then
			isSubSchematic = false
		end
	end
	
	local patternToSave = {}
	local itemsToCraft = tonumber(wndParent:FindChild("ItemsNumber"):GetText())
	patternToSave.nSchematicId = nSchematicId
	patternToSave.isSubSchematic = isSubSchematic 
	patternToSave.strSchematicName = tSchematicInfo.strName
	patternToSave.tSubInfo = tSchematicInfo
	patternToSave.itemsToCraft = itemsToCraft
	if not self.SavedConfig then self.SavedConfig = {} end
	table.insert(self.SavedConfig, #self.SavedConfig + 1, patternToSave)
	self:AddPattern()
end

function ViragsAutoCoordinate:OnRemove(wndHandler, wndControl, eMouseButton, index)

	local rIndex
	for k, v in pairs(self.SavedConfig) do
		if v == self.selectedListItem then
			rIndex = k
		end
	end
	
	if rIndex then
		table.remove(self.SavedConfig, rIndex)
		self.listItemParent = nil
		self.selectedListItem = nil
		self.listItemIndex = nil
		self.tCurrentCatalyst = nil
	end
	self:AddPattern()	
end

function ViragsAutoCoordinate:OnClearQue()
	self.SavedConfig = {}
	self:AddPattern()
end

function ViragsAutoCoordinate:OnResizeWnd() 
	if (wndSize == PATTERN_LIST_SMALL) then
		self.wndMain:FindChild(wndNames[PATTERN_LIST_SMALL].patternList):Show(false)
		self.wndMain:FindChild(wndNames[PATTERN_LIST_BIG].patternList):Show(true)
		wndSize = PATTERN_LIST_BIG
	elseif (wndSize == PATTERN_LIST_BIG) then
		self.wndMain:FindChild(wndNames[PATTERN_LIST_SMALL].patternList):Show(true)
		self.wndMain:FindChild(wndNames[PATTERN_LIST_BIG].patternList):Show(false)
		wndSize = PATTERN_LIST_SMALL
	end
	self:AddPattern()
end

local tSummary = {}

function ViragsAutoCoordinate:Rover(tag, var)
	Apollo.GetAddon("Rover"):AddWatch(tag, var)
end

function ViragsAutoCoordinate:AddPattern()
	local wndPatternList = self.wndMain:FindChild(wndNames[wndSize].patternList):FindChild("Scroll")
	
	wndPatternList:DestroyChildren()
	tSummary = {}
	if not self.SavedConfig then self.SavedConfig = {} end
	for k, v in pairs(self.SavedConfig) do
	
		local item  = Apollo.LoadForm(self.xmlDoc, wndNames[wndSize].listItem, wndPatternList, self)
		v.wndListItem = item
		wndPatternList:ArrangeChildrenVert(0)
		
		local offset = 6
		--if wndSize == PATTERN_LIST_SMALL then offset = 7 end 
		local itemLeft, itemTop, itemRight, itemBottom = item:GetAnchorOffsets()
		item:SetAnchorOffsets(itemLeft + 5, itemTop, wndPatternList:GetWidth() - 36, itemTop + itemHeight - offset)

		
		local tSchematicInfo = CraftingLib.GetSchematicInfo(v.nSchematicId)
		local tSubInfo = v.tSubInfo
		
		v.strTradeskill = kTradeskills[tSchematicInfo.eTradeskillId].strName
		v.eTier = tSchematicInfo.eTier
		v.availableToCraft = self:GetAvailable(v.nSchematicId, tSchematicInfo)
		
		local itemCurrent = tSubInfo.itemOutput
		local tItem = itemCurrent:GetDetailedInfo()
		local strIcon = itemCurrent:GetIcon()
		local availableToCraft = v.availableToCraft				
		item:FindChild("QueListItemButton"):SetData(k)
		item:FindChild("Tradeskill"):SetSprite(kTradeskills[tSchematicInfo.eTradeskillId].strIcon)
		item:FindChild("Tradeskill"):SetTooltip(kTradeskills[tSchematicInfo.eTradeskillId].strName)
		item:FindChild("SkillLevel"):SetText(tSchematicInfo.eTier)
		item:FindChild("SkillLevel"):SetTooltip(kTradeskillTiers[tSchematicInfo.eTier])
		item:FindChild("ItemIcon"):SetSprite(strIcon)
		Tooltip.GetItemTooltipForm(self, item:FindChild("ItemIcon"), itemCurrent, {bPrimary = true, bSelling = false})
					
		item:FindChild("AvailableToCraft"):SetText(availableToCraft)
		if availableToCraft == 0 then
			item:FindChild("AvailableToCraft"):SetTextColor("red")	-- Red
		else
			item:FindChild("AvailableToCraft"):SetTextColor("green")	-- Green
		end
		item:FindChild("AvailableToCraft"):SetData(availableToCraft)
		
		local tChance = tSuccessChance[v.strSchematicName]
		local wndSuccess = item:FindChild("SuccessChance")
		local nSuccessRatio = nil
		
		if tChance then
			nSuccessRatio = tChance.nSuccessCrafts / tChance.nCrafts 
			local nSuccessPercent = math.floor( nSuccessRatio * 100)
			wndSuccess:SetText(	nSuccessPercent .. "%")
			wndSuccess:SetTextColor("green")

			if nSuccessPercent < 60 and nSuccessPercent > 30 then
				wndSuccess:SetTextColor("yellow")
			elseif nSuccessPercent <= 30 then
				wndSuccess:SetTextColor("red")
			end
			wndSuccess:SetTooltip(tChance.nSuccessCrafts .. " out of " .. tChance.nCrafts .. " attempts were successful")
		else
			
			wndSuccess:SetText("n/a")
		end
		item:SetData(v)
				
		local wndItemsToCraft = item:FindChild("QueListItemButton"):FindChild("ItemsToCraftBox")
		wndItemsToCraft:SetData(k)
		local itemsToCraft =  v.itemsToCraft
		if not itemsToCraft then itemsToCraft = 3 end
		wndItemsToCraft:SetText(itemsToCraft)
		
		if (wndSize == PATTERN_LIST_BIG) then 
			item:FindChild("SavedSchematic"):SetText(v.strSchematicName)
			Tooltip.GetItemTooltipForm(self, item:FindChild("SavedSchematic"), itemCurrent, {bPrimary = true, bSelling = false})
			local microchips = item:FindChild("Microchips")
			self:RefreshMaterialsWnd(microchips, tSchematicInfo, itemsToCraft)
		end
		
		
		self:PopulateSummary(tSchematicInfo, itemsToCraft, nSuccessRatio)		
	end
	
end

function ViragsAutoCoordinate:PopulateSummary(tSchematicInfo, itemsToCraft, nSuccessRatio)
	if nSuccessRatio and nSuccessRatio > 1 then nSuccessRatio = 1 end
	for key, tMaterial in pairs(tSchematicInfo.arMaterials) do	
		local strName = tMaterial.itemMaterial:GetName()
		local tItem = tSummary[strName]
		if tSummary[strName] == nil then
			tSummary[strName] = { 
				sName = tMaterial.itemMaterial:GetName(),
				tIcon = tMaterial.itemMaterial:GetIcon(),
				nHave = tMaterial.itemMaterial:GetBackpackCount(),
				nNeed = tMaterial.nNeeded * itemsToCraft, 
				 }
			if nSuccessRatio ~= nil then
				tSummary[strName].nSuccess = math.ceil((2 - nSuccessRatio) * tSummary[strName].nNeed)
			end
		else
			tSummary[strName].nNeed = tItem.nNeed + tMaterial.nNeeded * itemsToCraft 
			if nSuccessRatio ~= nil and tItem.nSuccess ~= nil then
				tSummary[strName].nSuccess = tItem.nSuccess 
				+ math.ceil(( 2 - nSuccessRatio) * tMaterial.nNeeded * itemsToCraft)
			else
				tSummary[strName].nSuccess = nil
			end
		end
												
	end
	
end

function ViragsAutoCoordinate:RefreshMaterialsWnd(microchips, tSchematicInfo, itemsToCraft)
	if (wndSize == PATTERN_LIST_BIG) then
		for key, tMaterial in pairs(tSchematicInfo.arMaterials) do
			if tMaterial.nNeeded > 0 then
				local wndMaterial = microchips:FindChild("Microchip" .. (key))
				local nBackpackCount = tMaterial.itemMaterial:GetBackpackCount()
				local sumM = tMaterial.nNeeded * itemsToCraft
				local canCraft = math.floor(nBackpackCount/sumM)
				wndMaterial:SetSprite(tMaterial.itemMaterial:GetIcon())
				wndMaterial:SetText(nBackpackCount .. "/" .. sumM )
				wndMaterial:SetTooltip(tMaterial.itemMaterial:GetName().. " " .. nBackpackCount .. "/" .. sumM .. " Enough for ".. canCraft .. " crafts.")
				--wndMaterial:FindChild("MaterialsName"):SetText(tMaterial.itemMaterial:GetName())
				wndMaterial:FindChild("MaterialsIconNotEnough"):Show(nBackpackCount < (tMaterial.nNeeded * itemsToCraft) )
				--self:HelperBuildItemTooltip(wndMaterial, tMaterial.itemMaterial)			
			end
		end	
	end		
end

function ViragsAutoCoordinate:OnSummaryBtn()
	local wndSummary = self.wndMain:FindChild("Summary")
	
	--[[if table.getn(tSummary) == 0 then 
		wndSummary:FindChild("Summary"):Show(false) 
		return 
	end]]
	
	if wndSummary:IsShown() then
		wndSummary:FindChild("Summary"):Show(false)
	else
		wndSummary:Show(true)
	end
	
	self:RefreshSummary()
	
end

function ViragsAutoCoordinate:OnSummaryHide() 
	self.wndMain:FindChild("Summary"):Show(false)
end

function ViragsAutoCoordinate:OnSummaryRefresh() 	
	self:AddPattern()
	self:RefreshSummary()
	
end

function ViragsAutoCoordinate:RefreshSummary()
	local wndSummary = self.wndMain:FindChild("Summary")
	local wndSummaryList = self.wndMain:FindChild("SumList")
	
	local sumLeft, sumTop, sumRight, sumBottom = wndSummary:FindChild("FormBackground"):GetAnchorOffsets()
	wndSummary:FindChild("FormBackground"):SetAnchorOffsets(sumLeft, sumTop, sumRight, 157)
	wndSummaryList:DestroyChildren()
	
	for key, tMaterial in pairs(tSummary) do
		local item  = Apollo.LoadForm(self.xmlDoc, "SummaryListItem", wndSummaryList, self)
		
		wndSummaryList:ArrangeChildrenVert(0)
		local itemLeft, itemTop, itemRight, itemBottom = item:GetAnchorOffsets()
		local sumListLeft, sumListTop, sumListRight, sumListBottom = wndSummaryList:GetAnchorOffsets()
		local sumLeft, sumTop, sumRight, sumBottom = wndSummary:FindChild("FormBackground"):GetAnchorOffsets()

		item:SetAnchorOffsets(itemLeft + 15, itemTop, itemRight, itemTop + 20)
		wndSummaryList:SetAnchorOffsets(sumListLeft, sumListTop, sumListRight, sumListTop + itemTop + 20)
		wndSummary:FindChild("FormBackground"):SetAnchorOffsets(sumLeft, sumTop, sumRight, sumTop + sumListTop + itemTop + 90)
		if tMaterial.nSuccess ~= nil then
			item:FindChild("Adjusted"):SetText(tMaterial.nSuccess) 
		else 
			item:FindChild("Adjusted"):SetText("n/a")
		end

		local bIsEnough = tMaterial.nHave >= tMaterial.nNeed
		item:FindChild("Icon"):SetSprite(tMaterial.tIcon)
		item:FindChild("Material"):SetText(tMaterial.sName)
		item:FindChild("Have"):SetText(tMaterial.nHave)
		if not bIsEnough then 
			item:FindChild("Have"):SetTextColor("red") 
		else 
			item:FindChild("Have"):SetTextColor("green")
		end
		item:FindChild("Need"):SetText(tMaterial.nNeed)
	end

end



function ViragsAutoCoordinate:GetAvailable(nSchematicId, tSchematicInfo)
		local bHaveEnoughMats = true
	local available = 9999
	for key, tMaterial in pairs(tSchematicInfo.arMaterials) do
		--self:Rover("GetBackpackCount()", tMaterial )
		if tMaterial.nNeeded > 0 then
			local nBackpackCount = tMaterial.itemMaterial:GetBackpackCount()
			available = math.min(available, math.floor(nBackpackCount / tMaterial.nNeeded))
		end
	end
	bHasEnoughMaterials = true
	if available == 0 then bHasEnoughMaterials = false end
	return available
end


-- modify: don't need additives
-- modify: list each item with success/total
function ViragsAutoCoordinate:AddCraftResult()
	local wndScroll = self.wndCraftResults:FindChild("Scroll")
	wndScroll:DestroyChildren()
	--local sumLeft, sumTop, sumRight, sumBottom = self.wndCraftResults:FindChild("FormBackground"):GetAnchorOffsets()
	--wndSummary:FindChild("FormBackground"):SetAnchorOffsets(sumLeft, sumTop, sumRight, 157)
	--wndScroll:DestroyChildren()
	local totalCrafts = 0
	local successCrafts = 0
	local craftResults = {}
	for key, tResult in pairs(tCraftResults) do
		if tResult ~= nil and tResult.strName ~= nil then
			if craftResults[tResult.strName] == nil or craftResults[tResult.strName].total == nil then
				craftResults[tResult.strName] = {total = 0, success = 0}
			end

			if tResult.bSuccess == true then 
				successCrafts = successCrafts + 1
				craftResults[tResult.strName].success = craftResults[tResult.strName].success + 1
			end
			
			totalCrafts = totalCrafts + 1
			craftResults[tResult.strName].total = craftResults[tResult.strName].total + 1
		end
	end

	
	for key, result in pairs(craftResults) do
		local item  = Apollo.LoadForm(self.xmlDoc, "CraftResultsListItem", wndScroll, self)
		wndScroll:ArrangeChildrenVert(0)		
		
		item:FindChild("name"):SetText(key)
		item:FindChild("success"):SetText(result.success .. " / " .. result.total)
	end
end


-----------------------------------------------------------------------------------------------
-- Save Patterns End
-----------------------------------------------------------------------------------------------

function ViragsAutoCoordinate:OnSave(eType)
    if eType ~= GameLib.CodeEnumAddonSaveLevel.General then
        return nil
    end 
	local save = { SavedConfig = {} }
	local posLeft, posTop = self.wndMain:GetPos()
	save.mainPosition = { left = posLeft, top = posTop }
	if self.wndCraftResultsPosition == nil then		
		local posLeft, posTop = self.wndCraftResults:GetPos()
		save.craftResultPosition = { left = posLeft, top = posTop }
		save.bIsResultsOpen = true
	else
		save.craftResultPosition = self.wndCraftResultsPosition
		save.bIsResultsOpen = false
	end
	save.tSuccessChance = tSuccessChance
	save.nVersion = "1.04"
	save.wndSize = wndSize
    return save
end

function ViragsAutoCoordinate:OnRestore(eType, tData)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.General then
        return nil
    end 
	if tData.mainPosition ~= nil then
        self.wndMain:Move(tData.mainPosition.left, tData.mainPosition.top, self.wndMain:GetWidth(), self.wndMain:GetHeight())
    end
	if tData.craftResultPosition ~= nil then
		self.craftResultPosition = tData.craftResultPosition
    end
	if tData.wndSize ~= nil then
		wndSize = tData.wndSize
	end
	
	if tData.tSuccessChance ~= nil then
		tSuccessChance = tData.tSuccessChance
	else 
		tSuccessChance = {}
	end
	self.bIsResultsOpen = tData.bIsResultsOpen
	tSummary = {}
	--self.SavedConfig = tData.SavedConfig
end


---------------------------------------------------------------------------------------------------
-- CraftResults Functions
---------------------------------------------------------------------------------------------------

function ViragsAutoCoordinate:OnCraftResultsDestroy( wndHandler, wndControl, eMouseButton )		
	local posLeft, posTop = self.wndCraftResults:GetPos()
	self.wndCraftResultsPosition = { left = posLeft, top = posTop }
	wndHandler:GetParent():Destroy()
	self.wndCraftResults = nil
	self.bIsResultsOpen = false
	tCraftResults = {}
end

function ViragsAutoCoordinate:OnCraftResultsClear( wndHandler, wndControl, eMouseButton )
	tCraftResults = {}
	self:AddCraftResult()

end

function ViragsAutoCoordinate:OnWndMouseEnter( wndHandler, wndControl, x, y )
	if wndHandler:GetName() == "ClearResultsSprite" then
		wndHandler:SetSprite("CRB_Basekit:kitBtn_Metal_Icon_InsetTrashFlyBy")
	end
	if wndHandler:GetName() == "Sprite" then
		wndHandler:SetBGColor("yellow")
	end

	if wndHandler:GetName() == "RefreshSprite" then
		wndHandler:SetBGColor("yellow")
	end

end

function ViragsAutoCoordinate:OnWndMouseExit( wndHandler, wndControl, x, y )
	if wndHandler:GetName() == "ClearResultsSprite" then
		wndHandler:SetSprite("CRB_Basekit:kitBtn_Metal_Icon_InsetTrashNormal")
		
	end
	if wndHandler:GetName() == "Sprite" then
		wndHandler:SetBGColor("ItemQuality_Good")
	end
	
	if wndHandler:GetName() == "RefreshSprite" then
		wndHandler:SetBGColor("ItemQuality_Good")
	end

end

function ViragsAutoCoordinate:OnGridCloseBtn(wndHandler, wndControl)
	local virA = Apollo.GetAddon("ViragsAutoCoordinate")
	if virA then virA.wndMain:Show(false) end
	if wndHandler ~= wndControl then
		return
	end

	if self.wndMain and self.wndMain:IsValid() then
		self.wndMain:Destroy()
		self.wndMain = nil

		local tCurrentCraft = CraftingLib.GetCurrentCraft()
		if tCurrentCraft and tCurrentCraft.nSchematicId ~= 0 then
			Event_FireGenericEvent("GenericEvent_LootChannelMessage", Apollo.GetString("CoordCrafting_CraftingInterrupted"))
		end
	end
	Event_FireGenericEvent("AlwaysShowTradeskills")
end

--[[function ViragsAutoCoordinate:OnQueListItemCheck(wndHandler, wndControl, eMouseButton)
	wndHandler:FindChild("Background"):SetBGColor("AddonLoaded")
	wndHandler:FindChild("Checked"):Show(true)
	self.listItemIndex = wndHandler:GetData()
	self.listItemParent = wndHandler:GetParent()
	self.selectedListItem = self.listItemParent:GetData()
	config = self.SavedConfig[self.listItemIndex] 
	local item = config.wndListItem:GetData()
	self:RefreshCatalysts(item.nSchematicId, CraftingLib.GetSchematicInfo(item.nSchematicId), config.strSchematicName)
end

function ViragsAutoCoordinate:OnQueListItemUncheck(wndHandler, wndControl, eMouseButton)
	wndHandler:FindChild("Background"):SetBGColor("ItemQuality_Good")
	wndHandler:FindChild("Checked"):Show(false)
	self.listItemIndex = nil
	self.listItemParent = nil
	self.selectedListItem = nil
	self:ResetCatalysts()
end]]

function ViragsAutoCoordinate:OnQueListItemCheck(wndHandler, wndControl, eMouseButton)
	wndHandler:FindChild("Background"):SetBGColor("AddonLoaded")
	wndHandler:FindChild("Checked"):Show(true)
	self.listItemIndex = wndHandler:GetData()
	self.listItemParent = wndHandler:GetParent()
	self.selectedListItem = self.listItemParent:GetData()
	config = self.SavedConfig[self.listItemIndex] 
	local item = config.wndListItem:GetData()

	local wndPicker = self.listItemParent:FindChild("QueuePicker")
	wndPicker:Show(true)
	wndPicker:SetData(self.listItemIndex)
	local bCheckUp = self:CheckQueueKey(self.listItemIndex, -1)
	local bCheckDown = self:CheckQueueKey(self.listItemIndex, 1)
	if bCheckUp == false and bCheckDown == false then
		wndPicker:Show(false)
	elseif bCheckUp == false then
		wndPicker:FindChild("PickerUp"):Show(false)
	elseif self:CheckQueueKey(self.listItemIndex, 1) == false then
		wndPicker:FindChild("PickerDown"):Show(false)
	end
end

function ViragsAutoCoordinate:OnQueListItemUncheck(wndHandler, wndControl, eMouseButton)
	wndHandler:FindChild("Background"):SetBGColor("ItemQuality_Good")
	wndHandler:FindChild("Checked"):Show(false)
	wndHandler:GetParent():FindChild("QueuePicker"):Show(false)
	self.listItemIndex = nil
	self.listItemParent = nil
	self.selectedListItem = nil
	
end


function ViragsAutoCoordinate:OnQueuePickerDown( wndHandler, wndControl, eMouseButton )
	local wndPatternList = self.wndMain:FindChild(wndNames[wndSize].patternList):FindChild("Scroll")
	local wndParent = wndHandler:GetParent()
	local key = wndParent:GetData()
	local swap = self.SavedConfig[key +1]
	self.SavedConfig[key +1] = self.SavedConfig[key]
	self.SavedConfig[key] = swap
	local offset = 6
	--if wndSize == PATTERN_LIST_SMALL then offset = 7 end
	local currentPosition = wndPatternList:GetVScrollPos() + (itemHeight - offset) 
	--wndParent:GetParent():FindChild("QueListItemButton"):SetCheck(true)
	local wndBtn2 = self.SavedConfig[key].wndListItem:FindChild("QueListItemButton")
	self:OnQueListItemUncheck(wndBtn2, wndBtn2)
	self:AddPattern()
	local wndBtn1 = self.SavedConfig[key+1].wndListItem:FindChild("QueListItemButton")
	wndPatternList:SetVScrollPos(currentPosition)
	wndBtn1:SetCheck(true)
	self:OnQueListItemCheck(wndBtn1, wndBtn1)
end

function ViragsAutoCoordinate:OnQueuePickerUp( wndHandler, wndControl, eMouseButton )
	local wndPatternList = self.wndMain:FindChild(wndNames[wndSize].patternList):FindChild("Scroll")
	local wndParent = wndHandler:GetParent()
	local key = wndParent:GetData()
	local swap = self.SavedConfig[key -1]
	self.SavedConfig[key -1] = self.SavedConfig[key]
	self.SavedConfig[key] = swap
	local offset = 6
	local currentPosition = wndPatternList:GetVScrollPos() - (itemHeight - offset)
	
	local wndBtn2 = self.SavedConfig[key].wndListItem:FindChild("QueListItemButton")
	self:OnQueListItemUncheck(wndBtn2, wndBtn2)
	self:AddPattern()
	local wndBtn1 = self.SavedConfig[key-1].wndListItem:FindChild("QueListItemButton")
	wndPatternList:SetVScrollPos(currentPosition)
	wndBtn1:SetCheck(true)
	self:OnQueListItemCheck(wndBtn1, wndBtn1)
end

function ViragsAutoCoordinate:CheckQueueKey(key, value)
	if value > 0 then
		if key+value <= #self.SavedConfig then
			return true
		else 
			return false
		end
	else 
		if key+value >= 1 then
			return true
		else 
			return false
		end
	end
end

-----------------------------------------------------------------------------------------------
-- ViragsAutoCoordinate Instance
-----------------------------------------------------------------------------------------------
local ViragsAutoCoordinateInst = ViragsAutoCoordinate:new()
ViragsAutoCoordinateInst:Init()
