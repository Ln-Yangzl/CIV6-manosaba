local FRIENDSHIP_KEY_PREFIX = "MANOSABA_FRIENDSHIP_"

Events.BuildingAddedToMap.Add(FriendshipOnBuildingConstructed)
Events.DistrictAddedToMap.Add(FriendshipOnDistrictConstructed)
Events.WonderCompleted.Add(FriendshipOnWonderCompleted)
Events.UnitAddedToMap.Add(FriendshipOnUnitAdded)
Events.DiplomacyMeet.Add(FriendshipOnDiplomacyMeet)

function AddFriendship(count, targetLeaderType)
    local pPlayer = Players[Game.GetLocalPlayer()];	
    local currentFriendship = pPlayer:GetProperty(FRIENDSHIP_KEY_PREFIX .. targetLeaderType) or 0
    pPlayer:SetProperty(FRIENDSHIP_KEY_PREFIX .. targetLeaderType, currentFriendship + count)
end

function FriendshipOnBuildingConstructed(iX, iY, buildingID, playerID, cityID, misc2, misc3)
    if playerID ~= Game.GetLocalPlayer() then return end
    local pPlayerConfig = PlayerConfigurations[playerID];
    local sLeaderType = pPlayerConfig:GetLeaderTypeName();
    if sLeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
        print("Building Constructed add sherry friendship for buidingId" .. buildingID)
        AddFriendship(5, sLeaderType)
    end
end

function FriendshipOnDistrictConstructed(playerID, districtID, cityID, iX, iY, districtType, percentComplete)
    if playerID ~= Game.GetLocalPlayer() then return end
    local pPlayerConfig = PlayerConfigurations[playerID];
    local sLeaderType = pPlayerConfig:GetLeaderTypeName();
    if sLeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
        print("District Constructed add sherry friendship for districtId" .. districtID)
        AddFriendship(10, sLeaderType)
    end
end

function FriendshipOnWonderCompleted(iX, iY, buildingIndex, playerIndex, cityID, percentComplete, iUnknown)
    if playerIndex ~= Game.GetLocalPlayer() then return end
    if percentComplete < 100 then return end
    local pPlayerConfig = PlayerConfigurations[playerIndex];
    local sLeaderType = pPlayerConfig:GetLeaderTypeName();
    if sLeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" then
        print("Wonder Completed add sherry friendship for buildingIndex" .. buildingIndex)
        AddFriendship(20, sLeaderType)
    end
end

function FriendshipOnUnitAdded(playerID, unitID)
    if playerID ~= Game.GetLocalPlayer() then return end
    local pPlayerConfig = PlayerConfigurations[playerID];
    local sLeaderType = pPlayerConfig:GetLeaderTypeName();
    if sLeaderType == "LEADER_MANOSABA_TONO_HANNA" then
        print("Unit Added add hanna friendship for unitID" .. unitID)
        local pUnit = UnitManager.GetUnit(playerID, unitID);
        if pUnit ~= nil then
            print("Unit type is " .. pUnit:GetType())
            local sUnitType = pUnit:GetType();
            if sUnitType == "UNIT_BUILDER" then
                AddFriendship(5, sLeaderType)
            end
            if sUnitType == "UNIT_SETTLER" then
                AddFriendship(10, sLeaderType)
            end
        end
    end
end

function FriendshipOnDiplomacyMeet(player1ID, player2ID)
    if player1ID ~= Game.GetLocalPlayer() then return end
    local pPlayer2Config = PlayerConfigurations[player2ID];
    local sPlayer2LeaderType = pPlayer2Config:GetLeaderTypeName();
    if sPlayer2LeaderType == "LEADER_MANOSABA_TACHIBANA_SHERRY" or sPlayer2LeaderType == "LEADER_MANOSABA_TONO_HANNA" then
        print("Diplomacy Meet add sherry friendship for meeting player2ID" .. sPlayer2LeaderType)
        AddFriendship(10, sPlayer2LeaderType)
    end
end

