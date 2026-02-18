-- Manosaba_Emergency_UI
-- Author: Rin
-- DateCreated: 2/13/2026 8:29:27 AM
--------------------------------------------------------------

-- Change emergency summary text for different leader.
function OnCrisisReceived(targetPlayerID, emergencyType)
	local pPlayerConfig = PlayerConfigurations[Game.GetLocalPlayer()];
    local sLeaderType = pPlayerConfig:GetLeaderTypeName();
	print("OnCrisisReceived emergencyType:"..GameInfo.EmergencyAlliances[emergencyType].EmergencyType)
	local pContext :table = ContextPtr:LookUpControl("/InGame/AdditionalUserInterfaces/WorldCrisisPopup/TrinketString");
	
	if sLeaderType == "LEADER_MANOSABA_SAKURABA_EMA" then
		local emergencyTypeString = GameInfo.EmergencyAlliances[emergencyType].EmergencyType;
		local locKey = "";
		
		if emergencyTypeString == "EMERGENCY_MANOSABA_COMPETITION_6" then
			locKey = "LOC_WORLD_CONGRESS_MANOSABA_COMPETITION_1_SUMMARY";
		elseif emergencyTypeString == "EMERGENCY_MANOSABA_COMPETITION_7" then
			locKey = "LOC_WORLD_CONGRESS_MANOSABA_COMPETITION_2_SUMMARY";
		elseif emergencyTypeString == "EMERGENCY_MANOSABA_COMPETITION_8" then
			locKey = "LOC_WORLD_CONGRESS_MANOSABA_COMPETITION_3_SUMMARY";
		elseif emergencyTypeString == "EMERGENCY_MANOSABA_COMPETITION_9" then
			locKey = "LOC_WORLD_CONGRESS_MANOSABA_COMPETITION_4_SUMMARY";
		end
		
		if locKey ~= "" then
			local summary = Locale.Lookup(locKey);
			pContext:SetText(summary);
		end
	end
	
	
end




function Initialize()
	LuaEvents.NotificationPanel_EmergencyClicked.Add( OnCrisisReceived );
	LuaEvents.WorldCrisisTracker_EmergencyClicked.Add( OnCrisisReceived );
	Events.EmergencyAvailable.Add(OnCrisisReceived);
end

Events.LoadGameViewStateDone.Add(Initialize);