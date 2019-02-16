function Spawn( entityKeyValues )

	local thisEnt = thisEntity

	thisEnt.land_mine = thisEnt:FindAbilityByName("custom_land_mine")
	thisEnt.stored_pos = nil
	thisEnt.numMines = 0
	thisEnt.maxMines = 3

	Timers:CreateTimer(1, function() return AI_Techies_Think(thisEnt) end)

end

function PlantMine(thisEnt, pos)

	thisEnt:CastAbilityOnPosition(pos, thisEnt.land_mine, 0)
	local newMine = CreateUnitByName( "npc_dota_custom_mine" , pos, false, thisEnt:GetOwner(), thisEnt:GetOwner(), DOTA_TEAM_GOODGUYS)
	newMine:AddNewModifier(newMine, nil, "modifier_item_phase_boots_active", nil)
	thisEnt.numMines = thisEnt.numMines + 1
	newMine.techies = thisEnt
	local a = newMine:FindAbilityByName("techies_suicide")
	a:SetLevel(thisEnt.land_mine:GetLevel())
	a:StartCooldown(1.0)

end

function AI_Techies_Think(thisEnt)

	if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
 	end

  if thisEnt.land_mine:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(thisEnt.land_mine)
  end

  if thisEnt:IsStunned() then
  	return 1
  end

  if thisEnt.land_mine:IsFullyCastable() and thisEnt.numMines < thisEnt.maxMines then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

		if units ~= nil and #units >= 1 then

			local pos = units[1]:GetAbsOrigin()
			thisEnt.stored_pos = pos

			PlantMine(thisEnt, pos)

			return 1

		elseif thisEnt.stored_pos ~= nil then

			PlantMine(thisEnt, thisEnt.stored_pos)

			return 1
		end

	end

	return 1
end