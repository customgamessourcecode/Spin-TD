function Spawn( entityKeyValues )

  fish_crush = thisEntity:FindAbilityByName("fish_crush")
  fish_sprint = thisEntity:FindAbilityByName("fish_sprint")

  fish_sprint:SetLevel(4)

  Timers:CreateTimer(1, function() return AI_Boss_Fish_Think() end)

end

function AI_Boss_Fish_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil
  end

  if fish_sprint:GetCooldownTimeRemaining() > 0.0 and fish_crush:GetCooldownTimeRemaining() > 0.0 then
    if fish_sprint:GetCooldownTimeRemaining() < fish_crush:GetCooldownTimeRemaining() then
      return fish_sprint:GetCooldownTimeRemaining()
    else
      return fish_crush:GetCooldownTimeRemaining()
    end
  end

  fish_sprint:CastAbility()
  fish_crush:CastAbility()

  return 1
end