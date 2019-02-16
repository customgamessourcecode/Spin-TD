local ROSH_PHASE_START = 0
local ROSH_PHASE_ANGRY = 1
local ROSH_PHASE_SWARM = 2
local ROSH_PHASE_LAST_RUSH = 3

function Spawn( entityKeyValues )
	thisEntity.ReachedEndCallback = AI_Boss_Roshan_Reached_End


	thisEntity.roshBossPhase = ROSH_PHASE_START
	thisEntity.nSwarms = 10
	thisEntity.swarmCounter = 0
  thisEntity.creepSpawns = {}

  thisEntity.dummyUnit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), true, thisEntity, thisEntity, DOTA_TEAM_NEUTRALS )
  thisEntity.dummyUnit:AddNoDraw()
  thisEntity.dummyUnit:AddAbility("omniknight_repel")
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_invulnerable", nil)
  thisEntity.dummyUnit:AddNewModifier(thisEntity.dummyUnit, nil, "modifier_spectre_spectral_dagger_path_phased", nil)
  local a = thisEntity.dummyUnit:FindAbilityByName("omniknight_repel")
  a:SetLevel(2)


  Timers:CreateTimer(1, function() return AI_Boss_Roshan_Think(thisEntity) end)

end

function AI_Boss_Roshan_Slam(thisEnt)
	local waypointlocation = Entities:FindByName ( nil, "waypoint_end" )

	local CreateSpawnCallback = function(creature)  
    creature:SetHullRadius(2)
    creature:AddNewModifier(creature, nil, "modifier_super_speed_lua", nil)
    creature:AddNewModifier(creature, nil, "modifier_spectre_spectral_dagger_path_phased", nil)

    local hpBonus = PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusCreepStart + (GameMode.currentWave * PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusCreepPT)

    creature:SetBaseMaxHealth((creature:GetBaseMaxHealth() + hpBonus)*MAX_HEALTH_MULT_DIFFICULTY[DIFFICULTY])

    creature:SetMaxHealth(creature:GetBaseMaxHealth())
    creature:SetHealth(creature:GetMaxHealth())
    creature:SetPhysicalArmorBaseValue(creature:GetPhysicalArmorBaseValue() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].armorBonus)

    creature:SetMaximumGoldBounty(creature:GetMaximumGoldBounty() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].bountyBonus)
    creature:SetMinimumGoldBounty(creature:GetMinimumGoldBounty() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].bountyBonus)

    creature:SetBaseMoveSpeed(280)

    creature.TD_RoshSpawn = true

    table.insert(thisEnt.creepSpawns, creature)

    local finalOrder = {
        UnitIndex = creature:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = waypointlocation,
        Queue = true
    }

    ExecuteOrderFromTable(finalOrder)
  end

	StartAnimation(thisEnt, {duration=1, activity=ACT_DOTA_CAST_ABILITY_3, rate=1})

	Timers:CreateTimer(0.4, function() 
  	ScreenShake(thisEnt:GetAbsOrigin(), 100, 1, 1, 6000, 0, true)
  	thisEnt:EmitSoundParams("Roshan.Slam", RandomInt(80, 4000), 0, 0)
  	
		local particle = ParticleManager:CreateParticle(PARTICLE_ROSHAN_EXPLOSION, PATTACH_ABSORIGIN, thisEnt)

		Timers:CreateTimer(2, function() ParticleManager:DestroyParticle(particle, false) end)
	end)

  local behindDir = (thisEnt:GetAbsOrigin()-waypointlocation:GetAbsOrigin())
  behindDir = behindDir:Normalized()
  local sideDir = Vector(-behindDir.y, behindDir.x, behindDir.z)

  local nCreeps = 2

  if 			DIFFICULTY == DIFFICULTY_EASY then
  	nCreeps = 1
  elseif	DIFFICULTY == DIFFICULTY_NORMAL then
  	nCreeps = 2
  elseif	DIFFICULTY == DIFFICULTY_HARD then
  	nCreeps = 3
  end

  for i = 1, nCreeps do
  	CreateUnitByNameAsync( GameMode.WAVES.waveTable[RandomInt(26, 29)].creep , thisEnt:GetAbsOrigin() + behindDir*2000 + sideDir*RandomFloat(-4000, 4000), true, nil, nil, DOTA_TEAM_NEUTRALS, CreateSpawnCallback)
	end
end

function AI_Boss_Roshan_Think(thisEnt)

  if thisEnt:IsNull() or not thisEnt:IsAlive() then

    for k, creature in pairs(thisEnt.creepSpawns) do
      if creature:IsNull() == false and creature:IsAlive() then
        creature:ForceKill(false)
      end
    end
    thisEnt.dummyUnit:ForceKill(false)

    return nil
  end

  if thisEnt.roshBossPhase == ROSH_PHASE_ANGRY or thisEnt.roshBossPhase == ROSH_PHASE_START then

    local a = thisEnt.dummyUnit:FindAbilityByName("omniknight_repel")
    thisEnt.dummyUnit:SetAbsOrigin(thisEnt:GetAbsOrigin())

    if a:GetCooldownTimeRemaining() == 0 then

      thisEnt.dummyUnit:CastAbilityOnTarget(thisEnt, a, -1)
    end
    
  end

  if thisEnt.roshBossPhase == ROSH_PHASE_SWARM then

  	if thisEnt.MoveAIPaused then
  		if thisEntity.swarmCounter > thisEntity.nSwarms then
  			thisEnt.MoveAIPaused = false
  		end

  		thisEntity.swarmCounter = thisEntity.swarmCounter + 1

  		AI_Boss_Roshan_Slam(thisEnt)

  		return 1
  	else
  		--will spawn creeps at sides where players have dc:ed
  		--AI_Boss_Roshan_Slam(thisEnt)

  		return 2
  	end
  end

  return 1
end

function AI_Boss_Roshan_Reached_End(thisEnt)
	--print("AI_Boss_Roshan_Reached_End called")

	thisEnt.roshBossPhase =  thisEnt.roshBossPhase + 1

	if 			thisEnt.roshBossPhase == ROSH_PHASE_ANGRY then

		thisEnt:Purge(false, true, false, true, true)
		thisEnt:SetRenderColor(255, 0, 0)
		thisEnt:SetBaseMoveSpeed(thisEnt:GetBaseMoveSpeed()*1.7)

		thisEnt:SetAdditionalBattleMusicWeight(1000 )

		local particle = ParticleManager:CreateParticle(PARTICLE_ROSHAN_SMOKE, PATTACH_ABSORIGIN_FOLLOW, thisEntity)

		--flail anim
    StartAnimation(thisEnt, {duration = 9999999, activity=ACT_DOTA_FLAIL, rate=2.5})

		return true

	elseif 	thisEnt.roshBossPhase == ROSH_PHASE_SWARM then
		EndAnimation(thisEnt)
		-- slam anim
		thisEnt.MoveAIPaused = true
		thisEntity.swarmCounter = 0
		return true
	elseif 	thisEnt.roshBossPhase == ROSH_PHASE_LAST_RUSH then
		return false
	end

	return false
end