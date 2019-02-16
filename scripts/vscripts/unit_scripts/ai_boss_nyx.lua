function Spawn( entityKeyValues )

  local nyx_assassin_impale = thisEntity:FindAbilityByName("nyx_assassin_impale")
  local nyx_assassin_vendetta = thisEntity:FindAbilityByName("nyx_assassin_vendetta")

  nyx_assassin_impale:SetLevel(4)
  nyx_assassin_vendetta:SetLevel(1)

  nyx_assassin_impale:StartCooldown(math.random(4, 6))
  nyx_assassin_vendetta:StartCooldown(math.random(28, 30))

  thisEntity.dummyUnit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), true, thisEntity, thisEntity, DOTA_TEAM_NEUTRALS )
  thisEntity.dummyUnit:AddNoDraw()
  thisEntity.dummyUnit:AddAbility("nyx_assassin_impale")
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_invulnerable", nil)
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
  local a = thisEntity.dummyUnit:FindAbilityByName("nyx_assassin_impale")
  a:SetLevel(4)

  Timers:CreateTimer(1, function() return AI_Boss_Nyx_Think(thisEntity) end)

end

function AI_Boss_Nyx_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    thisEnt.dummyUnit:ForceKill(false)
    return nil
  end

  local nyx_assassin_impale = thisEnt:FindAbilityByName("nyx_assassin_impale")
  local nyx_assassin_vendetta = thisEnt:FindAbilityByName("nyx_assassin_vendetta")

  if nyx_assassin_impale:GetCooldownTimeRemaining() > 0.0 and nyx_assassin_vendetta:GetCooldownTimeRemaining() > 0.0 then
      if nyx_assassin_impale:GetCooldownTimeRemaining() < nyx_assassin_vendetta:GetCooldownTimeRemaining() then
        return nyx_assassin_impale:GetCooldownTimeRemaining()
      else
        return nyx_assassin_vendetta:GetCooldownTimeRemaining()
      end
  end

   if nyx_assassin_impale:GetCooldownTimeRemaining() == 0.0 then

    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

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
      local a = thisEnt.dummyUnit:FindAbilityByName("nyx_assassin_impale")
      thisEnt.dummyUnit:SetAbsOrigin(thisEnt:GetAbsOrigin())
      a:EndCooldown()

      thisEnt.dummyUnit:CastAbilityOnPosition(bestUnit:GetOrigin(), a, -1)
      nyx_assassin_impale:StartCooldown(13.0)
    end

  end


  nyx_assassin_vendetta:CastAbility()

  return 1
end