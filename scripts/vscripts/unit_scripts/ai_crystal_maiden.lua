function Spawn( entityKeyValues )

  local crystal_nova = thisEntity:FindAbilityByName("crystal_maiden_crystal_nova")

  Timers:CreateTimer(1, function() return AI_Crystal_Maiden_Think(thisEntity) end)

end

function AI_Crystal_Maiden_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local crystal_nova = thisEnt:FindAbilityByName("crystal_maiden_crystal_nova")

  if crystal_nova:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(crystal_nova)
  end

  if crystal_nova:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then
        local target = units[1]

        thisEnt:CastAbilityOnPosition(target:GetOrigin(), crystal_nova, -1)

        return 1
      end
    end

  end

  return 1
end