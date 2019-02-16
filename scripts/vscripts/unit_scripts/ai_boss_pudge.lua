function Spawn( entityKeyValues )

  pudge_dismember = thisEntity:FindAbilityByName("custom_pudge_dismember")

  pudge_dismember:SetLevel(3)

  thisEntity:SetStolenScepter(true)

  --print("ENT HAS  SCEPTER: " .. tostring(thisEntity:HasScepter()))

  Timers:CreateTimer(1, function() return AI_Boss_Pudge_Think() end)

end

function AI_Boss_Pudge_Think()

  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil
  end

  if pudge_dismember:GetCooldownTimeRemaining() > 0.0 then
    return pudge_dismember:GetCooldownTimeRemaining()
  end

  if pudge_dismember:IsFullyCastable() and thisEntity:GetHealthPercent() < 60 then

    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, thisEntity:GetOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )

    if units ~= nil then
      if #units >= 1 then

        for i = 1, #units do
          local target = units[i]

          if target.isATower ~= nil and target.isATower == true then
            thisEntity:CastAbilityOnTarget(target, pudge_dismember, -1)


            local finalOrder = {
                UnitIndex = thisEntity:GetEntityIndex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = Entities:FindByName ( nil, "waypoint_end" ),
                Queue = true
            }

            ExecuteOrderFromTable(finalOrder)

            return 1
          end

        end
      end
    end
  end

  return 1
end