function Spawn( entityKeyValues )

	local fatal_bonds = thisEntity:FindAbilityByName("warlock_fatal_bonds")

  Timers:CreateTimer(1, function() return AI_Warlock_Think(thisEntity) end)

end

function AI_Warlock_Think(thisEnt)

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local fatal_bonds = thisEntity:FindAbilityByName("warlock_fatal_bonds")

  if fatal_bonds:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(fatal_bonds)
  end


  if fatal_bonds:IsFullyCastable() then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, fatal_bonds:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
    	if #units >= 1 then
    		local target = units[1]

    		thisEnt:CastAbilityOnTarget(target, fatal_bonds, -1)

    		return 1
    	end
    end

  end

  return 1
end