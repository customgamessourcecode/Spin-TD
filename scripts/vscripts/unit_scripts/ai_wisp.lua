function Spawn( entityKeyValues )

  local wisp_tether = thisEntity:FindAbilityByName("wisp_tether")
  local wisp_overcharge = thisEntity:FindAbilityByName("wisp_overcharge")
  local wisp_tether_break = thisEntity:FindAbilityByName("wisp_tether_break")

  

  thisEntity:AddAbility("wisp_target")
  local a = thisEntity:FindAbilityByName("wisp_target")
  a:StartCooldown(0.0)
  a:SetLevel(1)

  thisEntity.targetOverride = nil

  Timers:CreateTimer(1, function() return AI_Wisp_Think(thisEntity) end)

end

function AI_Wisp_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local wisp_tether = thisEnt:FindAbilityByName("wisp_tether")
  local wisp_overcharge = thisEntity:FindAbilityByName("wisp_overcharge")
  local wisp_tether_break = thisEntity:FindAbilityByName("wisp_tether_break")

  --for i = 1, thisEnt:GetModifierCount() do
    --print("Modifier " .. i .. ": " .. thisEnt:GetModifierNameByIndex(i-1))
  --end

  if thisEnt:HasModifier("modifier_wisp_tether") == false and wisp_overcharge:GetToggleState() == true then
    wisp_overcharge:CastAbility()
  end

  if wisp_tether:GetCooldownTimeRemaining() > 0.0 then
    return 1--return AI_GetCooldownTimeRemaining(wisp_tether)
  end

  if wisp_tether:IsFullyCastable() then

    wisp_tether_break:CastAbility()

    if thisEnt.targetOverride ~= nil then

      if thisEnt.targetOverride:IsNull() or thisEnt.targetOverride:IsAlive() == false then
        thisEnt.targetOverride = nil
        return 1
      end

      thisEnt:CastAbilityOnTarget(thisEnt.targetOverride, wisp_tether, -1)
      wisp_overcharge:CastAbility()

    else

      local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 650, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
      --print("searching trough " .. #units .. " units!")
      local bestUnit = nil

      for k, v in pairs(units) do

        if v:HasModifier("modifier_wisp_tether_haste") == false and v.isATower ~= nil and v:GetEntityIndex() ~= thisEnt:GetEntityIndex() then
          if bestUnit == nil then
            bestUnit = v
          elseif v:GetAverageTrueAttackDamage(v) >= bestUnit:GetAverageTrueAttackDamage(bestUnit) then
            bestUnit = v
          end
        end
      end

      if bestUnit ~= nil then
        --print("casting")
        thisEnt:CastAbilityOnTarget(bestUnit, wisp_tether, -1)
        wisp_overcharge:CastAbility()
      end

    end

  end

  return 1
end

function selectTarget(keys)
  --print("selectTarget(keys)")
  --PrintTable(keys)

  if keys.target.isATower == true then
    keys.attacker.targetOverride = keys.target
  end
end