-- Manosaba_Audio
-- Author: Rin
-- DateCreated: 1/13/2026 1:33:48 PM
--------------------------------------------------------------

GameEvents = ExposedMembers.GameEvents;

local UIplayRecord = 0

Events.LoadGameViewStateDone.Add(function()
	local leader = getLeaderName()
	if (string.find(leader, "LEADER_MANOSABA")) then
		UI.PlaySound("Manosaba_Loading_BGM")
	end
end)

Events.LoadScreenClose.Add(function()
	UI.PlaySound("Manosaba_Stop_Loading_BGM")
	playStartVoice()
	
end)

Events.PlayerTurnActivated.Add(function(playerID, bIsFirstTime)
	local currentTurn = Game.GetCurrentGameTurn();
	playCompetitionVoice(currentTurn, playerID)
end)

--Events.BuildingAddedToMap.Add(function(iX, iY, buildingID, playerID, misc2, misc3)
	--playWardenIntroductionVoice(playerID, buildingID)
--end)

GameEvents.BuildingConstructed.Add(function(playerID, cityID, buildingID, plotID, bOriginalConstruction)
	playWardenIntroductionVoice(playerID, buildingID)
end)

Events.UnitAddedToMap.Add(function(playerID: number, unitID : number, unitX : number, unitY : number)
	playHiroGetPenVoice(playerID, unitID)
end);

Events.DiplomacyDeclareWar.Add(function(firstPlayerID, secondPlayerID)
	print(firstPlayerID)
	print(secondPlayerID)
	playDeclareWarBGM(firstPlayerID)
	playBeDeclaredWarBGM(secondPlayerID)
end)


Events.UnitKilledInCombat.Add(function(killedPlayerID, killedUnitID, playerID, unitID)
	playHiroKillUnitVoice(playerID)
	playSherryKillUnitVoice(playerID)
end)

Events.UnitCommandStarted.Add(function(playerID, unitID, hCommand, iData1)
	playSherryUnitAccelerateWondrProductionVoice(playerID, unitID, hCommand, iData1)
end)

function playSherryUnitAccelerateWondrProductionVoice(playerID, unitID, hCommand)
	local leader = getLeaderName()
	local pPlayer	:table = Players[playerID];
	local pUnit		:table = pPlayer:GetUnits():FindID(unitID);
	if pUnit == nil then return; end
	print("unit type:"..GameInfo.Units[pUnit:GetUnitType()].UnitType);
	print(hCommand)
	if Game.GetLocalPlayer() == playerID and leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME" and hCommond == nil and GameInfo.Units[pUnit:GetUnitType()].UnitType == "UNIT_BUILDER" then
		local random = getRandomNum(1, 3)
		UI.PlaySound("Manosaba_Sherry_Build_"..random.."_Voice")
	end
end

Events.GreatWorkCreated.Add(function(playerID, unitID, iCityPlotX, iCityPlotY, buildingID, greatWorkID)
	playGetEvidenceVoice(playerID, unitID, iCityPlotX, iCityPlotY, greatWorkID)
end)


function playGetEvidenceVoice(playerID, unitID, cityX, cityY, greatWorkID)
	if greatWorkID == nil then return; end
	local leader = getLeaderName()
	print("playGetEvidenceVoice greatWorkID:"..greatWorkID)
	m_City = Cities.GetCityInPlot(Map.GetPlotIndex(cityX, cityY));
	if m_City == nil then return; end
	m_CityBldgs = m_City:GetBuildings();
	m_GreatWorkType = m_CityBldgs:GetGreatWorkTypeFromIndex(greatWorkID);
	local greatWorkInfo:table = GameInfo.GreatWorks[m_GreatWorkType];
	if greatWorkInfo == nil or greatWorkInfo.GreatWorkObjectType ~= "GREATWORKOBJECT_MANOSABA_EVIDENCE" then return; end
	
	if Game.GetLocalPlayer() == playerID and leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME"  then
		print("Sherry voice for GetEvidenceVoice")
		local random = getRandomNum(1, 3)
		UI.PlaySound("Manosaba_Sherry_Find_Something_"..random.."_Voice")
	end
end

function playHiroKillUnitVoice(playerID) 
	if Game.GetLocalPlayer() == playerID then
		local leader = getLeaderName()
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			local random = getRandomNum(1, 5)
			if random == 1 then
				UI.PlaySound("Manosaba_Unit_Kill_Voice")
			elseif random == 2 then
				UI.PlaySound("Manosaba_Unit_Kill_2_Voice")
			end
		end
	end
end

function playSherryKillUnitVoice(playerID) 
	if Game.GetLocalPlayer() == playerID then
		local leader = getLeaderName()
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			local random = getRandomNum(1, 2)
			UI.PlaySound("Manosaba_Sherry_Unit_Kill_"..random.."_Voice")
		end
	end
end

function playDeclareWarBGM(firstPlayerID)
	if Game.GetLocalPlayer() == firstPlayerID then
		UI.PlaySound("Declare_War_BGM")
	end
end

function playBeDeclaredWarBGM(secondPlayerID)
	if Game.GetLocalPlayer() == secondPlayerID then
		UI.PlaySound("Be_Declared_War_BGM")
	end
end

function playHiroGetPenVoice(playerID, unitID)
	if Game.GetLocalPlayer() ~= playerID then return; end
	local pUnit = UnitManager.GetUnit(playerID, unitID);
	local sUnitName = pUnit:GetName();
	if sUnitName == "LOC_GREAT_PERSON_INDIVIDUAL_MANOSABA_PEN_GENERATOR_NAME" then
		UI.PlaySound("Manosaba_Hiro_Get_Pen_Voice")
	end
end

function playWardenIntroductionVoice(playerID, buildingID)
	if Game.GetLocalPlayer() == playerID and GameInfo.Buildings[buildingID].Name == 'LOC_BUILDING_CIVILIZATION_MANOSABA_PRISON_ISLAND_NAME' then
		UI.PlaySound("Warden_Introduction_Voice")
	end
end

function getLeaderName()
	return PlayerConfigurations[Game.GetLocalPlayer()]:GetLeaderName()
end

function playStartVoice()
	local leader = getLeaderName()
	if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
		local currentTurn = Game.GetCurrentGameTurn();
		if currentTurn > 1 then
			local voiceIndex = getRandomNum(1,2)
			UI.PlaySound("Manosaba_Hiro_Restart_"..voiceIndex.."_Voice")
		else
			UI.PlaySound("Manosaba_Hiro_StartGame_Voice")
		end
	end
	if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
		local currentTurn = Game.GetCurrentGameTurn();
		if currentTurn > 1 then
			local voiceIndex = getRandomNum(1,3)
			UI.PlaySound("Manosaba_Sherry_Restart_"..voiceIndex.."_Voice")
		else
			UI.PlaySound("Manosaba_Sherry_Start_Voice")
		end
	end
end

function playCompetitionVoice(turn, playerID)
	if playerID ~= Game.GetLocalPlayer() then return; end
	-- Current turn has already played the sound(aviod player turn activate mutiple times)
	if UIplayRecord == turn then return; end
	local leader = getLeaderName()
	-- competition 1 start turn
	if turn == 27 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_1_Start_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_6_Start_Voice")
		end
		UIplayRecord = 27
	end
	-- competition 1 end turn
	if turn == 37 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_1_End_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_6_End_Voice")
		end
		UIplayRecord = 37
	end
	-- competition 2 start turn
	if turn == 52 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_2_Start_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_7_Start_Voice")
		end
		UIplayRecord = 52
	end
	-- competition 2 end turn
	if turn == 62 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_2_End_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_7_End_Voice")
		end
		UIplayRecord = 62
	end
	-- competition 3 start turn
	if turn == 77 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_3_Start_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_8_Start_Voice")
		end
		UIplayRecord = 77
	end
	-- competition 3 end turn
	if turn == 87 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_3_End_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_8_End_Voice")
		end
		UIplayRecord = 87
	end
	-- competition 4 start turn
	if turn == 102 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_4_Start_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_9_Start_Voice")
		end
		UIplayRecord = 102
	end
	-- competition 4 end turn
	if turn == 112 then
		if (leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME") then
			UI.PlaySound("Manosaba_Hiro_Trial_4_End_Voice")
		end
		if (leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME") then
			UI.PlaySound("Manosaba_Sherry_Trial_9_End_Voice")
		end
		UIplayRecord = 112
	end
end

function getRandomNum(x, y)
	math.randomseed(os.time())
	math.random(x, y)
	math.random(x, y)
	math.random(x, y)
	return math.random(x, y)
end