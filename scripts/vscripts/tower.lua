local function clearUnitAbilities(unit)
  for i = 0, unit:GetAbilityCount()-1 do
    local a = unit:GetAbilityByIndex(i)

    if a ~= nil then
      unit:RemoveAbility(a:GetAbilityName())
    end
  end
end

local function lvlUpUnitAbilities(unit)
  for i = 0, unit:GetAbilityCount()-1 do
    local a = unit:GetAbilityByIndex(i)

    if a ~= nil then
      a:SetLevel(1)
    end
  end
end

local function CreateNewTower(towerName, caster, owner, cost)
  local location = caster:GetAbsOrigin()
  local tower = CreateUnitByName(towerName, location, false, owner, owner, DOTA_TEAM_GOODGUYS)
  tower.isATower = true
  tower.attackTarget = nil


  tower.refundGold = cost * CONST_SELL_LOSS

  table.insert(owner.PGS.towerList, tower)

  CustomNetTables:SetTableValue( "players_nTowers", "player" .. owner:GetPlayerID(), {value = #owner.PGS.towerList} );

  tower:SetControllableByPlayer(owner:GetPlayerID(), true)

  tower:AddAbility("sell_tower")

  local a = tower:FindAbilityByName("sell_tower")
  a:StartCooldown(1)
  a:SetLevel(1)

  local buildSlotProp = Entities:CreateByClassname("prop_dynamic")
  buildSlotProp:SetModel("models/heroes/pedestal/effigy_pedestal_ti5.vmdl")--caster:GetModelName())
  buildSlotProp:SetModelScale(0.85)
  buildSlotProp:SetRenderColor(owner.PGS.customColor[1], owner.PGS.customColor[2], owner.PGS.customColor[3])
  buildSlotProp:SetOrigin(tower:GetAbsOrigin() + Vector(0, 0, 16))

  tower.buildSlotProp = buildSlotProp

  --find and remove platform
  for i = 1, #owner.PGS.towerPlatformsList do
    if owner.PGS.towerPlatformsList[i] == caster then
      table.remove(owner.PGS.towerPlatformsList, i)
      break
    end
  end

  return tower
end

local function CloneAndRemoveTower(tower, newTower)
  local location = tower:GetAbsOrigin()
  local towerName = tower:GetUnitName()
  local refundGold =  tower.refundGold
  local buildSlotProp = tower.buildSlotProp
  local owner = tower:GetOwner()

  if newTower ~= nil then
    towerName = newTower;
  end

  local towerEntIndex = tower:entindex()

  if owner == nil then
    return tower
  end

  local PLAYTEST_MIRROR_SELL_LIST = tower.PLAYTEST_MIRROR_SELL_LIST

  local items = {}
  local nRapiers = 0

  for i = 0, 6 do
    local item = tower:GetItemInSlot(i)

    if item ~= nil and item:GetName() ~= "item_rapier" then
      table.insert(items, item)
    elseif item ~= nil and item:GetName() == "item_rapier" then
      nRapiers = nRapiers + 1
      tower:RemoveItem(item)
    end
  end

  local nevermore_soul_stacks = 0

  if tower:HasModifier("modifier_nevermore_necromastery") then
    local modifier = tower:FindModifierByName("modifier_nevermore_necromastery")
    nevermore_soul_stacks = modifier:GetStackCount()
  end

  --owner == nil when mirror
  if owner ~= nil then
    --search and remove
    for i = 1, #owner.PGS.towerList do
      if owner.PGS.towerList[i] == tower then
        table.remove(owner.PGS.towerList, i)
        break
      end
    end
  end

  tower:AddNoDraw()
  tower:ForceKill(false)
  tower = nil

  local newTower = CreateUnitByName(towerName, location, false, owner, owner, DOTA_TEAM_GOODGUYS)

  if owner ~= nil then
    newTower:SetControllableByPlayer(owner:GetPlayerID(), true)
  end

  newTower:AddAbility("sell_tower")

  local a = newTower:FindAbilityByName("sell_tower")
  a:StartCooldown(1)
  a:SetLevel(1)

  if owner ~= nil then
    table.insert(owner.PGS.towerList, newTower)
  end

  newTower.isATower = true
  newTower.refundGold = refundGold
  newTower.buildSlotProp = buildSlotProp

  for i = 1, #items do
    newTower:AddItem(items[i])
  end

  for i = 1, nRapiers do
    newTower:AddItemByName("item_rapier")
  end

  if nevermore_soul_stacks > 0 then
    local modifier = newTower:FindModifierByName("modifier_nevermore_necromastery")
    modifier:SetStackCount(nevermore_soul_stacks)
  end

  newTower.PLAYTEST_MIRROR_SELL_LIST = PLAYTEST_MIRROR_SELL_LIST

  --for the javascript
  CustomGameEventManager:Send_ServerToAllClients("TowerCloned", {oldEntIndex = towerEntIndex, newEntIndex = newTower:entindex()} )

  return newTower
end

function buildNewTower(keys)
  GameMode:buildNewTower(keys)
end

function GameMode:buildNewTower(keys)
  --PrintTable(keys)
  local caster = keys.caster
  local ability = keys.ability

  local ability_name = ability:GetAbilityName()
  local location = caster:GetAbsOrigin()

  local cost = ability:GetGoldCost(ability:GetLevel())

  local owner = caster:GetOwner()

  owner.PGS.networth = owner.PGS.networth + cost
  CustomNetTables:SetTableValue( "players_Networth", "player" .. owner:GetPlayerID(), {value = owner.PGS.networth} );

  --caster:ForceKill(false)
  local tower = CreateNewTower(string.sub(ability_name, 7), caster, owner, cost)

  if owner.PGS.spawnerDisabled then
    tower:AddNewModifier(tower, nil, "modifier_earthshaker_fissure_stun", nil)
  end

  if keys.Ability1Level ~= nil then
    tower:GetAbilityByIndex(1-1):SetLevel(keys.Ability1Level)
  end
   if keys.Ability2Level ~= nil then
    tower:GetAbilityByIndex(2-1):SetLevel(keys.Ability2Level)
  end
   if keys.Ability3Level ~= nil then
    tower:GetAbilityByIndex(3-1):SetLevel(keys.Ability3Level)
  end
   if keys.Ability4Level ~= nil then
    tower:GetAbilityByIndex(4-1):SetLevel(keys.Ability4Level)
  end

  --toggle on toogle abilities
  for i = 0, tower:GetAbilityCount() - 1 do
    if tower:GetAbilityByIndex(i) ~= nil then

      if tower:GetAbilityByIndex(i):IsToggle() then
        tower:GetAbilityByIndex(i):ToggleAbility()
      end
      --tower:GetAbilityByIndex(i):ToggleAutoCast()
    end
  end

  --remove all the casters abilities
  clearUnitAbilities(caster)

  caster.buildSlotProp:Kill()
  caster:ForceKill(false)
  caster:AddNoDraw()

  CustomGameEventManager:Send_ServerToPlayer(owner.PGS.player, "SelectUnitEvent", {entid = tower:GetEntityIndex()} )

  --lvlUpUnitAbilities(caster)

  if PLAYTEST then
    local vec = location
    local tx = vec.x
    local ty = vec.y
    local de = -(math.pi/2)

    vec.x = (tx * math.cos(de)) - (ty * math.sin(de))
    vec.y = (ty * math.cos(de)) + (tx * math.sin(de))

    local unit = CreateUnitByName(string.sub(ability_name, 7), vec, false, nil, nil, DOTA_TEAM_GOODGUYS)
    unit.IS_PLAYTEST_MIRROR = true;
    tower.PLAYTEST_MIRROR_SELL_LIST = {}
    table.insert(tower.PLAYTEST_MIRROR_SELL_LIST, unit)

    tx = vec.x
    ty = vec.y
    de = de - (math.pi/2)

    vec.x = (tx * math.cos(de)) - (ty * math.sin(de))
    vec.y = (ty * math.cos(de)) + (tx * math.sin(de))

    local unit2 = CreateUnitByName(string.sub(ability_name, 7), vec, false, nil, nil, DOTA_TEAM_GOODGUYS)
    unit2.IS_PLAYTEST_MIRROR = true;
    table.insert(tower.PLAYTEST_MIRROR_SELL_LIST, unit2)

    tx = vec.x
    ty = vec.y
    de = de - (math.pi/2)

    vec.x = (tx * math.cos(de)) - (ty * math.sin(de))
    vec.y = (ty * math.cos(de)) + (tx * math.sin(de))

    local unit3 = CreateUnitByName(string.sub(ability_name, 7), vec, false, nil, nil, DOTA_TEAM_GOODGUYS)
    unit3.IS_PLAYTEST_MIRROR = true;
    table.insert(tower.PLAYTEST_MIRROR_SELL_LIST, unit3)
  end
end

function sellTower(keys)
  GameMode:sellTower(keys)
end

function GameMode:sellTower(keys)
  local caster = keys.caster
  local owner = caster:GetOwner()

  --search and remove
  for i = 1, #owner.PGS.towerList do
    if owner.PGS.towerList[i] == caster then
      table.remove(owner.PGS.towerList, i)
      break
    end
  end

  --drop all items
  for i = 0, 6 do
    local item = caster:GetItemInSlot(i)
    if item ~= nil then
      caster:DropItemAtPositionImmediate(item, caster:GetAbsOrigin())
    end
  end

  --caster:GetOwner():ModifyGold(caster.RefundGold, true, DOTA_ModifyGold_CreepKill)

  local bountyDummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)

  bountyDummy:AddNoDraw()
  bountyDummy:SetMaximumGoldBounty(caster.refundGold)
  bountyDummy:SetMinimumGoldBounty(caster.refundGold)
  bountyDummy:SetHullRadius(0)
  bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_item_phase_boots_active", nil)
  bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_invulnerable", nil)

  Timers:CreateTimer(0.1, function() bountyDummy:Kill(nil, caster:GetOwner()) return nil end)

  owner.PGS.networth = owner.PGS.networth - (caster.refundGold * CONST_INVERSE_SELL_LOSS)

  CustomNetTables:SetTableValue( "players_Networth", "player" .. owner:GetPlayerID(), {value = owner.PGS.networth} );
  CustomNetTables:SetTableValue( "players_nTowers", "player" .. owner:GetPlayerID(), {value = #owner.PGS.towerList} );

  if PLAYTEST and caster.PLAYTEST_MIRROR_SELL_LIST ~= nil then
    for k, v in pairs(caster.PLAYTEST_MIRROR_SELL_LIST) do
      v:ForceKill(false)
    end
  end

  caster.buildSlotProp:Kill()

  local vec = caster:GetAbsOrigin()
  caster:ForceKill(false)

  local newTowerSlot = GameMode:CreateTowerSlot(owner, vec)

  CustomGameEventManager:Send_ServerToPlayer(owner.PGS.player, "SelectUnitEvent", {entid = newTowerSlot:GetEntityIndex()} )
end

function upgradeTower(keys)
  local caster = keys.caster
  local ability = keys.ability

  local ability_name = nil

  if keys.IS_MIRROR == nil then
    ability_name = ability:GetAbilityName()
  else
    ability_name = keys.STORED_NAME
  end

  local location = caster:GetAbsOrigin()

  local cost = 0

  local owner = caster:GetOwner()

  if keys.IS_MIRROR == nil then
    cost = ability:GetGoldCost(ability:GetLevel())

    owner.PGS.networth = owner.PGS.networth + cost
    CustomNetTables:SetTableValue( "players_Networth", "player" .. owner:GetPlayerID(), {value = owner.PGS.networth} );
  end

  local sellAbility = caster:FindAbilityByName("sell_tower")

  --needed for playtest since mirrored towers don't have the sell_tower ability.
  if sellAbility ~= nil then
    sellAbility:StartCooldown(5.0)
  end

  --caster:RemoveAbility(ability_name)

  if keys.IS_MIRROR == nil then
    caster.refundGold = caster.refundGold + (cost * CONST_SELL_LOSS)
  end

  if keys.UpgradeTower ~= nil then
    --if the unit already has a ability with the same name just change level!

    local tower = CloneAndRemoveTower(caster, keys.UpgradeTower)

    if keys.IS_MIRROR == nil then
      if keys.UpgradeAbility1 ~= nil then
        tower:GetAbilityByIndex(1-1):SetLevel(keys.UpgradeAbility1)
      end
      if keys.UpgradeAbility2 ~= nil then
        tower:GetAbilityByIndex(2-1):SetLevel(keys.UpgradeAbility2)
      end
      if keys.UpgradeAbility3 ~= nil then
        tower:GetAbilityByIndex(3-1):SetLevel(keys.UpgradeAbility3)
      end
      if keys.UpgradeAbility4 ~= nil then
        tower:GetAbilityByIndex(4-1):SetLevel(keys.UpgradeAbility4)
      end

      --toggle on toogle abilities
      for i = 0, tower:GetAbilityCount() - 1 do
        if tower:GetAbilityByIndex(i) ~= nil then

          if tower:GetAbilityByIndex(i):IsToggle() then
            tower:GetAbilityByIndex(i):ToggleAbility()
          end
          --tower:GetAbilityByIndex(i):ToggleAutoCast()
        end
      end
    end

    caster = tower
    caster:RemoveAbility(ability_name)

    if owner ~= nil then
      CustomGameEventManager:Send_ServerToPlayer(owner.PGS.player, "SelectUnitEvent", {entid = tower:GetEntityIndex()} )
    end
  end
  
  if PLAYTEST and keys.IS_MIRROR == nil and caster.PLAYTEST_MIRROR_SELL_LIST ~= nil then
    for k, v in pairs(caster.PLAYTEST_MIRROR_SELL_LIST) do
      local newKeys = shallowcopy(keys)
      newKeys.caster = v
      newKeys.IS_MIRROR = true
      newKeys.STORED_NAME = ability_name
      upgradeTower(newKeys)
    end
  end
end

function goToPage(keys)
  GameMode:goToPage(keys)
end

function GameMode:goToPage(keys)
  local caster = keys.caster
  local ability = keys.ability
  local ability_name = ability:GetAbilityName()

  clearUnitAbilities(caster)

  caster:AddAbility("return_to_start_page")

  if ability_name == "open_page_one" then

    caster:AddAbility("build_tower_windrunner")
    caster:AddAbility("build_tower_spirit_breaker")
    caster:AddAbility("build_tower_templar_assassin")
    caster:AddAbility("build_tower_phantom_assassin")
    caster:AddAbility("build_tower_venomancer")

  elseif ability_name == "open_page_two" then

    caster:AddAbility("build_tower_nevermore")
    caster:AddAbility("build_tower_weaver")
    caster:AddAbility("build_tower_witch_doctor")
    caster:AddAbility("build_tower_abyssal_underlord")
    caster:AddAbility("build_tower_techies")
    
  elseif ability_name == "open_page_three" then
    caster:AddAbility("build_tower_sven") 
    caster:AddAbility("build_tower_ursa")
    caster:AddAbility("build_tower_gyrocopter")
    caster:AddAbility("build_tower_crystal_maiden")
    caster:AddAbility("build_tower_sniper")

  elseif ability_name == "open_page_four" then
    caster:AddAbility("build_tower_luna")
    caster:AddAbility("build_tower_wisp")
    caster:AddAbility("build_tower_dragon_knight")
    caster:AddAbility("build_tower_zuus")
    caster:AddAbility("build_tower_ember_spirit")

  elseif ability_name == "open_page_five" then
    caster:AddAbility("build_tower_kunkka")
    caster:AddAbility("build_tower_warlock")
    caster:AddAbility("build_tower_medusa")
    --caster:AddAbility("build_tower_life_stealer")
  end

  lvlUpUnitAbilities(caster)
end

function returnToStartPage(keys)
  GameMode:returnToStartPage(keys)
end

function GameMode:returnToStartPage(keys)
  local caster = keys.caster
  local ability = keys.ability

  local ability_name = ability:GetAbilityName()

  clearUnitAbilities(caster)

  caster:AddAbility("open_page_one")
  caster:AddAbility("open_page_two")
  caster:AddAbility("open_page_three")
  caster:AddAbility("open_page_four")
  caster:AddAbility("open_page_five")

  lvlUpUnitAbilities(caster)
end

function sellItems(keys)
  GameMode:sellItems(keys)
end

function GameMode:sellItems(keys)
  local caster = keys.caster
  local totalCost = 0

  for i = 0, 6 do
    local item = caster:GetItemInSlot(i)

    if item ~= nil then
      totalCost = totalCost + (GetItemCost(item:GetName()) * .5)
      caster:RemoveItem(item)
    end
  end

  if totalCost > 0 then
    local bountyDummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)

    bountyDummy:AddNoDraw()
    bountyDummy:SetMaximumGoldBounty(totalCost)
    bountyDummy:SetMinimumGoldBounty(totalCost)
    bountyDummy:SetHullRadius(0)
    bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_item_phase_boots_active", nil)
    bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_invulnerable", nil)

    Timers:CreateTimer(0.1, function() bountyDummy:Kill(nil, caster) return nil end)
  end
end