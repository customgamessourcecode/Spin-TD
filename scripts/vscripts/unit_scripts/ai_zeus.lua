function Spawn( entityKeyValues )

  Timers:CreateTimer(1, function() return AI_Zeus_Think(thisEntity) end)

end

function AI_Zeus_Think(thisEnt)

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local zuus_lightning_bolt = thisEnt:FindAbilityByName("zuus_lightning_bolt")
  local arc_lightning = thisEnt:FindAbilityByName("zuus_arc_lightning")

  if zuus_lightning_bolt ~= nil then

    if arc_lightning:GetCooldownTimeRemaining() > 0.0 and zuus_lightning_bolt:GetCooldownTimeRemaining() > 0.0 then
        if arc_lightning:GetCooldownTimeRemaining() < zuus_lightning_bolt:GetCooldownTimeRemaining() then
          return AI_GetCooldownTimeRemaining(arc_lightning)
        else
          return AI_GetCooldownTimeRemaining(zuus_lightning_bolt)
        end
    end

  else

    if arc_lightning:GetCooldownTimeRemaining() > 0.0 then
      return AI_GetCooldownTimeRemaining(arc_lightning)
    end

  end

  if arc_lightning:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 850, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

  	if units ~= nil then
  		if #units >= 1 then
  			local target = units[1]

  			thisEnt:CastAbilityOnTarget(target, arc_lightning, -1)

  			return 1
  		end
  	end

	end

  if zuus_lightning_bolt ~= nil and zuus_lightning_bolt:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then
        local target = units[1]

        thisEnt:CastAbilityOnTarget(target, zuus_lightning_bolt, -1)

        return 1
      end
    end

  end

	return 1
end