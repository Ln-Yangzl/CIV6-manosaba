-- Manosaba_Leader_NikaidoHiro_InGame
-- Author: Rin
-- DateCreated: 1/15/2026 8:20:54 PM
--------------------------------------------------------------


-- Grant greate people to get init greate work
function GrantManosabaNikaidoHiroGreatePeople(playerID: number, cityID : number, cityX : number, cityY : number )

	local pPlayerConfig = PlayerConfigurations[playerID];
	if pPlayerConfig == nil then return; end

	local sLeaderType = pPlayerConfig:GetLeaderTypeName();
	if sLeaderType == "LEADER_MANOSABA_NIKAIDO_HIRO" then
		local pPlayer = Players[playerID];	
		if pPlayer:GetProperty("GREAT_PERSON_INDIVIDUAL_MANOSABA_PEN_GENERATOR") == nil then
			local individual = GameInfo.GreatPersonIndividuals["GREAT_PERSON_INDIVIDUAL_MANOSABA_PEN_GENERATOR"].Hash;
			local class = GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_MANOSABA_GENERATOR"].Hash;
			local era = GameInfo.Eras["ERA_RENAISSANCE"].Hash;
			local cost = 0;
			Game.GetGreatPeople():GrantPerson(individual, class, era, cost, playerID, false);
			pPlayer:SetProperty("GREAT_PERSON_INDIVIDUAL_MANOSABA_PEN_GENERATOR", true);
		end
	end
end

GameEvents.CityBuilt.Add( GrantManosabaNikaidoHiroGreatePeople );