-- Manosaba_Friendship_UI
-- Author: Rin
-- DateCreated: 2/13/2026 1:00:47 PM
--------------------------------------------------------------
local FRIENDSHIP_KEY_PREFIX = "MANOSABA_FRIENDSHIP_"
local FRIENDSHIP_ACTIVE_KEY_PREFIX = "MANOSABA_FRIENDSHIP_ACTIVE_"

-- Leader Configuration Table - Add new leaders here
local LEADERS_CONFIG = {
    {
        leaderId = "LEADER_MANOSABA_TACHIBANA_SHERRY",
        controlName = "SherryFriendshipBar",
        magicImageControlName = "SherryMagicImage"
    },
    {
        leaderId = "LEADER_MANOSABA_TONO_HANNA", 
        controlName = "HannaFriendshipBar",
        magicImageControlName = "HannaMagicImage"
    }
}

-- Configuration constants
local MAX_FRIENDSHIP = 100  -- Maximum friendship value for percentage calculations

local m_FriendshipState:number		= 0;

-- Calculate friendship percentage for a given leader
function CalculateFriendshipPercent(friendship)
    -- Calculate percentage value (clamped between 0 and 1)
    local friendshipPercent = math.min(friendship / MAX_FRIENDSHIP, 1.0)
    
    -- Round percentage to two decimal places
    friendshipPercent = math.floor(friendshipPercent * 100 + 0.5) / 100
    
    return friendshipPercent
end



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
    local playerID = Game.GetLocalPlayer()
	local playerConfig = PlayerConfigurations[playerID];
	local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
	local worldTrackerPanel:table = ContextPtr:LookUpControl("/InGame/WorldTracker/PanelStack");
    local inGame:table = ContextPtr:LookUpControl("/InGame");
    if (worldTrackerPanel ~= nil) then
        Controls.ManosabaFriendship:ChangeParent(worldTrackerPanel);
        worldTrackerPanel:AddChildAtIndex(Controls.ManosabaFriendship, 1);
        worldTrackerPanel:CalculateSize();
        worldTrackerPanel:ReprocessAnchoring();
        
    end
    if (inGame ~= nil) then
        Controls.ManosabaFriendshipModal:ChangeParent(inGame);
    end
    Controls.HeaderTitle:RegisterCallback(Mouse.eLClick, OnPanelTitleClicked);

    -- Hide friendship controls for self leader
    if leader.LeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
        Controls.TachibanaSherry:SetHide(true);
    end
    if leader.LeaderType == "LEADER_MANOSABA_TONO_HANNA" then
        Controls.TonoHanna:SetHide(true);
    end
	
    RefreshFriendship()
end

function ShowFriendshipModal(secondaryLeaderType)
    local playerID = Game.GetLocalPlayer()
	local playerConfig = PlayerConfigurations[playerID];
	local leader = GameInfo.Leaders[playerConfig:GetLeaderTypeID()];
    Controls.ManosabaFriendshipModalPrimaryLeaderImage:SetTexture(GetLeaderModalImg(leader.LeaderType));
    Controls.ManosabaFriendshipModalSecondaryLeaderImage:SetTexture(GetLeaderModalImg(secondaryLeaderType));
    Controls.ManosabaFriendshipModal:SetHide(false);
    Controls.ManosabaFriendshipOption1:RegisterCallback(Mouse.eLClick, function() ActivateFriendshipMagic(secondaryLeaderType) end);
    Controls.ManosabaFriendshipOption2:RegisterCallback(Mouse.eLClick, function() Controls.ManosabaFriendshipModal:SetHide(true) end);
end

function ActivateFriendshipMagic(leaderType)
    print("Activating friendship magic for " .. leaderType);
    Controls.ManosabaFriendshipModal:SetHide(true)
    local leaderConfig = GetLeaderConfig(leaderType)
    if leaderConfig and leaderConfig.magicImageControlName then
        Controls[leaderConfig.magicImageControlName]:SetHide(true)
        ExposedMembers.WitchFactor.SavePlayerProperty(Game.GetLocalPlayer(), FRIENDSHIP_ACTIVE_KEY_PREFIX .. leaderType, true)
    end
    -- TODO: Add sound for magic activation
    -- TODO: Add magic activate logic
end

function GetLeaderConfig(leaderType)
    for _, config in ipairs(LEADERS_CONFIG) do
        if config.leaderId == leaderType then
            return config
        end
    end
    return nil
end

function GetLeaderModalImg(LeaderType)
    if LeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
        return "IMG_MANOSABA_SHERRY_CONFIG";
    elseif LeaderType == "LEADER_MANOSABA_TONO_HANNA" then
        return "IMG_MANOSABA_HANNA_CONFIG";
    else
        return "IMG_MANOSABA_HIRO_CONFIG"; 
    end
end

function RefreshFriendship()
    local pPlayer = Players[Game.GetLocalPlayer()];
    local pPlayerConfig = PlayerConfigurations[Game.GetLocalPlayer()];
    
    -- Iterate through all configured leaders
    for _, leaderConfig in ipairs(LEADERS_CONFIG) do
        -- Get friendship value for this leader
        local friendship = pPlayer:GetProperty(FRIENDSHIP_KEY_PREFIX .. leaderConfig.leaderId) or 0
        
        -- Calculate friendship percentage for this leader
        local friendshipPercent = CalculateFriendshipPercent(friendship)
        
        -- Update the friendship bar for this leader
        if Controls[leaderConfig.controlName] then
            Controls[leaderConfig.controlName]:SetPercent(friendshipPercent)
        else
            print("Warning: Control " .. leaderConfig.controlName .. " not found for leader " .. leaderConfig.leaderId)
        end
        
        -- Show magic image when friendship reaches 100%
        if friendship >= MAX_FRIENDSHIP and leaderConfig.magicImageControlName then
            if Controls[leaderConfig.magicImageControlName] and pPlayer:GetProperty(FRIENDSHIP_ACTIVE_KEY_PREFIX .. leaderConfig.leaderId) ~= true then
                Controls[leaderConfig.magicImageControlName]:SetHide(false)
            end
        end
        
        -- Print debug information
        print(leaderConfig.leaderId .. " Friendship: " .. friendship .. " (" .. (friendshipPercent * 100) .. "%)")
    end
end

function Initialize()
	Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone);
    ExposedMembers.GameEvents.OnGameTurnStarted.Add(RefreshFriendship);
end
Initialize();