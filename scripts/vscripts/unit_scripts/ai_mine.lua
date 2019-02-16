function Spawn( entityKeyValues )


    thisEntity:AddNewModifier(thisEntity, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
	thisEntity:AddNewModifier(thisEntity, nil, "modifier_magic_immune", nil)
    thisEntity:AddNewModifier(thisEntity, nil, "modifier_super_speed_lua", nil)
    thisEntity.killMe = false


	Timers:CreateTimer(1, function() return AI_Custom_Mine_Think(thisEntity) end)

end

function AI_Custom_Mine_Think(thisEnt)

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
		return nil
	end

  local mine_boom = thisEnt:FindAbilityByName("techies_suicide")

  if thisEnt.killMe and mine_boom:GetCooldownTimeRemaining() > 0 then
  	thisEnt:ForceKill(false)
  	return nil
  elseif thisEnt.killMe then
  	thisEnt.killMe = false
  	thisEnt:SetAbsOrigin(thisEnt.startPos)
  end

  if mine_boom:IsFullyCastable() then

	  local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		if units ~= nil then
			if #units >= 1 then

    		thisEnt.startPos = thisEntity:GetAbsOrigin()
				thisEnt.techies.numMines = thisEnt.techies.numMines - 1
				thisEnt:CastAbilityOnTarget(units[1], mine_boom, -1)
    		thisEnt.killMe = true
				
				
			end
		end

	end

	return 1
end