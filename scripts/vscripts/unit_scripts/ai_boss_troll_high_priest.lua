function Spawn( entityKeyValues )

  troll_heal = thisEntity:FindAbilityByName("enchantress_natures_attendants")
  troll_untouch = thisEntity:FindAbilityByName("enchantress_untouchable")

  troll_heal:SetLevel(4)
  troll_untouch:SetLevel(2)

  Timers:CreateTimer(1, function() return AI_Boss_Troll_Priest_Think() end)

end

function AI_Boss_Troll_Priest_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil
  end

  if troll_heal:GetCooldownTimeRemaining() > 0.0 then
    return troll_heal:GetCooldownTimeRemaining()
  end

  if thisEntity:GetHealthPercent() < 70 then
    troll_heal:CastAbility()
  end

  return 1
end