function Spawn( entityKeyValues )

  local tiny_avalanche = thisEntity:FindAbilityByName("tiny_avalanche")

  tiny_avalanche:SetLevel(1)

  local tiny_craggy_exterior = thisEntity:FindAbilityByName("tiny_craggy_exterior")

  tiny_craggy_exterior:SetLevel(4)


  thisEntity.dummyUnit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), true, thisEntity, thisEntity, DOTA_TEAM_NEUTRALS )
  thisEntity.dummyUnit:AddNoDraw()
  thisEntity.dummyUnit:AddAbility("tiny_avalanche")
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_invulnerable", nil)
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
  local a = thisEntity.dummyUnit:FindAbilityByName("tiny_avalanche")
  a:SetLevel(4)

  tiny_avalanche:StartCooldown(5)


  Timers:CreateTimer(1, function() return AI_Boss_Void_Think(thisEntity) end)

end

function AI_Boss_Void_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    thisEnt.dummyUnit:ForceKill(false)
    return nil
  end

  local tiny_avalanche = thisEntity:FindAbilityByName("tiny_avalanche")

  if tiny_avalanche:GetCooldownTimeRemaining() == 0.0 then

    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, thisEnt:GetOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    local bestUnit = nil

    for k, v in pairs(units) do

      if v.isATower then
        if bestUnit == nil then
          bestUnit = v
        elseif v:GetAverageTrueAttackDamage(v) >= bestUnit:GetAverageTrueAttackDamage(bestUnit) then
          bestUnit = v
        end
      end
    end

    if bestUnit ~= nil then
      local a = thisEnt.dummyUnit:FindAbilityByName("tiny_avalanche")
      thisEnt.dummyUnit:SetAbsOrigin(thisEnt:GetAbsOrigin())
      a:EndCooldown()

      thisEnt.dummyUnit:CastAbilityOnPosition(bestUnit:GetOrigin(), a, -1)
      tiny_avalanche:StartCooldown(4.0)
    end

  end


  return 1
end