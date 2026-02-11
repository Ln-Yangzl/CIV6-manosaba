-- Manosaba_Audio
-- Author: Rin
-- DateCreated: 1/13/2026 1:33:48 PM
--------------------------------------------------------------

GameEvents = ExposedMembers.GameEvents;

local UIplayRecord = 0
local hannaUnitMoveTurnRecord = 0

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

Events.UnitMoved.Add(function(playerID, unitID)
	playHannaUnitMoveVoice(playerID, unitID)
end)

Events.DiplomacyMeet.Add(function(player1ID:number, player2ID:number)
	playManosabaLeaderMeetVoice(player1ID, player2ID)
end)

function playManosabaLeaderMeetVoice(player1ID:number, player2ID:number)
	if Game.GetLocalPlayer() ~= player1ID then return; end
	local playerConfig = PlayerConfigurations[player2ID];
	local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
	if leader.LeaderType == "LEADER_MANOSABA_NIKAIDO_HIRO" then
		UI.PlaySound("Manosaba_Hiro_Self_Introduction_Voice")
	end
	if leader.LeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
		UI.PlaySound("Manosaba_Sherry_Start_Voice")
	end
	if leader.LeaderType == "LEADER_MANOSABA_TONO_HANNA" then
		UI.PlaySound("Manosaba_Hanna_Start_Voice")
	end
end

function playHannaUnitMoveVoice(playerID, unitID)
	local leader = getLeaderName()
	local pPlayer	:table = Players[playerID];
	local pUnit		:table = pPlayer:GetUnits():FindID(unitID);
	if pUnit == nil then return; end
	-- avoid muti play voice
	if Game.GetCurrentGameTurn() == hannaUnitMoveTurnRecord then return; end
	hannaUnitMoveTurnRecord = Game.GetCurrentGameTurn()
	if Game.GetLocalPlayer() == playerID and leader == "LOC_LEADER_MANOSABA_TONO_HANNA_NAME" and GameInfo.Units[pUnit:GetUnitType()].UnitType == "UNIT_BUILDER" then
		local random = getRandomNum(1, 20)
		if random <= 3 then
			UI.PlaySound("Manosaba_Hanna_Unit_Move_"..random.."_Voice")
		end
	end
end

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
	if (leader == "LOC_LEADER_MANOSABA_TONO_HANNA_NAME") then
		local currentTurn = Game.GetCurrentGameTurn();
		if currentTurn > 1 then
			if currentTurn < 25 then
				UI.PlaySound("Manosaba_Hanna_Restart_1_Voice")
			elseif currentTurn < 75 then
				UI.PlaySound("Manosaba_Hanna_Restart_2_Voice")
			else
				UI.PlaySound("Manosaba_Hanna_Restart_3_Voice")
			end 
			
		else
			UI.PlaySound("Manosaba_Hanna_Start_Voice")
		end
	end
end

function playCompetitionVoice(emergencyType, isStart)
	local leader = getLeaderName()
	-- Only play if local player is one of the Manosaba leaders
	if not string.find(leader, "LEADER_MANOSABA") then return end
	
	local trialNum = nil
	local soundSuffix = isStart and "Start" or "End"
	
	-- Map emergency type to trial number based on leader
	if emergencyType == "EMERGENCY_MANOSABA_COMPETITION_1" or emergencyType == "EMERGENCY_MANOSABA_COMPETITION_6" then
		trialNum = 1
	elseif emergencyType == "EMERGENCY_MANOSABA_COMPETITION_2" or emergencyType == "EMERGENCY_MANOSABA_COMPETITION_7" then
		trialNum = 2
	elseif emergencyType == "EMERGENCY_MANOSABA_COMPETITION_8" then
		trialNum = 3
	elseif emergencyType == "EMERGENCY_MANOSABA_COMPETITION_9" then
		trialNum = 4
	end
	
	if trialNum == nil then return end
	
	if leader == "LOC_LEADER_MANOSABA_NIKAIDO_HIRO_NAME" then
		UI.PlaySound("Manosaba_Hiro_Trial_"..trialNum.."_"..soundSuffix.."_Voice")
	elseif leader == "LOC_LEADER_MANOSABA_TACHIBANA_SHERRY_NAME" then
		UI.PlaySound("Manosaba_Sherry_Trial_"..trialNum.."_"..soundSuffix.."_Voice")
	elseif leader == "LOC_LEADER_MANOSABA_TONO_HANNA_NAME" then
		UI.PlaySound("Manosaba_Hanna_Trial_"..trialNum.."_"..soundSuffix.."_Voice")
	end
end

-- Expose function for use in other lua files
ExposedMembers.playCompetitionVoice = playCompetitionVoice

function getRandomNum(x, y)
	math.randomseed(os.time())
	math.random(x, y)
	math.random(x, y)
	math.random(x, y)
	return math.random(x, y)
end