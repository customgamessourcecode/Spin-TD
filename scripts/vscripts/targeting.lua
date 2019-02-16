--naive targeting AI

local function IsChanneling( unit )
    
    for abilitySlot=0,15 do
        local ability = unit:GetAbilityByIndex(abilitySlot)
        if ability and ability:IsChanneling() then 
            return ability
        end
    end

    for itemSlot=0,5 do
        local item = unit:GetItemInSlot(itemSlot)
        if item and item:IsChanneling() then
            return ability
        end
    end

    return false
end

local function IsCasting(unit)
	if IsChanneling(unit) then return true end

	for abilitySlot=0,15 do
		if unit:GetAbilityByIndex(abilitySlot) then
			if unit:GetAbilityByIndex(abilitySlot):IsInAbilityPhase() then
				return true
			end
		end
	end

	return false
end

function GameMode:FindTargets()
	for k, player in pairs(self.vPlayers) do
	    if player.PGS.spawnerDisabled == false then

	    	for k, tower in pairs(player.PGS.towerList) do

	    		if tower:IsNull() == false and tower:HasAttackCapability() then

		    		if tower.AttackTarget ~= nil and tower:AttackReady() and tower:IsAttacking() == false and IsCasting(tower) == false then
		    			if tower.AttackTarget:IsNull() or tower.AttackTarget:IsAlive() == false or tower:GetRangeToUnit(tower.AttackTarget) > tower:Script_GetAttackRange() then
                --print("clearing target")
		    				tower.AttackTarget = nil
		    			end
            end

		    		if tower.AttackTarget ~= nil and tower.AttackTarget:IsNull() == false and tower.AttackTarget:IsAlive() == true and tower:AttackReady() and tower:IsAttacking() == false and IsCasting(tower) == false then
              --print("Reattacking target")
		    			tower:MoveToTargetToAttack(tower.AttackTarget)
		    		end

		    		if tower.AttackTarget == nil then
              --print("Searching for targets ...")
		    			local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, tower:GetOrigin(), nil, tower:Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true )
		    			if units ~= nil then
					    	if #units >= 1 then
                  --print("Found " .. #units .. " targets.")

					    		local target = units[1]

					    		tower.AttackTarget = target

					    		--print("distance to target " .. tower:GetRangeToUnit(target))

					    		--tower:SetForceAttackTarget(target)
					    		if tower:AttackReady() and tower:IsAttacking() == false and IsCasting(tower) == false then
					    			tower:MoveToTargetToAttack(target)
					    		end
					    	end
					    end
		    		end
	    		end
	    	end
	    end
	end
end

