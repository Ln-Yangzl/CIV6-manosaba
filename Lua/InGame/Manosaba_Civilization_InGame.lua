-- Manosaba_Civilization_InGame
-- Author: Rin
-- DateCreated: 1/13/2026 7:13:43 PM
--------------------------------------------------------------
ExposedMembers.GameEvents = GameEvents

local GRANTED_EVIDENCE_TABLE_KEY = "GRANTED_EVIDENCE_TABLE"
local PLAYER_EVIDENCE_USED_KEY = "EVIDENCE_USED_TABLE"
local COMPETITION_TYPE_KEY = "MANOSABA_COMPETITION_TYPE"

local m_ManosabaCompetition1 = GameInfo.EmergencyAlliances and GameInfo.EmergencyAlliances['EMERGENCY_MANOSABA_COMPETITION_1']
local m_ManosabaCompetition6 = GameInfo.EmergencyAlliances and GameInfo.EmergencyAlliances['EMERGENCY_MANOSABA_COMPETITION_6']
local m_ManosabaCompetition7 = GameInfo.EmergencyAlliances and GameInfo.EmergencyAlliances['EMERGENCY_MANOSABA_COMPETITION_7']
local m_ManosabaCompetition8 = GameInfo.EmergencyAlliances and GameInfo.EmergencyAlliances['EMERGENCY_MANOSABA_COMPETITION_8']
local m_ManosabaCompetition9 = GameInfo.EmergencyAlliances and GameInfo.EmergencyAlliances['EMERGENCY_MANOSABA_COMPETITION_9']

local m_EmergencyGreatPersonClass = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_MANOSABA_EMERGENCY']
local m_EmergencyGreatPersonClass6 = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_MANOSABA_EMERGENCY_6']
local m_EmergencyGreatPersonClass7 = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_MANOSABA_EMERGENCY_7']
local m_EmergencyGreatPersonClass8 = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_MANOSABA_EMERGENCY_8']
local m_EmergencyGreatPersonClass9 = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_MANOSABA_EMERGENCY_9']

local m_ProjectTrailAgree = GameInfo.Projects["PROJECT_MANOSABA_TRIAL_AGREE"]
local m_ProjectTrailReasoning = GameInfo.Projects["PROJECT_MANOSABA_TRIAL_REASONING"]
local m_ProjectTrailSubmitEvidence = GameInfo.Projects["PROJECT_MANOSABA_TRIAL_SUBMIT_EVIDENCE"]
local m_ProjectTrailPerjury = GameInfo.Projects["PROJECT_MANOSABA_TRIAL_PERJURY"]

local activeBuildingCompleteTurn = 0

local SUBMIT_EVIDENCE_SCOURE = 200

local COMPETITION_VALID_EVIDENCE_TABLE = {
	EMERGENCY_MANOSABA_COMPETITION_1 = {
		GREATWORK_MANOSABA_RIBBON = "GREATWORK_MANOSABA_RIBBON"
	},
	EMERGENCY_MANOSABA_COMPETITION_2 = {
		GREATWORK_MANOSABA_LOCK = "GREATWORK_MANOSABA_LOCK"
	},
	EMERGENCY_MANOSABA_COMPETITION_6 = {
		GREATWORK_MANOSABA_ALIBI = "GREATWORK_MANOSABA_ALIBI",
		GREATWORK_MANOSABA_MERURU_PHONE = "GREATWORK_MANOSABA_MERURU_PHONE",
		GREATWORK_MANOSABA_MERURU = "GREATWORK_MANOSABA_MERURU"
	},
	EMERGENCY_MANOSABA_COMPETITION_7 = {
		GREATWORK_MANOSABA_PAPER = "GREATWORK_MANOSABA_PAPER",
		GREATWORK_MANOSABA_KOKO_PHONE = "GREATWORK_MANOSABA_KOKO_PHONE",
		GREATWORK_MANOSABA_KOKO = "GREATWORK_MANOSABA_KOKO"
	},
	EMERGENCY_MANOSABA_COMPETITION_8 = {
		GREATWORK_MANOSABA_NOA_ATELIER = "GREATWORK_MANOSABA_NOA_ATELIER",
		GREATWORK_MANOSABA_ANAN = "GREATWORK_MANOSABA_ANAN",
		GREATWORK_MANOSABA_ANAN_PHONE = "GREATWORK_MANOSABA_ANAN_PHONE"
	},
	EMERGENCY_MANOSABA_COMPETITION_9 = {
		GREATWORK_MANOSABA_REIA = "GREATWORK_MANOSABA_REIA",
		GREATWORK_MANOSABA_EMA = "GREATWORK_MANOSABA_EMA",
		GREATWORK_MANOSABA_DRESS = "GREATWORK_MANOSABA_DRESS"
	}
}

-- Generate scout when BUILDING_CIVILIZATION_MANOSABA_PRISON_ISLAND constructed
GameEvents.BuildingConstructed.Add(function(playerID, cityID, buildingID, plotID, bOriginalConstruction)
	if Game.GetLocalPlayer() == playerID then
		if GameInfo.Buildings[buildingID].Name == "LOC_BUILDING_CIVILIZATION_MANOSABA_PRISON_ISLAND_NAME" then
			local capital_x = Players[0]:GetCities():GetCapitalCity():GetX()
			local capital_y = Players[0]:GetCities():GetCapitalCity():GetY()

			UnitManager.InitUnit(playerID, "UNIT_SCOUT", capital_x, capital_y);
		end
	end
end)


function EmergencyAddAiRandomPointsInner(greatPersonID)
	for _, playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
		if Game.GetLocalPlayer() ~= playerID then
			local randomStrategy = getRandomNum(1, 15)
			if randomStrategy == 1 or randomStrategy == 2 or randomStrategy == 3 then
				OnCompetitionProjectFinishInner(playerID, m_ProjectTrailReasoning.Index, greatPersonID)
			end
			if randomStrategy == 4 then
				OnCompetitionProjectFinishInner(playerID, m_ProjectTrailAgree.Index, greatPersonID)
			end
			--if randomStrategy == 5 then
				---- Mock AI submit evidence
				--OnCompetitionProjectFinishInner(playerID, m_ProjectTrailPerjury.Index, greatPersonID)
				--OnCompetitionProjectFinishInner(playerID, m_ProjectTrailPerjury.Index, greatPersonID)
			--end
		end
	end
end

function EmergencyAddAiRandomPoints()
	EmergencyAddAiRandomPointsInner(m_EmergencyGreatPersonClass.Index)
end
function EmergencyAddAiRandomPoints6()
	EmergencyAddAiRandomPointsInner(m_EmergencyGreatPersonClass6.Index)
end
function EmergencyAddAiRandomPoints7()
	EmergencyAddAiRandomPointsInner(m_EmergencyGreatPersonClass7.Index)
end
function EmergencyAddAiRandomPoints8()
	EmergencyAddAiRandomPointsInner(m_EmergencyGreatPersonClass8.Index)
end
function EmergencyAddAiRandomPoints9()
	EmergencyAddAiRandomPointsInner(m_EmergencyGreatPersonClass9.Index)
end

function OnEmergencyAvailable(targetPlayerID:number, emergencyID:number, startingTurn:number)
	local turn = Game.GetCurrentGameTurn()
	local currentCompetitionType = Game:GetProperty(COMPETITION_TYPE_KEY)
	print("competition start, emergencyID:"..emergencyID)
	if m_ManosabaCompetition1 and emergencyID == m_ManosabaCompetition1.Index then
		-- start of this competition
		if currentCompetitionType ~= m_ManosabaCompetition1.EmergencyType then
			print("competition m_ManosabaCompetition1 start")
			Events.TurnEnd.Add(EmergencyAddAiRandomPoints)
			Events.CityProjectCompleted.Add(OnCompetition1ProjectFinish)
		else
		-- end of this competition
			print("competition m_ManosabaCompetition1 end")
			Events.TurnEnd.Remove(EmergencyAddAiRandomPoints)
			Events.CityProjectCompleted.Remove(OnCompetition1ProjectFinish)
		end
		Game:SetProperty(COMPETITION_TYPE_KEY, m_ManosabaCompetition1.EmergencyType)
	end
	if m_ManosabaCompetition6 and emergencyID == m_ManosabaCompetition6.Index then
		-- start of this competition
		if currentCompetitionType ~= m_ManosabaCompetition6.EmergencyType then
			print("competition m_ManosabaCompetition6 start")
			Events.TurnEnd.Add(EmergencyAddAiRandomPoints6)
			Events.CityProjectCompleted.Add(OnCompetition6ProjectFinish)
		else
		-- end of this competition
			print("competition m_ManosabaCompetition6 end")
			Events.TurnEnd.Remove(EmergencyAddAiRandomPoints6)
			Events.CityProjectCompleted.Remove(OnCompetition6ProjectFinish)
		end
		Game:SetProperty(COMPETITION_TYPE_KEY, m_ManosabaCompetition6.EmergencyType)
	end
	if m_ManosabaCompetition7 and emergencyID == m_ManosabaCompetition7.Index then
		-- start of this competition
		if currentCompetitionType ~= m_ManosabaCompetition7.EmergencyType then
			print("competition m_ManosabaCompetition7 start")
			Events.TurnEnd.Add(EmergencyAddAiRandomPoints7)
			Events.CityProjectCompleted.Add(OnCompetition7ProjectFinish)
		else
		-- end of this competition
			print("competition m_ManosabaCompetition7 end")
			Events.TurnEnd.Remove(EmergencyAddAiRandomPoints7)
			Events.CityProjectCompleted.Remove(OnCompetition7ProjectFinish)
		end
		Game:SetProperty(COMPETITION_TYPE_KEY, m_ManosabaCompetition7.EmergencyType)
	end
	if m_ManosabaCompetition8 and emergencyID == m_ManosabaCompetition8.Index then
		-- start of this competition
		if currentCompetitionType ~= m_ManosabaCompetition8.EmergencyType then
			print("competition m_ManosabaCompetition8 start")
			Events.TurnEnd.Add(EmergencyAddAiRandomPoints8)
			Events.CityProjectCompleted.Add(OnCompetition8ProjectFinish)
		else
		-- end of this competition
			print("competition m_ManosabaCompetition8 end")
			Events.TurnEnd.Remove(EmergencyAddAiRandomPoints8)
			Events.CityProjectCompleted.Remove(OnCompetition8ProjectFinish)
			local maxPointPlayer = GetMaxPointPlayer(m_EmergencyGreatPersonClass8.Index, nil)
			print('maxPointPlayer:'..maxPointPlayer)
			OnManosabaBuildingProduction(maxPointPlayer)
		end
		Game:SetProperty(COMPETITION_TYPE_KEY, m_ManosabaCompetition8.EmergencyType)
	end
	if m_ManosabaCompetition9 and emergencyID == m_ManosabaCompetition9.Index then
		-- start of this competition
		if currentCompetitionType ~= m_ManosabaCompetition9.EmergencyType then
			print("competition m_ManosabaCompetition9 start")
			Events.TurnEnd.Add(EmergencyAddAiRandomPoints9)
			Events.CityProjectCompleted.Add(OnCompetition9ProjectFinish)
		else
		-- end of this competition
			print("competition m_ManosabaCompetition9 end")
			Events.TurnEnd.Remove(EmergencyAddAiRandomPoints9)
			Events.CityProjectCompleted.Remove(OnCompetition9ProjectFinish)
		end
		Game:SetProperty(COMPETITION_TYPE_KEY, m_ManosabaCompetition9.EmergencyType)
	end
end

Events.EmergencyAvailable.Add(OnEmergencyAvailable)

function OnManosabaBuildingProduction(playerId)
    local player = Players[playerId]
    if not player then return end
	print("OnManosabaBuildingProduction start")
    --if activeBuildingCompleteTurn ~= Game.GetCurrentGameTurn() then
        --return
    --end

    -- 后续逻辑保持不变...
    --local city = player:GetCities():FindID(cityId)
    --if not city then return end
	for i, city in player:GetCities():Members() do
		local buildQueue = city:GetBuildQueue()
		if not buildQueue then return end

		local currentProduction = buildQueue:CurrentlyBuilding()
		if not currentProduction then return end

		-- 检查是否为建筑或区域
		local buildingInfo = GameInfo.Buildings[currentProduction]
		local districtInfo = GameInfo.Districts[currentProduction]

		-- 排除奇观
		if buildingInfo and buildingInfo.IsWonder then
			return
		end

		if not buildingInfo and not districtInfo then
			return
		end

		-- 立即完成建造
		buildQueue:FinishProgress()

		---- 添加通知和音效
		--local itemName = buildingInfo and Locale.Lookup(buildingInfo.Name) or
						 --districtInfo and Locale.Lookup(districtInfo.Name) or "未知项目"
--
		--local message = Locale.Lookup("立即完成{1}建造！", itemName)
		--Game.AddWorldViewText(playerId, message, city:GetX(), city:GetY())
		print("INFO: MANOSABA construct:", currentProduction)
	end

    
end

--Events.CityProductionChanged.Add(OnManosabaBuildingProduction)



function AddPlayerPoint(playerID, greatPersonID, point)
	local currentPoint = Players[playerID]:GetGreatPeoplePoints():GetPointsTotal(greatPersonID)
	if currentPoint == nil then
		currentPoint = 0
	end
	Players[playerID]:GetGreatPeoplePoints():SetPointsTotal(greatPersonID, currentPoint + point)
end

function GetMaxPointPlayer(greatPersonID, excludeSelfPlayerId)
	local localPlayerId = Game.GetLocalPlayer()
	local maxPlayerId = localPlayerId
	local max = 0
	for _, playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
		local currentPoint = Players[playerID]:GetGreatPeoplePoints():GetPointsTotal(greatPersonID)
		if currentPoint ~= nil and currentPoint >= max and playerID ~= excludeSelfPlayerId then
			max = currentPoint
			maxPlayerId = playerID
		end
	end
	return maxPlayerId
end

function GetMaxPoint(greatPersonID, excludeSelfPlayerId)
	local maxPlayerId = GetMaxPointPlayer(greatPersonID, excludeSelfPlayerId)
	return Players[maxPlayerId]:GetGreatPeoplePoints():GetPointsTotal(greatPersonID)
end



function OnCompetition1ProjectFinish(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
	OnCompetitionProjectFinishInner(playerID, projectID, m_EmergencyGreatPersonClass.Index)
end

function OnCompetition6ProjectFinish(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
	OnCompetitionProjectFinishInner(playerID, projectID, m_EmergencyGreatPersonClass6.Index)
end
function OnCompetition7ProjectFinish(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
	OnCompetitionProjectFinishInner(playerID, projectID, m_EmergencyGreatPersonClass7.Index)
end
function OnCompetition8ProjectFinish(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
	OnCompetitionProjectFinishInner(playerID, projectID, m_EmergencyGreatPersonClass8.Index)
end
function OnCompetition9ProjectFinish(playerID, cityID, projectID, buildingIndex, iX, iY, bCancelled)
	OnCompetitionProjectFinishInner(playerID, projectID, m_EmergencyGreatPersonClass9.Index)
end

function OnCompetitionProjectFinishInner(playerID, projectID, greatPersonID)
	print("OnCompetitionProjectFinishInner")
	local pPlayer = Players[playerID];	
	if projectID == m_ProjectTrailAgree.Index then
		AddPlayerPoint(playerID, greatPersonID, GetMaxPoint(m_EmergencyGreatPersonClass.Index, playerID) * 0.25)
	end
	if projectID == m_ProjectTrailReasoning.Index then
		AddPlayerPoint(playerID, greatPersonID, getRandomNum(1, 50))
	end
	if projectID == m_ProjectTrailPerjury.Index then
		AddPlayerPoint(playerID, greatPersonID, 100)
	end
	if projectID == m_ProjectTrailSubmitEvidence.Index then
		print("m_ProjectTrailSubmitEvidence:"..Game:GetProperty(COMPETITION_TYPE_KEY))
		local validEvidience = COMPETITION_VALID_EVIDENCE_TABLE[Game:GetProperty(COMPETITION_TYPE_KEY)]
		local evidenceHas = pPlayer:GetProperty(GRANTED_EVIDENCE_TABLE_KEY)
		local evidenceUsed = pPlayer:GetProperty(PLAYER_EVIDENCE_USED_KEY)
		if evidenceUsed == nil then
			evidenceUsed = {}
		end
		if evidenceHas == nil then
			evidenceHas = {}
		end
		for k,v in pairs(evidenceHas) do
			print("current has evidence:"..k)
			if evidenceUsed[k] ~= nil then
			elseif validEvidience[k] ~= nil then
				AddPlayerPoint(playerID, greatPersonID, 200)
				evidenceUsed[k] = v
				pPlayer:SetProperty(PLAYER_EVIDENCE_USED_KEY, evidenceUsed)
			end
		end
	end
end


function getRandomNum(x, y)
	return math.random(x, y)
end