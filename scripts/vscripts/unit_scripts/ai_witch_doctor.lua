function Spawn( entityKeyValues )

	local paralyzing_cask = thisEntity:FindAbilityByName("witch_doctor_paralyzing_cask")

  Timers:CreateTimer(1, function() return AI_Witch_Doctor_Think(thisEntity) end)

end

function AI_Witch_Doctor_Think(thisEnt)

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
        return nil
  end

  local witch_doctor_maledict = thisEnt:FindAbilityByName("witch_doctor_maledict")
  local paralyzing_cask = thisEnt:FindAbilityByName("witch_doctor_paralyzing_cask")

  if witch_doctor_maledict ~= nil then

    if paralyzing_cask:GetCooldownTimeRemaining() > 0.0 and witch_doctor_maledict:GetCooldownTimeRemaining() > 0.0 then
        if paralyzing_cask:GetCooldownTimeRemaining() < witch_doctor_maledict:GetCooldownTimeRemaining() then
          return paralyzing_cask:GetCooldownTimeRemaining()
        else
          return AI_GetCooldownTimeRemaining(witch_doctor_maledict)
        end
    end

  else

    if paralyzing_cask:GetCooldownTimeRemaining() > 0.0 then
      return AI_GetCooldownTimeRemaining(paralyzing_cask)
    end

  end


  if paralyzing_cask:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
    	if #units >= 1 then
    		local target = units[1]

    		thisEnt:CastAbilityOnTarget(target, paralyzing_cask, -1)

    		return 1
    	end
    end

  end

  if witch_doctor_maledict ~= nil and witch_doctor_maledict:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then
        local target = units[1]

        thisEnt:CastAbilityOnPosition(target:GetAbsOrigin(), witch_doctor_maledict, -1)

        return 1
      end
    end

  end

  return 1
end