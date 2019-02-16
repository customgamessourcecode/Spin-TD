function Spawn( entityKeyValues )
  --print("standard print")
  --PrintTable(entityKeyValues)

  faceless_void_backtrack = thisEntity:FindAbilityByName("faceless_void_backtrack")
  faceless_void_chronosphere = thisEntity:FindAbilityByName("faceless_void_chronosphere")

  faceless_void_backtrack:SetLevel(4)
  faceless_void_chronosphere:SetLevel(3)

  thisEntity.dummyUnit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), true, thisEntity, thisEntity, DOTA_TEAM_NEUTRALS )
  thisEntity.dummyUnit:AddNoDraw()
  thisEntity.dummyUnit:AddAbility("faceless_void_chronosphere")
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_invulnerable", nil)
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
  local a = thisEntity.dummyUnit:FindAbilityByName("faceless_void_chronosphere")
  a:SetLevel(3)

  faceless_void_chronosphere:StartCooldown(5)


  Timers:CreateTimer(1, function() return AI_Boss_Void_Think() end)

end

function AI_Boss_Void_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    thisEntity.dummyUnit:ForceKill(false)
    return nil
  end

  if faceless_void_chronosphere:GetCooldownTimeRemaining() == 0.0 then

    local a = thisEntity.dummyUnit:FindAbilityByName("faceless_void_chronosphere")
    thisEntity.dummyUnit:SetAbsOrigin(thisEntity:GetAbsOrigin())
    a:EndCooldown()
    --thisEntity.dummyUnit:CastAbilityOnTarget(target, a, -1)
    thisEntity.dummyUnit:CastAbilityOnPosition(thisEntity:GetAbsOrigin(), a, -1)
    faceless_void_chronosphere:StartCooldown(12.0)

  end


  return 1
end