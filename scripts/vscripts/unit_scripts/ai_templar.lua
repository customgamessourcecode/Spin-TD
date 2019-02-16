function Spawn( entityKeyValues )

  local templar_assassin_psi_blades = thisEntity:FindAbilityByName("templar_assassin_psi_blades")

  templar_assassin_psi_blades:SetLevel(4)

  Timers:CreateTimer(1, function() return AI_Templar_Think(thisEntity) end)

end

function AI_Templar_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local templar_assassin_refraction = thisEnt:FindAbilityByName("templar_assassin_refraction")

  if templar_assassin_refraction ~= nil then

    if templar_assassin_refraction:GetCooldownTimeRemaining() > 0.0 then
      return AI_GetCooldownTimeRemaining(templar_assassin_refraction)
    end


    templar_assassin_refraction:CastAbility()

    return 1
  end

  return 1

end