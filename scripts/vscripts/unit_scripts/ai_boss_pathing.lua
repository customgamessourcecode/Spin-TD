local timerIntervall = 0.1

function AI_MoveBoss(boss)

	if boss:IsNull() or not boss:IsAlive() then
		--print("dead")
    	return nil
  	end

	if boss.FirstMoveBossCall == nil then
		--print("first call")
		boss.FirstMoveBossCall = false
		boss.StartPathOffset = boss.PathOffset
		boss.FirstVisit = true
		boss.MoveAIPaused = false
		boss.MovingToCenter = false

        return timerIntervall
	end

	if boss:IsChanneling()  or boss.MoveAIPaused == true then
		return timerIntervall
	end

	--print("moving to " .. boss.PathOffset)

	local pos = WAYPOINTS[boss.PathOffset]

    local order = {
    	UnitIndex = boss:GetEntityIndex(),
    	OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    	Position = pos,
    	Queue = false
	}

		if boss.MovingToCenter == false then
    	ExecuteOrderFromTable(order)
  	end

    --check distance to pos

    --print("dist " .. (pos - boss:GetOrigin()):Length2D())

    if (pos - boss:GetOrigin()):Length2D() < 102 then
    	
    	if boss.PathOffset == boss.StartPathOffset and boss.FirstVisit == false then

    		local restartPath = false

    		if boss.ReachedEndCallback ~= nil then

    			restartPath = boss.ReachedEndCallback(boss)
    		end

    		if boss.MoveAIPaused == true then
    			if restartPath then
    				boss.PathOffset = boss.StartPathOffset+1
	    		end
	    		return timerIntervall
	    	end

    		if restartPath == false then
	    		--print("moving to center")

	    		local waypointlocation = Entities:FindByName ( nil, "waypoint_end" )

			    local order = {
			    	UnitIndex = boss:GetEntityIndex(),
			    	OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			    	Position = waypointlocation,
			    	Queue = false
					}

			    ExecuteOrderFromTable(order)

			    boss.MovingToCenter = true

	    		return timerIntervall
	    	end

    	end

    	boss.PathOffset = (boss.PathOffset + 1)%8
    	boss.FirstVisit = false
    end

	return timerIntervall
end