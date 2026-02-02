-- Manosaba_Witch_Factor_InGame
-- Author: Rin
-- DateCreated: 1/31/2026 11:43:59 AM
--------------------------------------------------------------
PLAYER_WITCH_FACTOR_HAS_KEY = "PLAYER_WITCH_FACTOR_HAS_KEY"
PLAYER_WITCH_FACTOR_BUFFER_KEY = "PLAYER_WITCH_FACTOR_BUFFER_KEY"
SUPPRESS_WITCH_TURN_KEY = "SUPPRESS_WITCH_TURN"
WITCH_FACTOR_THRESHOLD = 1000

function SavePlayerProperty(playerID, key, value)
	local player = Players[playerID]
	player:SetProperty(key, value)
end

function ChangeFaithBalance(playerID, value)
	local player = Players[playerID]
	local playerReligion		:table	= player:GetReligion();
	playerReligion:ChangeFaithBalance(value)
end
if ( not ExposedMembers.WitchFactor) then ExposedMembers.WitchFactor = {}; end
ExposedMembers.WitchFactor.SavePlayerProperty = SavePlayerProperty
ExposedMembers.WitchFactor.ChangeFaithBalance = ChangeFaithBalance

GameEvents.OnGameTurnStarted.Add(function(turn:number)
	WitchFactorRefresher()
	--GrantFaithBaseOnWitchFactor()
	AttachFaithBuffBaseOnWitchFactor()
	DefeatPlayerWhenReachThreshold()
end)


function WitchFactorRefresher()
	local players = Game.GetPlayers{Major = true};
	for i, player in ipairs(players) do
		local pSavedWitchFactor = player:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0
		for _, pCity in player:GetCities():Members() do
			-- only for manosaba civ
			local playerConfig = PlayerConfigurations[player:GetID()];
			local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
			local civilization = leader.CivilizationCollection[1];
			if civilization.CivilizationType == "CIVILIZATION_MANOSABA" then
				local addWitchFactor = GetCityWitchFactor(pCity)
				pSavedWitchFactor = pSavedWitchFactor + addWitchFactor
			end 
			pSavedWitchFactor = math.min(pSavedWitchFactor, WITCH_FACTOR_THRESHOLD)
		end
		if player:GetID() == Game.GetLocalPlayer() then
			local suppressTurn = player:GetProperty(SUPPRESS_WITCH_TURN_KEY) or 0
			if suppressTurn < Game.GetCurrentGameTurn() then
				player:SetProperty(PLAYER_WITCH_FACTOR_HAS_KEY, pSavedWitchFactor)
			end
		else
			player:SetProperty(PLAYER_WITCH_FACTOR_HAS_KEY, pSavedWitchFactor)
		end
	end
end

function GrantFaithBaseOnWitchFactor()
	local players = Game.GetPlayers{Major = true};
	for i, player in ipairs(players) do
		local pSavedWitchFactor = player:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0
		local muti = pSavedWitchFactor / WITCH_FACTOR_THRESHOLD 
		local playerReligion		:table	= player:GetReligion();
		local faithYield			:number = playerReligion:GetFaithYield() or 0;
		local faithBalance			:number = playerReligion:GetFaithBalance() or 0;
		local bonusFaith = math.floor(muti * faithYield)
		print("Grant bonus faith base on witch factor:"..bonusFaith)
		playerReligion:ChangeFaithBalance(bonusFaith)
		player:SetProperty(PLAYER_WITCH_FACTOR_HAS_KEY, pSavedWitchFactor)
	end
end

function AttachFaithBuffBaseOnWitchFactor()
	local players = Game.GetPlayers{Major = true};
	for i, player in ipairs(players) do
		local grantedBufferCount = player:GetProperty(PLAYER_WITCH_FACTOR_BUFFER_KEY) or 0
		local pSavedWitchFactor = player:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0
		local bufferNeed = math.floor(((pSavedWitchFactor - grantedBufferCount) * 100) / WITCH_FACTOR_THRESHOLD)
		if bufferNeed > 0 then
			print("Start to grant buffer for player:"..i)
			print("Grant faith buffer base on witch factor:"..bufferNeed)
			for var=1,bufferNeed do
				player:AttachModifierByID("MODIFIER_MANOSABA_FAITH_BUFF");
			end
			player:SetProperty(PLAYER_WITCH_FACTOR_BUFFER_KEY, grantedBufferCount + bufferNeed * 10)
		end
	end
end

function DefeatPlayerWhenReachThreshold()
	local iPlayer = Game.GetLocalPlayer()
	local player = Players[iPlayer]
	local pSavedWitchFactor = player:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0
	if pSavedWitchFactor < WITCH_FACTOR_THRESHOLD then return; end
	print("DefeatPlayerWhenReachThreshold")
	local cities = player:GetCities()
	for i, pCity in cities:Members() do
		cities:Destroy(pCity)
	end
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
