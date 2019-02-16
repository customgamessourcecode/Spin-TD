function Spawn( entityKeyValues )
  Timers:CreateTimer(2, function() return AI_Boss_Spamm_Messer_Think() end)
end

function AI_Boss_Spamm_Messer_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil
  end

  --find the closest player by their towers of platforms
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

  if #units == 0 then return 2 end

  local playerHero = nil

  for i = 1, #units do
    local unit = units[i]

    if unit.isATower or unit:GetUnitName() == "npc_dota_tower_location" then
      local PlayerID = unit:GetMainControllingPlayer()

      if PlayerResource:GetPlayer(PlayerID) ~= nil then
        playerHero = PlayerResource:GetPlayer(PlayerID):GetAssignedHero()
        break
      end

    end

  end

  if playerHero == nil or #playerHero.PGS.towerList == 0 then return 2 end

  --after that find out wich type of tower they got the most of.
  local towerTypeTable = {}

  for i = 1, #playerHero.PGS.towerList do
    --v.TowerList[i]:ForceKill(false)
    local tower = playerHero.PGS.towerList[i]

    if tower:IsNull() == false then

      if towerTypeTable[tower:GetUnitName()] == nil then
        towerTypeTable[tower:GetUnitName()] = {}
        table.insert(towerTypeTable[tower:GetUnitName()], tower)
      else
        table.insert(towerTypeTable[tower:GetUnitName()], tower)
      end

    else
      print("null tower in players towerlist!")
    end

  end

  local largestType = nil
  local largetCount = 0

  for k, v in pairs(towerTypeTable) do
    if largestType == nil or largetCount < #v then
      largetCount = #v
      largestType = k
    end
  end

  if largestType == nil then return 2 end

  --and after that stun towers

  for k, v in pairs(towerTypeTable[largestType]) do
    v:AddNewModifier(v, nil, "modifier_earthshaker_fissure_stun", {duration = 5})
  end

  return 7
end