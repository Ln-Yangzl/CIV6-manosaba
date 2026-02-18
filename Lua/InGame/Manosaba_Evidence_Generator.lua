-- Manosaba_Evidence_Generator
-- Author: Rin
-- DateCreated: 1/18/2026 4:55:32 PM
--------------------------------------------------------------

-- Evidence from competitions 1-5 (for LEADER_MANOSABA_SAKURABA_EMA)
local EVIDENCE_LIST_GROUP1 = {
	GREATWORK_MANOSABA_RIBBON = "GREATWORK_MANOSABA_RIBBON",
	GREATWORK_MANOSABA_NOA = "GREATWORK_MANOSABA_NOA",
	GREATWORK_MANOSABA_SKETCHBOOK = "GREATWORK_MANOSABA_SKETCHBOOK",
	GREATWORK_MANOSABA_LOCK = "GREATWORK_MANOSABA_LOCK",
	GREATWORK_MANOSABA_MIRIA = "GREATWORK_MANOSABA_MIRIA",
	GREATWORK_MANOSABA_SMALL_KEY = "GREATWORK_MANOSABA_SMALL_KEY",
	GREATWORK_MANOSABA_DORU_ARISA = "GREATWORK_MANOSABA_DORU_ARISA",
	GREATWORK_MANOSABA_DORU_MERURU = "GREATWORK_MANOSABA_DORU_MERURU",
	GREATWORK_MANOSABA_HANNA = "GREATWORK_MANOSABA_HANNA",
	GREATWORK_MANOSABA_ARISA = "GREATWORK_MANOSABA_ARISA",
	GREATWORK_MANOSABA_CHAIR = "GREATWORK_MANOSABA_CHAIR",
	GREATWORK_MANOSABA_DRUG = "GREATWORK_MANOSABA_DRUG",
	GREATWORK_MANOSABA_COFFER = "GREATWORK_MANOSABA_COFFER",
	GREATWORK_MANOSABA_FILE = "GREATWORK_MANOSABA_FILE",
	GREATWORK_MANOSABA_NANOKA = "GREATWORK_MANOSABA_NANOKA"
}

-- Evidence from competitions 6-9 (for other leaders)
local EVIDENCE_LIST_GROUP2 = {
	GREATWORK_MANOSABA_ALIBI = "GREATWORK_MANOSABA_ALIBI",
	GREATWORK_MANOSABA_MERURU_PHONE = "GREATWORK_MANOSABA_MERURU_PHONE",
	GREATWORK_MANOSABA_MERURU = "GREATWORK_MANOSABA_MERURU",
	GREATWORK_MANOSABA_PAPER = "GREATWORK_MANOSABA_PAPER",
	GREATWORK_MANOSABA_KOKO_PHONE = "GREATWORK_MANOSABA_KOKO_PHONE",
	GREATWORK_MANOSABA_KOKO = "GREATWORK_MANOSABA_KOKO",
	GREATWORK_MANOSABA_NOA_ATELIER = "GREATWORK_MANOSABA_NOA_ATELIER",
	GREATWORK_MANOSABA_ANAN = "GREATWORK_MANOSABA_ANAN",
	GREATWORK_MANOSABA_ANAN_PHONE = "GREATWORK_MANOSABA_ANAN_PHONE",
	GREATWORK_MANOSABA_REIA = "GREATWORK_MANOSABA_REIA",
	GREATWORK_MANOSABA_EMA = "GREATWORK_MANOSABA_EMA",
	GREATWORK_MANOSABA_DRESS = "GREATWORK_MANOSABA_DRESS"
}
local GREAT_WORK_MANOSABA_EVIDENCE_TYPE:string = "GREATWORKOBJECT_MANOSABA_EVIDENCE"
local GRANTED_EVIDENCE_TABLE_KEY = "GRANTED_EVIDENCE_TABLE"
local previousGrantTurn = 0
local localPlayerTurnActivate = false

Events.LocalPlayerTurnBegin.Add(function()
	localPlayerTurnActivate = true
end);

Events.LocalPlayerTurnEnd.Add(function()
	localPlayerTurnActivate = false
end);

function TechOrCivicBoost(playerID)
	-- This function is kept for compatibility but now uses the updated GrantManosabaLocalPlayerEvidence logic
	GrantManosabaLocalPlayerEvidence(playerID)
end

function GrantEvidence(playerID, evidenceList)
	-- when not player turn, do not grant evidence
	if localPlayerTurnActivate == false then return; end
	local pPlayer = Players[playerID];	
	local evidenceCanGrant = {}
	local evidenceHasGrant = pPlayer:GetProperty(GRANTED_EVIDENCE_TABLE_KEY)
	if evidenceHasGrant == nil then
		evidenceHasGrant = {}
	end

	for k,v in pairs(evidenceList) do
		if evidenceHasGrant[k] == nil then
			table.insert(evidenceCanGrant, v)
		end
	end
	if GetTableSize(evidenceCanGrant) == 0 then return end
	print("start grant")
	local grantEvidence = evidenceCanGrant[math.random(1, GetTableSize(evidenceCanGrant))]
	local evidenceName = grantEvidence:gsub("GREATWORK_", "")
	local individual = GameInfo.GreatPersonIndividuals["GREAT_PERSON_INDIVIDUAL_"..evidenceName.."_GENERATOR"].Hash;
	local class = GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_MANOSABA_GENERATOR"].Hash;
	local era = GameInfo.Eras["ERA_RENAISSANCE"].Hash;
	local cost = 0;
	print(individual)
	Game.GetGreatPeople():GrantPerson(individual, class, era, cost, playerID, false);
	evidenceHasGrant[grantEvidence] = grantEvidence
	pPlayer:SetProperty(GRANTED_EVIDENCE_TABLE_KEY, evidenceHasGrant)
end

function GrantManosabaLocalPlayerEvidence(playerID)
	local pPlayer = Players[playerID];
	local playerCities = pPlayer:GetCities()
	local capitalCity = playerCities:GetCapitalCity()
	-- do not grant when player's capital city not found yet
	if capitalCity == nil then return; end

	local pPlayerConfig = PlayerConfigurations[playerID];
	local turn = Game.GetCurrentGameTurn()
	if pPlayerConfig == nil then return; end
	local sLeaderType = pPlayerConfig:GetLeaderTypeName();
	if string.find(sLeaderType, "LEADER_MANOSABA") and Game.GetLocalPlayer() == playerID then
		-- avoid muti grant great person in one turn
		if turn == previousGrantTurn then return; end
		previousGrantTurn = turn
		local randomNum = math.random(1, 3)
		--local randomNum = 1
		if randomNum == 1 then
			-- Grant Group1 evidence for LEADER_MANOSABA_SAKURABA_EMA
			if sLeaderType == "LEADER_MANOSABA_SAKURABA_EMA" then
				GrantEvidence(playerID, EVIDENCE_LIST_GROUP1)
			-- Grant Group2 evidence for other Manosaba leaders
			elseif sLeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" or 
			       sLeaderType == "LEADER_MANOSABA_TONO_HANNA" or 
			       sLeaderType == "LEADER_MANOSABA_NIKAIDO_HIRO" then
				GrantEvidence(playerID, EVIDENCE_LIST_GROUP2)
			end
		end
	end

end

Events.CivicBoostTriggered.Add(GrantManosabaLocalPlayerEvidence);
Events.TechBoostTriggered.Add(GrantManosabaLocalPlayerEvidence);

function GetTableSize(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

