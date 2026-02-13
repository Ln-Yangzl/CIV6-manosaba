-- Manosaba_Emergency_UI
-- Author: Rin
-- DateCreated: 2/13/2026 8:29:27 AM
--------------------------------------------------------------


function OnCrisisReceived(targetPlayerID, emergencyType)
	print("emergencyType:"..emergencyType)
	local pContext :table = ContextPtr:LookUpControl("/InGame/AdditionalUserInterfaces/WorldCrisisPopup/TrinketString");
	pContext:SetText("Test string");
	print("emergencyType:"..GameInfo.EmergencyAlliances[emergencyType].EmergencyType)
end




function Initialize()
	LuaEvents.NotificationPanel_EmergencyClicked.Add( OnCrisisReceived );
	LuaEvents.WorldCrisisTracker_EmergencyClicked.Add( OnCrisisReceived );
	Events.EmergencyAvailable.Add(OnCrisisReceived);
end

Events.LoadGameViewStateDone.Add(Initialize);