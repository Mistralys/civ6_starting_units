
-- Sets the units that should be added. Simply set
-- an amount above zero for that unit to be added.
--
-- WARNING: The script tries to distribute the units
-- over available tiles near the starting settler.
-- If there is not enough free space, they will be 
-- stacked. If you cannot move them all to free plots,
-- you will not be able to end the turn.

local unitsToAdd = 
{
    ["UNIT_SCOUT"] = 1,
    ["UNIT_SETTLER"] = 0,
    ["UNIT_BUILDER"] = 1,
    ["UNIT_SLINGER"] = 0,
    ["UNIT_WARRIOR"] = 0,
    ["UNIT_RANGER"] = 0,
    ["UNIT_ARCHER"] = 0,
    ["UNIT_SKIRMISHER"] = 0,
--    ["UNIT_CREE_OKIHTCITAW"] = 0, -- requires Rise and Fall expansion
    ["UNIT_SPEARMAN"] = 0,
    ["UNIT_TRADER"] = 0
}

-- Unit names can be found in the following locations:
-- > Vanilla: Base/Assets/Gameplay/Units.xml
-- > Rise and Fall: DLC/Expansion1/Expansion1_Units_Major.xml
-- > Gathering Storm: DLC/Expansion2/Expansion2_Units_Major


function OnPlayerTurnActivated( player, bIsFirstTime )

    -- Is this the start turn?
    if Game.GetCurrentGameTurn() == GameConfiguration.GetStartTurn() then
    
        local pPlayer = Players[player]
        local SpawnTurn = 0;
        local playerUnits;	
        local adjacentPlot;
        local unitPlot;
        
        -- Is the player human? If yes, determine if this is the spawn turn
        if pPlayer:IsHuman() then
            playerUnits = pPlayer:GetUnits()
            for i, unit in playerUnits:Members() do
                local unitTypeName = UnitManager.GetTypeName(unit)
                if "LOC_UNIT_SETTLER_NAME" == unitTypeName then
                    SpawnTurn = 1;
                    unitPlot = Map.GetPlot(unit:GetX(), unit:GetY());		
                end
            end
        end		
        
        -- This is the spawn turn
        if SpawnTurn == 1 then
            
            local lastPlot = unitPlot;
            
            for unitName, amount in pairs(unitsToAdd) do
                
                local unitIndex = GameInfo.Units[unitName].Index;
            
                if amount > 0 then
                    for i = 1, amount do
                        for direction = 1, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
                            adjacentPlot = Map.GetAdjacentPlot(lastPlot:GetX(), lastPlot:GetY(), direction);
                            if (adjacentPlot ~= nil) and not (adjacentPlot:IsWater() or adjacentPlot:IsImpassable()) then
                                playerUnits:Create(unitIndex, adjacentPlot:GetX(), adjacentPlot:GetY())
                                lastPlot = adjacentPlot;
                                break		
                            end
                        end
                    end
                end
            end
            
            -- Remove this event handler so it does not get called on every game turn afterwards
            Events.PlayerTurnActivated.Remove(OnPlayerTurnActivated);
        end
    end
end

-- Add the function to be called when a player turn is activated (AI or Human)
Events.PlayerTurnActivated.Add(OnPlayerTurnActivated);
