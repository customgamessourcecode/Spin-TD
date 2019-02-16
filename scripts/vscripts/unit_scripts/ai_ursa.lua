function Spawn( entityKeyValues )

  local ursa_fury_swipes = thisEntity:FindAbilityByName("ursa_fury_swipes")

  Timers:CreateTimer(1, function() return AI_Ursa_Think(thisEntity) end)

end

function AI_Ursa_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local ursa_overpower = thisEnt:FindAbilityByName("ursa_overpower")

  if ursa_overpower ~= nil then

    if ursa_overpower:GetCooldownTimeRemaining() > 0.0 then
      return AI_GetCooldownTimeRemaining(ursa_overpower)
    end

    ursa_overpower:CastAbility()

    return 1

  end

  return 1

end