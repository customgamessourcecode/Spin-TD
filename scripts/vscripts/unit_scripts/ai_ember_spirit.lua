function Spawn( entityKeyValues )

  local ember_spirit_sleight_of_fist = thisEntity:FindAbilityByName("ember_spirit_sleight_of_fist")

  Timers:CreateTimer(1, function() return AI_Ember_Spirit_Think(thisEntity) end)

end

function AI_Ember_Spirit_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then
    return nil
  end

  local ember_spirit_sleight_of_fist = thisEnt:FindAbilityByName("ember_spirit_sleight_of_fist")

  if ember_spirit_sleight_of_fist:GetCooldownTimeRemaining() > 0.0 then
    return AI_GetCooldownTimeRemaining(ember_spirit_sleight_of_fist)
  end

  if ember_spirit_sleight_of_fist:IsFullyCastable() and thisEnt:HasModifier("modifier_ember_spirit_sleight_of_fist_caster") == false then

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEnt:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then
        local target = units[1]

        thisEnt.SavedPos = thisEnt:GetAbsOrigin()
        thisEnt:CastAbilityOnPosition(target:GetOrigin(), ember_spirit_sleight_of_fist, -1)

        --[[
        local a = thisEnt:FindAbilityByName("sell_tower")
        if a ~= nil then
          a:StartCooldown(8)
        end--]]

        for i = 1, thisEnt:GetAbilityCount() - 1 do
          if thisEnt:GetAbilityByIndex(i) ~= nil then
            thisEnt:GetAbilityByIndex(i):StartCooldown(8)
          end
        end

        Timers:CreateTimer(0.25, function()
          if thisEnt:HasModifier("modifier_ember_spirit_sleight_of_fist_caster") == false then
            thisEnt:SetAbsOrigin(thisEnt.SavedPos)
            return nil
          end

          return 0.25
        end)


        return 1
      end
    end

  end

  return 1
end