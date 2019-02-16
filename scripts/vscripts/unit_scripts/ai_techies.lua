function Spawn( entityKeyValues )

	local thisEnt = thisEntity

	thisEnt.land_mine = thisEnt:FindAbilityByName("custom_land_mine")
	thisEnt.stored_pos = nil
	thisEnt.numMines = 0
	thisEnt.maxMines = 3

	Timers:CreateTimer(1, function() return AI_Techies_Think(thisEnt) end)

end

function PlantMine(thisEnt, pos)
	--print("Planting mine")
	thisEnt:CastAbilityOnPosition(pos, thisEnt.land_mine, 0)
	thisEnt.land_mine:StartCooldown(thisEnt.land_mine:GetCooldown(1))

	local MineSpawnCallback = function(newMine)
		thisEnt.numMines = thisEnt.numMines + 1
		newMine.techies = thisEnt

		local mineSkill = newMine:FindAbilityByName("techies_suicide")
		mineSkill:SetLevel(thisEnt.land_mine:GetLevel())

		if thisEnt.land_mine:GetLevel() == 2 then
			newMine:SetRenderColor(40, 40 , 255 )
			newMine:SetModelScale(1.2)
		end

	end

	CreateUnitByNameAsync("npc_dota_custom_mine" , pos + RandomVector( RandomFloat( -15, 15 ) ), true, thisEnt:GetOwner(), thisEnt:GetOwner(), DOTA_TEAM_GOODGUYS, MineSpawnCallback)
	
end

function AI_Techies_Think(thisEnt)

	--print("Thinking")

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
		return nil
	end

	thisEnt.land_mine = thisEnt:FindAbilityByName("custom_land_mine")

  if thisEnt.land_mine:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(thisEnt.land_mine)
  end

  if thisEnt:IsStunned() then
  	return 1
  end

  if thisEnt.land_mine:IsFullyCastable() and thisEnt.land_mine:GetCooldownTimeRemaining() == 0.0 and thisEnt.numMines < thisEnt.maxMines  then
	--print("Searching units")

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, thisEnt.land_mine:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		if units ~= nil and #units >= 1 then

			local pos = units[1]:GetAbsOrigin()
			thisEnt.stored_pos = pos

			PlantMine(thisEnt, pos)

			return 3

		elseif thisEnt.stored_pos ~= nil then

			PlantMine(thisEnt, thisEnt.stored_pos)

			return 3
		end

	end

	return 1
end