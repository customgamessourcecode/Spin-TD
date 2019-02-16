
--the only reason this exists is to exclude one of the probable causes (but the probabilty that it is this is low) of the towers stop using their abilites bug
--it is likely that this is not the problem but i have to do what i can to attempt to fix this bug.
function AI_GetCooldownTimeRemaining(ability)

  local time = ability:GetCooldownTimeRemaining()

  if time < 0.2 then
    time = 0.2
  elseif time > 10 then
    time = 10
  end

  return time
end