-- Manosaba_Friendship_UI
-- Author: Rin
-- DateCreated: 2/13/2026 1:00:47 PM
--------------------------------------------------------------
local m_FriendshipState:number		= 0;



function OnPanelTitleClicked()
    if(m_FriendshipState == 0) then
        Controls.ManosabaFriendship:SetSizeY(235);
        Controls.FriendshipStackMIN:SetHide(false);
        m_FriendshipState = 1;
    else
        Controls.ManosabaFriendship:SetSizeY(25);
        Controls.FriendshipStackMIN:SetHide(true);
        m_FriendshipState = 0;
    end
end

function OnLoadGameViewStateDone()
	local worldTrackerPanel:table = ContextPtr:LookUpControl("/InGame/WorldTracker/PanelStack");
    if (worldTrackerPanel ~= nil) then
        Controls.ManosabaFriendship:ChangeParent(worldTrackerPanel);
        worldTrackerPanel:AddChildAtIndex(Controls.ManosabaFriendship, 1);
        worldTrackerPanel:CalculateSize();
        worldTrackerPanel:ReprocessAnchoring();
        m_IsAttached = true;
    end
    Controls.HeaderTitle:RegisterCallback(Mouse.eLClick, OnPanelTitleClicked);
	Controls.HannaFriendshipBar:SetPercent(0.5)
	Controls.SherryFriendshipBar:SetPercent(1)
end

function Initialize()
	Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone);
end
Initialize();