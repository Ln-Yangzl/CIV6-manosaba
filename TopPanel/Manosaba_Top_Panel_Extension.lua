-- Manosaba_Top_Panel_Extension
-- Author: Rin
-- DateCreated: 1/31/2026 9:45:33 AM
--------------------------------------------------------------
include("TopPanel_Expansion2.lua");


PLAYER_WITCH_FACTOR_HAS_KEY = "PLAYER_WITCH_FACTOR_HAS_KEY"
SUPPRESS_WITCH_TURN_KEY = "SUPPRESS_WITCH_TURN"
WITCH_FACTOR_THRESHOLD = 1000

TPE_BASE_RefreshYields = RefreshYields;
TPE_BASE_LateInitialize = LateInitialize;


local m_WitchFactorYieldButton = nil

function RefreshWitchFactor()
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if localPlayer == nil then
			return;
		end
	else
		return;
	end
	local playerID = Game.GetLocalPlayer()
	local playerConfig = PlayerConfigurations[playerID];
	local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
	local civilization = leader.CivilizationCollection[1];
	if civilization.CivilizationType ~= "CIVILIZATION_MANOSABA" then
		return
	end

	m_WitchFactorYieldButton = m_WitchFactorYieldButton or m_YieldButtonSingleManager:GetInstance()


	local pPlayerCities = localPlayer:GetCities()

	local pSavedWitchFactor = localPlayer:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0

	local pTotalWitchFactor = 0
	

	local sWitchFactorListText = ""
	
	for i, pCity in pPlayerCities:Members() do
	

		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		

		local pCityWitchFactor = GetCityWitchFactor(pCity)
		if pCityWitchFactor ~= 0 then
			local pCityWitchFactorText = pCityWitchFactor
			local addWitchFactorListText = "[NEWLINE]"..addCityNameText.." +"..pCityWitchFactorText
			sWitchFactorListText = sWitchFactorListText..addWitchFactorListText
			pTotalWitchFactor = pTotalWitchFactor + pCityWitchFactor
		end
		
	end
	
	local sTotalWitchFactor = pSavedWitchFactor.."/"..WITCH_FACTOR_THRESHOLD
	local muti = pSavedWitchFactor / WITCH_FACTOR_THRESHOLD 
	local playerReligion		:table	= localPlayer:GetReligion();
	local faithYield			:number = playerReligion:GetFaithYield() or 0;
	local faithBalance			:number = playerReligion:GetFaithBalance() or 0;
	local bonusFaith = math.floor(muti * faithYield)

	local suppressTurn = localPlayer:GetProperty(SUPPRESS_WITCH_TURN_KEY) or 0
	local suppressText = ""
	if Game.GetCurrentGameTurn() <= suppressTurn then
		suppressText = "[NEWLINE]"..Locale.Lookup("LOC_MANOSABA_WITCH_FACTOR_PRESS_TURN")..(suppressTurn - Game.GetCurrentGameTurn())
		pTotalWitchFactor = 0
	end
	
	local sToolTipText = Locale.Lookup("LOC_MANOSABA_WITCH_FACTOR_PER_TURN")..pTotalWitchFactor..suppressText.."[NEWLINE]"..sWitchFactorListText
	
	

	m_WitchFactorYieldButton.YieldPerTurn:SetText(sTotalWitchFactor)
	m_WitchFactorYieldButton.YieldBacking:SetToolTipString(sToolTipText)
	m_WitchFactorYieldButton.YieldPerTurn:SetColorByName("StatNormalCS")
	m_WitchFactorYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_WitchFactorYieldButton.YieldIconString:SetText("[ICON_UnderSiege]")
	m_WitchFactorYieldButton.YieldButtonStack:CalculateSize()


end

function RefreshYields()
	TPE_BASE_RefreshYields()
	
	
	RefreshWitchFactor()

	
	Controls.YieldStack:CalculateSize();
	Controls.StaticInfoStack:CalculateSize();
	Controls.InfoStack:CalculateSize();
	
end
function GetCityWitchFactor(pCity)
	if pCity == nil then return 0; end
	local factor = 1
	local pCityBldgs:table = pCity:GetBuildings();
	for buildingInfo in GameInfo.Buildings() do
		local buildingIndex:number = buildingInfo.Index;
		local buildingType:string = buildingInfo.BuildingType;
		if buildingType == 'BUILDING_CIVILIZATION_MANOSABA_PRISON_ISLAND' and pCityBldgs:HasBuilding(buildingIndex) then
			factor = factor + 1
		end
		if buildingType == 'BUILDING_MANOSABA_SCAFFOLD' and pCityBldgs:HasBuilding(buildingIndex) then
			factor = factor + 1
		end
		if buildingType == 'BUILDING_MANOSABA_COLD_ROOM' and pCityBldgs:HasBuilding(buildingIndex) then
			factor = factor + 1
		end
	end
	local pCityDists:table = pCity:GetDistricts();
	for districtInfo in GameInfo.Districts() do
		local districtIndex:number = districtInfo.Index;
		local districtType:string = districtInfo.DistrictType;
		if districtType == "DISTRICT_MANOSABA_COURT" and pCityDists:HasDistrict(districtIndex) then
			factor = factor + 1
		end 
	end
	return factor
end

--====================================================================================================================

function LateInitialize()
	TPE_BASE_LateInitialize()
end

