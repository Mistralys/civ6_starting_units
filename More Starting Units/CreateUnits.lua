
-- The variable unitsToAdd sets the units that should 
-- be added. Simply set an amount above zero for that 
-- unit to be added.
--
-- WARNING: The script tries to distribute the units
-- over available tiles near the starting settler.
-- If there is not enough free space, they will be 
-- stacked. If you cannot move them all to free plots,
-- you will not be able to end the turn. In this case,
-- simply disband some.

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





-- -----------------------------------------------------------------------------
-- DO NOT CHANGE ANYTHING BELOW - UNLESS YOU KNOW WHAT YOU ARE DOING :)
-- -----------------------------------------------------------------------------

-- Largely inspired by Mynex's original mod on Nexusmods:
-- https://www.nexusmods.com/civilisationvi/mods/9

-- Called when any player (AI or human) takes his turn.
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
            
            -- Go through the list of units
            for unitName, amount in pairs(unitsToAdd) do
                
                -- This is the internal index of the unit
                local unitIndex = GameInfo.Units[unitName].Index;
            
                -- Do we want to add this unit?
                if amount > 0 then
                
                    for i = 1, amount do
                    
                        -- Go through plots nearby, and check where we could put the unit.
                        -- We also store the last plot we put a unit so we can avoid putting
                        -- a second one there.
                        --
                        -- This could be enhanced with a stack of plots built in advance
                        -- using an outward spiral for the amount of units to add.
                        --
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
