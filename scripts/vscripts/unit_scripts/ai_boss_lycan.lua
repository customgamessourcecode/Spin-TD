--o == 1 if zero index == start, else 0
local function closestWaypoint(list, o)
  local closest_dist = 9999999
  local closest_index = 0

  for i = 1 - o, #list - o do
    local distance = (thisEntity:GetAbsOrigin() - WAYPOINTS[i]):Length2D()

    if distance < closest_dist then
      closest_index = i
      closest_dist = distance
    end
  end

  return closest_index
end

local function furthestWaypoint(list, o)
  local furthest_dist = -1
  local furthest_index = 0

  for i = 1 - o, #list - o do
    local distance = (thisEntity:GetAbsOrigin() - WAYPOINTS[list[i]]):Length2D()

    if distance > furthest_dist then
      furthest_index = list[i]
      furthest_dist = distance
    end
  end

  return furthest_index
end

function Spawn( entityKeyValues )
  lycan_summon_wolves = thisEntity:FindAbilityByName("custom_lycan_summon_wolves")
  lycan_shapeshift = thisEntity:FindAbilityByName("custom_lycan_shapeshift")

  lycan_summon_wolves:SetLevel(4)
  lycan_shapeshift:SetLevel(3)

  lycan_summon_wolves:StartCooldown(math.random(4, 6))

  Timers:CreateTimer(1, function() return AI_Boss_Lycan_Think() end)
end

function test(closest_index, entranceWayPoint)
  print("entranceWayPoint: " .. entranceWayPoint)
  print("closest_index: " .. closest_index)

  local dir = 0
  local waypoints = {}

  if closest_index - entranceWayPoint > 0 then
    dir = -1
  else
    dir = 1
  end

  local i = closest_index
  while i ~= (entranceWayPoint + dir+8)%8 do 
    print("i: " .. i)
    table.insert(waypoints, WAYPOINTS[i])
    i = i + dir
    i = (i+8) % 8
    
  end
end

--test(5, 6)
--test(4, 6)
--test(6, 5)

function AI_Boss_Lycan_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil
  end

  if thisEntity:GetHealthPercent() < 40 and lycan_shapeshift:GetCooldownTimeRemaining() < 1.0 then
    lycan_shapeshift:CastAbility()
  end

  if lycan_summon_wolves:GetCooldownTimeRemaining() > 0.0 then
    return 1--lycan_summon_wolves:GetCooldownTimeRemaining()
  end

  if lycan_summon_wolves:IsFullyCastable() then --and thisEntity:GetHealthPercent() < 60 then
    lycan_summon_wolves:CastAbility()

    local activePlayers = GameMode:getActivePlayers()
    local entrances = {}

    for k, aPly in pairs(activePlayers) do
      table.insert(entrances, aPly.PGS.spawnerOffset)
    end

    local entranceWayPoint = furthestWaypoint(entrances, 0)

    --print("entranceWayPoint: " .. entranceWayPoint)

    local closest_index = closestWaypoint(WAYPOINTS, 1)

    --print("closest_index: " .. closest_index)

    local dir = 0
    local waypoints = {}

    if closest_index - entranceWayPoint > 0 then
      dir = -1
    else
      dir = 1
    end

    local i = closest_index
    while i ~= (entranceWayPoint + dir+8)%8 do 
      --print("i: " .. i)
      table.insert(waypoints, WAYPOINTS[i])
      i = i + dir
      i = (i+8) % 8
      
    end

    table.insert(waypoints, Entities:FindByName( nil, "waypoint_end" ))

    --spawn wolves!
    --
    local nWolves = math.random(7, 10)

    for i = 1, nWolves do
      local creature = CreateUnitByName( "boss_lycan_wolf1" , thisEntity:GetAbsOrigin() + RandomVector( RandomFloat( 0, 50 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
      --creature:SetHullRadius(2)
      creature:AddNewModifier(creature, nil, "modifier_super_speed_lua", nil)
      creature:AddNewModifier(creature, nil, "modifier_item_phase_boots_active", nil)
      creature:AddNewModifier(creature, nil, "modifier_spectre_spectral_dagger_path_phased", nil)

      Timers:CreateTimer(0.1, function()

        for k, v in pairs(waypoints) do
          local order = 
          {
            UnitIndex = creature:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = v,
            Queue = true
          }

          ExecuteOrderFromTable(order)
        end
      end)
    end
  end

  return 1
end