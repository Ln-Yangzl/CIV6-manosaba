-- Manosaba_Witch_Config_UI
-- Author: Rin
-- DateCreated: 2/1/2026 9:38:59 AM
--------------------------------------------------------------
local COST_LIST = {
	COST_0 = 100,
	COST_100 = 200,
	COST_200 = 500,
	COST_500 = 1000,
	COST_1000 = 1000
}

local PLAYER_WITCH_FACTOR_HAS_KEY = "PLAYER_WITCH_FACTOR_HAS_KEY"
local PLAYER_ACCELERATE_COST_KEY = "PLAYER_ACCELERATE_COST"
local PLAYER_SUPPRESS_COST_KEY = "PLAYER_SUPPRESS_COST"
local SUPPRESS_WITCH_TURN_KEY = "SUPPRESS_WITCH_TURN"
local ACCERERATE_WITCH_FACTOR = 100
local SUPPRESS_FACTOR_TURN = 25


function InitConfigButton()
	ContextPtr:SetHide(false);
    Controls.ManosabaWitchConfigOptions:ChangeParent(ContextPtr:LookUpControl("/InGame/ActionPanel"))
	Controls.ManosabaWitchConfigButton:RegisterCallback(Mouse.eLClick, OpenConfigModal);
end

function OpenConfigModal()
	Controls.ManosabaWitchConfigModal:SetHide(false);

	local playerID = Game.GetLocalPlayer() 
	local player = Players[playerID]
	local playerReligion		:table	= player:GetReligion();
	local faithBalance			:number = playerReligion:GetFaithBalance() or 0;
	
	local option1CostKey = player:GetProperty(PLAYER_ACCELERATE_COST_KEY) or "COST_0"
	local option1Cost = COST_LIST[option1CostKey]
	local option1ExtraText = string.format(Locale.Lookup("LOC_WITCH_MANAGER_OPTION_COST"), option1Cost)
	if faithBalance < option1Cost then
		option1ExtraText = option1ExtraText..Locale.Lookup("LOC_WITCH_MANAGER_OPTION_COST_INSUFFICIENT")
	end
	Controls.ManosabaWitchConfigCost1Text:SetString(option1ExtraText)

	local option2CostKey = player:GetProperty(PLAYER_SUPPRESS_COST_KEY) or "COST_0"
	local option2Cost = COST_LIST[option2CostKey]
	local option2ExtraText = string.format(Locale.Lookup("LOC_WITCH_MANAGER_OPTION_COST"), option2Cost)
	if faithBalance < option2Cost then
		option2ExtraText = option2ExtraText..Locale.Lookup("LOC_WITCH_MANAGER_OPTION_COST_INSUFFICIENT")
	end
	Controls.ManosabaWitchConfigCost2Text:SetString(option2ExtraText)
end

function CloseConfigModal()
	Controls.ManosabaWitchConfigModal:SetHide(true);
end

function InitConfigModal(leaderType)

	Controls.ManosabaWitchConfigModal:ChangeParent(ContextPtr:LookUpControl("/InGame"))
	Controls.ManosabaWitchConfigModal:SetHide(true);

	Controls.ManosabaWitchConfigOption3:RegisterCallback(Mouse.eLClick, CloseConfigModal);

	Controls.ManosabaWitchConfigOption1:RegisterCallback(Mouse.eLClick, AccelerateWitch);
	Controls.ManosabaWitchConfigOption2:RegisterCallback(Mouse.eLClick, SuppressWitch);

	if leaderType == "LEADER_MANOSABA_NIKAIDO_HIRO" then
		Controls.ManosabaConfigModalLeaderImage:SetTexture("IMG_MANOSABA_HIRO_CONFIG")
	elseif leaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
		Controls.ManosabaConfigModalLeaderImage:SetTexture("IMG_MANOSABA_SHERRY_CONFIG")
	end

end

function AccelerateWitch()
	local playerID = Game.GetLocalPlayer() 
	local player = Players[playerID]
	local playerReligion		:table	= player:GetReligion();
	local faithBalance			:number = playerReligion:GetFaithBalance() or 0;
	local costKey = player:GetProperty(PLAYER_ACCELERATE_COST_KEY) or "COST_0"
	local needFaith = COST_LIST[costKey]
	if faithBalance < needFaith then return; end
	ExposedMembers.WitchFactor.SavePlayerProperty(playerID, PLAYER_ACCELERATE_COST_KEY, "COST_"..needFaith)
	ExposedMembers.WitchFactor.ChangeFaithBalance(playerID, -needFaith)
	local pSavedWitchFactor = player:GetProperty(PLAYER_WITCH_FACTOR_HAS_KEY) or 0
	ExposedMembers.WitchFactor.SavePlayerProperty(playerID, PLAYER_WITCH_FACTOR_HAS_KEY, pSavedWitchFactor + ACCERERATE_WITCH_FACTOR)
	
	CloseConfigModal()
end

function SuppressWitch()
	local playerID = Game.GetLocalPlayer() 
	local player = Players[playerID]
	local playerReligion		:table	= player:GetReligion();
	local faithBalance			:number = playerReligion:GetFaithBalance() or 0;
	local costKey = player:GetProperty(PLAYER_SUPPRESS_COST_KEY) or "COST_0"
	local needFaith = COST_LIST[costKey]
	if faithBalance < needFaith then return; end
	ExposedMembers.WitchFactor.SavePlayerProperty(playerID, PLAYER_SUPPRESS_COST_KEY, "COST_"..needFaith)
	ExposedMembers.WitchFactor.ChangeFaithBalance(playerID, -needFaith)
	ExposedMembers.WitchFactor.SavePlayerProperty(playerID, SUPPRESS_WITCH_TURN_KEY, Game.GetCurrentGameTurn() + SUPPRESS_FACTOR_TURN)

	CloseConfigModal()
end


function Initialize()
	local playerID = Game.GetLocalPlayer()
	local playerConfig = PlayerConfigurations[playerID];
	local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
	local civilization = leader.CivilizationCollection[1];
	if civilization.CivilizationType == "CIVILIZATION_MANOSABA" then
		InitConfigButton()
		InitConfigModal(leader.LeaderType)
	end
end

Events.LoadGameViewStateDone.Add(Initialize);