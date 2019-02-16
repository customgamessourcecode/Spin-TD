function Spawn( entityKeyValues )

	local flak_cannon = thisEntity:FindAbilityByName("gyrocopter_flak_cannon")

	flak_cannon:CastAbility()

  Timers:CreateTimer(1, function() return AI_Gyro_Think(thisEntity) end)

end

function AI_Gyro_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local flak_cannon = thisEnt:FindAbilityByName("gyrocopter_flak_cannon")

  if flak_cannon:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(flak_cannon)
  end

	flak_cannon:CastAbility()

	return 1
end