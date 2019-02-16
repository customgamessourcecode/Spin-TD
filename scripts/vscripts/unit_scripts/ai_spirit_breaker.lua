function Spawn( entityKeyValues )

  local slardar_bash = thisEntity:FindAbilityByName("slardar_bash")

  Timers:CreateTimer(1, function() return AI_Spirit_Breaker_Think(thisEntity) end)

end

function AI_Spirit_Breaker_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local slardar_amplify_damage = thisEnt:FindAbilityByName("slardar_amplify_damage")

  if slardar_amplify_damage == nil then
    return 1
  end

  if slardar_amplify_damage:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(slardar_amplify_damage)
  end

  if slardar_amplify_damage:IsFullyCastable() then
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then
        local target = units[1]

        thisEnt:CastAbilityOnTarget(target, slardar_amplify_damage, -1)

        return 1
      end
    end
  end

  return 1
end