function creepReachedEnd( keys )
  --print("local function creepReachedEnd( keys )")
  --PrintTable(keys)

  local activator = keys.activator

  if IsValidEntity(activator) and activator:IsRealHero() == false and activator:IsAlive() and (activator.TD_Creep or activator.TD_RoshSpawn or activator:GetUnitName() == "boss_lycan_wolf1") then
    activator:Kill(nil, activator)
  end
end

function enterSpeedLane( keys )

 -- PrintTable(keys)
  --print("Name: " .. keys.caller:GetName()) -- [   VScript ]: Name: speed_lane_2
  local activator = keys.activator

  if keys.caller.isSpeedOn == nil or keys.caller.isSpeedOn == false then
    return
  end

  if IsValidEntity(activator) and activator:IsRealHero() == false and activator:IsAlive() and (activator.TD_Creep or activator:GetUnitName() == "boss_lycan_wolf1") then

    activator:SetBaseMoveSpeed(activator:GetBaseMoveSpeed() + 1200)
    activator:RemoveModifierByName("modifier_venomancer_poison_sting")
    activator:RemoveModifierByName("modifier_crystal_maiden_crystal_nova")
    activator:RemoveModifierByName("modifier_item_skadi_slow")

  end

end

function leaveSpeedLane( keys )
  local activator = keys.activator

  if keys.caller.isSpeedOn == nil or keys.caller.isSpeedOn == false then
    return
  end

  if IsValidEntity(activator) and activator:IsRealHero() == false and activator:IsAlive() and (activator.TD_Creep or activator:GetUnitName() == "boss_lycan_wolf1") then

    activator:SetBaseMoveSpeed(activator:GetBaseMoveSpeed() - 1200)

  end
end

local DOUBLE_VISIT_MSG_COUNTER = 1

function enterMoveTrigger( keys )
  
  local caller = keys.caller
  local activator = keys.activator
  local triggerName = caller:GetName()
  local index = tonumber(string.sub(triggerName, -1))

  --PrintTable(caller)
  --print("name: " .. triggerName)
  --print("index: " .. index)
  --PrintTable(activator)

  if activator:IsNull() == false and activator:IsAlive() == true and activator.TD_Creep == true and activator.isBoss == nil then

    if activator.moveIndex ~= activator.moveStartIndex  or activator.moveStartIndex == nil then
      
      if activator.moveWaypointVisits[index+1] > 0 then
        --print("double visit guard " .. DOUBLE_VISIT_MSG_COUNTER)
        DOUBLE_VISIT_MSG_COUNTER = DOUBLE_VISIT_MSG_COUNTER + 1
        return
      end

      activator.moveWaypointVisits[index+1] = activator.moveWaypointVisits[index+1] + 1

      if activator.moveStartIndex == nil then
        activator.moveStartIndex = activator.moveIndex
      end

      if G_WAVE_INDEX % 2 ~= 0 then
        activator.moveIndex = (activator.moveIndex + 1)%8
      else
        activator.moveIndex = (activator.moveIndex - 1)%8
      end

      --activator:Interrupt()

      local pos = WAYPOINTS[activator.moveIndex]

      local order = {
          UnitIndex = activator:GetEntityIndex(),
          OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
          Position = pos,
          Queue = true
      }

      ExecuteOrderFromTable(order)
    else
      local waypointlocation = Entities:FindByName ( nil, "waypoint_end" )
      activator.bMovingToCenter = true

      --activator:Interrupt()
      
      local order = {
          UnitIndex = activator:GetEntityIndex(),
          OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
          Position = waypointlocation,
          Queue = true
      }

      ExecuteOrderFromTable(order)
    end
  end

end