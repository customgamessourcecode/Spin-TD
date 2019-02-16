function Spawn( entityKeyValues )

  local dragon_form = thisEntity:FindAbilityByName("dragon_knight_elder_dragon_form")
  local thisEnt = thisEntity

  Timers:CreateTimer(0.5, function()
    if thisEnt:IsNull() == false and thisEnt:FindModifierByName("modifier_dragon_knight_dragon_form") == nil then
      dragon_form:CastAbility() return 0.5
    end
    return nil
  end)

end