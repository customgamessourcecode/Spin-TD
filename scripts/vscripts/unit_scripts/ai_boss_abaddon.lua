function Spawn( entityKeyValues )

  bane_nightmare = thisEntity:FindAbilityByName("bane_nightmare")
  abaddon_borrowed_time = thisEntity:FindAbilityByName("abaddon_borrowed_time")

  bane_nightmare:SetLevel(4)
  abaddon_borrowed_time:SetLevel(3)

  thisEntity.dummyUnit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), true, thisEntity, thisEntity, DOTA_TEAM_NEUTRALS )
  thisEntity.dummyUnit:AddNoDraw()
  thisEntity.dummyUnit:AddAbility("bane_nightmare")
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_invulnerable", nil)
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
  local a = thisEntity.dummyUnit:FindAbilityByName("bane_nightmare")
  a:SetLevel(4)


  Timers:CreateTimer(1, function() return AI_Boss_Abaddon_Think() end)

end

function AI_Boss_Abaddon_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    thisEntity.dummyUnit:ForceKill(false)
    return nil
  end

  if thisEntity:GetHealthPercent() < 40 and abaddon_borrowed_time:GetCooldownTimeRemaining() < 1.0 then
    abaddon_borrowed_time:CastAbility()
  end

  -- use bane sleep on the tower with highest refund value!

  if bane_nightmare:GetCooldownTimeRemaining() == 0.0 then

    local target = nil
    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, thisEntity:GetOrigin(), nil, 1250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
    local highest = 0

    for k, v in pairs(units) do
      if v.isATower and v.refundGold > highest and v:HasModifier("modifier_bane_nightmare") == false then
        target = v
        highest = v.refundGold
      end
    end

    if target ~= nil then
      local a = thisEntity.dummyUnit:FindAbilityByName("bane_nightmare")
      thisEntity.dummyUnit:SetAbsOrigin(target:GetAbsOrigin())
      a:EndCooldown()
      thisEntity.dummyUnit:CastAbilityOnTarget(target, a, -1)
      bane_nightmare:StartCooldown(6.0)


      return 1
    end

  end

  return 1
end