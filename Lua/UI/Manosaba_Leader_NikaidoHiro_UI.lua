-- Manosaba_Leader_NikaidoHiro_UI
-- Author: Rin
-- DateCreated: 1/15/2026 9:05:12 PM
--------------------------------------------------------------


local DB_UNITCOMMAND_ACTIVATE_GREAT_PERSON = GameInfo.UnitCommands['UNITCOMMAND_ACTIVATE_GREAT_PERSON'];
local DB_UNITCOMMAND_DELETE = GameInfo.UnitCommands['UNITCOMMAND_DELETE'];

local capitalX = nil
local capitalY = nil

-- Activate greate person to get greate work
function ActivateManosabaNikaidoHiroGreatePeople( playerID: number, unitID : number, unitX : number, unitY : number )
	if Game.GetLocalPlayer() ~= playerID then return; end
	local pUnit = UnitManager.GetUnit(playerID, unitID);
	local sUnitName = pUnit:GetName();
	if string.find(sUnitName, "LOC_GREAT_PERSON_INDIVIDUAL_MANOSABA") then
		-- save capital pos incase great person generated pos changed
		if capitalX == nil or capitalY == nil then
			capitalX = unitX
			capitalY = unitY
		-- move to capital when generator not born in capital
		elseif capitalX ~= unitX and capitalY ~= unitY then
			print("Move generator from "..unitX..","..unitY.." To "..capitalX..","..capitalY)
			local tParameters:table = {};
			tParameters[UnitOperationTypes.PARAM_X] = plotX;
			tParameters[UnitOperationTypes.PARAM_Y] = plotY;
			UnitManager.RequestOperation(pUnit, UnitOperationTypes.MOVE_TO, tParameters);
		end
		local pCapitalCity = CityManager.GetCityAt(capitalX, capitalY)
		-- allow hiro pen generator when capital created
		if CapitalCenterSlotValid(pCapitalCity) or MakeCapitalCenterSlotValid(pCapitalCity) or sUnitName == "LOC_GREAT_PERSON_INDIVIDUAL_MANOSABA_PEN_GENERATOR_NAME" then
			print("Generator Activated!")
			UnitManager.RequestCommand( pUnit, DB_UNITCOMMAND_ACTIVATE_GREAT_PERSON.Hash );
		else
			print("Generator Deleted!")
			UnitManager.RequestCommand( pUnit, DB_UNITCOMMAND_DELETE.Hash );
		end
	end
end
Events.UnitAddedToMap.Add( ActivateManosabaNikaidoHiroGreatePeople );

function CapitalCenterSlotValid(pCity)
	if pCity == nil then return; end
	local pCityBldgs:table = pCity:GetBuildings();
	for buildingInfo in GameInfo.Buildings() do
		local buildingIndex:number = buildingInfo.Index;
		local buildingType:string = buildingInfo.BuildingType;
		if buildingType == 'BUILDING_PALACE' and pCityBldgs:HasBuilding(buildingIndex) then
			local numSlots:number = pCityBldgs:GetNumGreatWorkSlots(buildingIndex);
			if (numSlots ~= nil and numSlots > 0) then
				for index:number=0, numSlots - 1 do
					local greatWorkIndex:number = pCityBldgs:GetGreatWorkInSlot(buildingIndex, index);
					-- slot valid
					if greatWorkIndex == -1 then
						return true
					end
				end
			end
		end
	end
	return false	
end

function MakeCapitalCenterSlotValid(pCapitalCity)
	local playerID = Game.GetLocalPlayer() 
	local cities = Players[playerID]:GetCities()
	if cities == nil or pCapitalCity == nil then
		return false;
	end
	local buildingPalaceID = nil
	local srcGreatWorkID = nil
	for buildingInfo in GameInfo.Buildings() do
		local buildingIndex:number = buildingInfo.Index;
		local buildingType:string = buildingInfo.BuildingType;
		if buildingType == 'BUILDING_PALACE' then
			buildingPalaceID = buildingIndex
			srcGreatWorkID = pCapitalCity:GetBuildings():GetGreatWorkInSlot(buildingPalaceID, 0);
		end
	end

	-- find a valid city and building
	for i, pCity in cities:Members() do
		local pCityBldgs:table = pCity:GetBuildings();
		for buildingInfo in GameInfo.Buildings() do
			local buildingIndex:number = buildingInfo.Index;
			local buildingType:string = buildingInfo.BuildingType;
			if buildingType ~= 'BUILDING_PALACE' and pCityBldgs:HasBuilding(buildingIndex) then
				local numSlots:number = pCityBldgs:GetNumGreatWorkSlots(buildingIndex);
				if (numSlots ~= nil and numSlots > 0) then
					for index:number=0, numSlots - 1 do
						local greatWorkIndex:number = pCityBldgs:GetGreatWorkInSlot(buildingIndex, index);
						-- slot valid
						if greatWorkIndex == -1 then
							print("move from city"..pCapitalCity:GetID().." buildingPalaceID to "..pCity:GetID().." "..buildingIndex)
							-- move great work
							local tParameters = {};
							tParameters[PlayerOperations.PARAM_PLAYER_ONE] = Game.GetLocalPlayer();
							tParameters[PlayerOperations.PARAM_CITY_SRC] = pCapitalCity:GetID();
							tParameters[PlayerOperations.PARAM_CITY_DEST] = pCity:GetID();
							tParameters[PlayerOperations.PARAM_BUILDING_SRC] = buildingPalaceID;
							tParameters[PlayerOperations.PARAM_BUILDING_DEST] = buildingIndex;
							tParameters[PlayerOperations.PARAM_GREAT_WORK_INDEX] = srcGreatWorkID;
							tParameters[PlayerOperations.PARAM_SLOT] = index;
							UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.MOVE_GREAT_WORK, tParameters);
							return true
						end
					end
				end
			end
		end
	end

	return false
end
