function SpinAbility(keys)
  local caster = keys.caster
  local ability = keys.ability

  GameMode.slotmachine:StartSpin(caster, ability:GetGoldCost(ability:GetLevel()), nil)
end

local function lock_new_member(t, k, v)
  print("warning adding new SlotMachine member after new: " .. k)
end

SlotMachine = {}

function SlotMachine:new()
	newObj = 
	{
		slotWidth = 3,
		slotHeight = 4,
		stripLength = 6,
		field = {},
		currentPlayer = NULL_TABLE,
		symbols = {},
		rotateSymbol = {},
		payouts = {},
		msgTable = {},
		offsets = {},
		activeSymbols = {},
		ogre = {},
    nActiveSymbols = 0,
    spinsPerStrip = {},
    completeStripCounter = 0,
    lost = false,
    currentBet = 0,
    currentCycle = 1
	}

 	self.__index = self
  self.__newindex = lock_new_member
 	return setmetatable(newObj, self)
end

function SlotMachine:Init()

	for x = 1, self.slotWidth do
		self.field[x] = {}
		for y = 1, self.stripLength do
			self.field[x][y] = "ERROR"
		end
 	end

	self.symbols[1] =  "slot_gold_greevil"
	self.symbols[2] =  "slot_frog"
	self.symbols[3] =  "slot_lockjaw"
	self.symbols[4] =  "slot_trapjaw"
	self.symbols[5] =  "slot_mega_greevil"
	self.symbols[6] =  "slot_sheep"
	self.symbols[7] =  "slot_present"
	self.symbols[8] =  "slot_treasure_chest"
	self.symbols[9] =  "slot_red_box"
	self.symbols[10] = "slot_branch"

	self.rotateSymbol["slot_treasure_chest"] = 90

	self.payouts["slot_gold_greevil"]    = {betMult = 15.0}
	self.payouts["slot_frog"]            = {betMult = 1.5}
	self.payouts["slot_lockjaw"]         = {betMult = 4.0}
	self.payouts["slot_trapjaw"]         = {betMult = 6.0}
	self.payouts["slot_mega_greevil"]    = {betMult = 8.0}
	self.payouts["slot_sheep"]           = {betMult = 2.0}
	self.payouts["slot_present"]         = {item = ITEMS_TIER[2]}
	self.payouts["slot_treasure_chest"]  = {item = ITEMS_TIER[3]}
	self.payouts["slot_red_box"]         = {item = ITEMS_TIER[4]}
	self.payouts["slot_branch"]          = {item = ITEMS_TIER[1]}

	self.msgTable = {}

	self.msgTable["slot_gold_greevil"]   = {text="#slot_gold_greevil_msg " .. self.payouts["slot_gold_greevil"].betMult .. "#slot_mult_symbol !", duration=5, style=
	{
		color="#FFD700",
		["text-shadow"]="0 0 24px #EEB589",
		["font-size"]="110px"
	}, continue=false}

	self.msgTable["slot_frog"]           = {text="#slot_frog_msg " .. self.payouts["slot_frog"].betMult .. "#slot_mult_symbol", duration=5, style={color="#11FF20"}, continue=false, dialog={number = self.payouts["slot_frog"].betMult}}
	self.msgTable["slot_lockjaw"]        = {text="#slot_lockjaw_msg " .. self.payouts["slot_lockjaw"].betMult .. "#slot_mult_symbol", duration=5, style={color="#FFD700"}, continue=false, dialog={number = 10}}
	self.msgTable["slot_trapjaw"]        = {text="#slot_trapjaw_msg " .. self.payouts["slot_trapjaw"].betMult .. "#slot_mult_symbol", duration=5, style={color="#FFD700"}, continue=false, dialog={number = 10}}
	self.msgTable["slot_mega_greevil"]   = {text="#slot_mega_greevil_msg " .. self.payouts["slot_mega_greevil"].betMult .. "#slot_mult_symbol !", duration=5, style={color="#FFD700"}, continue=false, dialog={number = 10}}
	self.msgTable["slot_sheep"]          = {text="#slot_sheep_msg " .. self.payouts["slot_sheep"].betMult .. "#slot_mult_symbol", duration=5, style={color="#FFD700"}, continue=false, dialog={number = 10}}
	self.msgTable["slot_present"]        = {text="#slot_present_msg ", duration=5, style={color="#006b8e"}, continue=false}
	self.msgTable["slot_treasure_chest"] = {text="#slot_treasure_chest_msg ", duration=5, style={color="#006b8e"}, continue=false}
	self.msgTable["slot_red_box"]        = {text="#slot_treasure_chest_msg ", duration=5, style={color="#006b8e"}, continue=false}
	self.msgTable["slot_branch"]        = {text="#slot_treasure_chest_msg ", duration=5, style={color="#006b8e"}, continue=false}

	self.offsets = {}

	self.activeSymbols = {}
	self.nActiveSymbols = 0

	self.ogre = CreateUnitByName("npc_ogre_anim", Vector(700, 700), false, nil, nil, DOTA_TEAM_GOODGUYS)
	self.ogre:AddNewModifier(symbol_creature, nil, "modifier_invulnerable", nil)
	--self.ogre:SetAngles(0, math.pi/2.0, 0)
	self.ogre:SetForwardVector(Vector(-1, -0.3))
end

function SlotMachine:PrintField()
	print("==============================================================================================")
	for y = 1, self.stripLength do
		print(self.field[1][y] .. ", " .. self.field[2][y] .. ", " .. self.field[3][y])
	end
	print("==============================================================================================\n")
end

function SlotMachine:RandSymbol()
	local nSymbols = #self.symbols
	local randSymbol = self.symbols[math.random(1,nSymbols)]

	if self.currentBet == 10 then
		while randSymbol == "slot_red_box" do
			randSymbol = self.symbols[math.random(1,nSymbols)]
		end
	else
		while randSymbol == "slot_branch" do
			randSymbol = self.symbols[math.random(1,nSymbols)]
		end
	end

	return randSymbol
end

function SlotMachine:GenerateLostRow(row)
	local lostRow = false
    while lostRow == false do
    	for x = 1, self.slotWidth do
    		self.field[x][row] = self:RandSymbol()
    	end

    	local firstSymbol = self.field[1][row]

    	for x = 2, self.slotWidth do
        	if self.field[x][row] ~= firstSymbol then
        		lostRow = true
        	end
    	end
    end
end

function SlotMachine:GenerateCloseButNoWinRow(row)
	local symbol1 = self:RandSymbol()

	for x = 1, self.slotWidth - 1 do
	    self.field[x][row] = symbol1
	end

	local symbol2 = symbol1

	while symbol2 == symbol1 do
		symbol2 = self:RandSymbol()
		self.field[self.slotWidth][row] = symbol2
	end
end

function SlotMachine:GenerateSequence(seqName)

  --BUILD WINNIN SEQUENCE IN PLACE
  --SHIFT STRIPS UP AND DOWN remember offsets
  --use offsets to animate!
  --?????
  --profit

  --so first if this is a winning sequence make the first row it!
	if seqName ~= "loss" then

	for x = 1, self.slotWidth do
		self.field[x][1] = seqName
	end

	else
		local r = math.random(1, 100)

		if r >= 50 then
			self:GenerateCloseButNoWinRow(1)
		else
			self:GenerateLostRow(1)
		end
	end

	--next fill rest of rows with junk
	for y = 2, self.stripLength do
		self:GenerateLostRow(y)
	end

	--make some offsets
	local halfStrip = self.stripLength/2
	local lastOffset = halfStrip
	self.offsets[1] = lastOffset
	for x = 2, self.slotWidth do
		self.offsets[x] = math.random(lastOffset+(halfStrip),lastOffset+(3*halfStrip))
		lastOffset = self.offsets[x]
	end

end

function SlotMachine:StartSpin(playerHero, bet, testWin)

	--print("spinning")

	if self.currentPlayer ~= NULL_TABLE then
		playerHero:ModifyGold(bet, true, 0)
		return
	end

	for k, v in pairs(GameMode.vPlayers) do

		local a = v:FindAbilityByName("slot_spin")
		if a ~= nil and a:GetCooldownTimeRemaining() < 15 then
			a:EndCooldown()
			a:StartCooldown(15)
		end

		a = v:FindAbilityByName("slot_spin2")
		if a ~= nil and a:GetCooldownTimeRemaining() < 15 then
			a:EndCooldown()
			a:StartCooldown(15)
		end

	end

	if PLAYTEST == false then
		local a = playerHero:FindAbilityByName("slot_spin")
		if a ~= nil then
			a:EndCooldown()
			a:StartCooldown(80)
		end

		a = playerHero:FindAbilityByName("slot_spin2")
		if a ~= nil then
			a:EndCooldown()
			a:StartCooldown(80)
		end
	end

	if USE_RUBBERBAND and GameMode:numberOfActivePlayers() > 1 then
		GameMode.rubberBandFund = GameMode.rubberBandFund + bet*0.1
	end

	local _value = CustomNetTables:GetTableValue("players_SpinBalance", "player" .. playerHero:GetPlayerID())
	_value.value = _value.value - bet
	CustomNetTables:SetTableValue( "players_SpinBalance", "player" .. playerHero:GetPlayerID(), {value = _value.value} )

	self.currentPlayer = playerHero
	self.lost = false
	self.currentBet = bet

	Notifications:TopToAll({text=playerHero.PGS.playerName .. " ", duration=5, style={color="rgb(".. playerHero.PGS.customColor[1] .. "," .. playerHero.PGS.customColor[2] .. "," .. playerHero.PGS.customColor[3] .. ")"}, continue=false})
	Notifications:TopToAll({text=" #spins", duration=5, style={color="white"}, continue=true})

	EmitGlobalSound("Hero_OgreMagi.Fireblast.Cast")

	StartAnimation(self.ogre, {duration=2, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})

	Timers:CreateTimer(1.0, function()
	  StartAnimation(self.ogre, {duration=10, activity=ACT_DOTA_RUN, rate=2}) end)

	--notes for new alg
	--divide loss and win on the 1 100 scale
	--divide the win portion by ranks etc rank 1 gets half, rank 2 gets 0.5^2, rank 3 0.5^3 etc
	-- or maybe rank 1 (1/2), rank 2 (1/2*1/3), rank 3 (1/2*1/3*1/4)

	--local rNumber = math.random()*100.0--RandomFloat(1.0, 100.0)
	local rNumber = RandomFloat(1.0, 100.0)

	if playerHero.PGS.nSpinLossesInARow >= 2 then
		rNumber = RandomFloat(60.0, 85.0)
		playerHero.nSpinLossesInARow = 0
	end

	--print(rNumber)

	if testWin == nil or testWin < 1 then
		if rNumber <= 35.0 then
			-- generate a losing sequence
			self:GenerateSequence("loss")
			playerHero.PGS.nSpinLosses = playerHero.PGS.nSpinLosses + 1
			playerHero.PGS.nSpinLossesInARow = playerHero.PGS.nSpinLossesInARow + 1
			self.lost = true
		elseif rNumber <= 60.0 then--25%
			playerHero.PGS.nSpinLossesInARow = 0
			local r = math.random(1, 4)
			if bet == 10 then
				if r < 4 then
					self:GenerateSequence("slot_branch")
				else
					self:GenerateSequence("slot_present")
				end
			else
				if r < 3 then
					self:GenerateSequence("slot_present")
				else
					self:GenerateSequence("slot_treasure_chest")
				end
			end
		elseif rNumber <= 80.0 then
			--20 % to get here
			playerHero.PGS.nSpinLossesInARow = 0
			local r = math.random(1, 2)

			if r == 1 then
				if bet == 10 then
					self:GenerateSequence("slot_present")--10%
				else
					self:GenerateSequence("slot_treasure_chest")--10%
				end
			else
				self:GenerateSequence("slot_frog")--10%
			end

		elseif rNumber <= 90.0 then
			--10%
			playerHero.PGS.nSpinLossesInARow = 0
			local r = math.random(1, 2)

			if r == 1 then
				if bet == 10 then
					self:GenerateSequence("slot_treasure_chest")--5%
				else
					self:GenerateSequence("slot_red_box")--5%
				end
			else
				self:GenerateSequence("slot_sheep")--5%
			end
		elseif rNumber <= 95.0 then
			playerHero.PGS.nSpinLossesInARow = 0
			self:GenerateSequence("slot_lockjaw")--5%
		elseif rNumber <= 98.0 then
			playerHero.PGS.nSpinLossesInARow = 0
			self:GenerateSequence("slot_trapjaw")--3%
		elseif rNumber <= 99.7 then
			playerHero.PGS.nSpinLossesInARow = 0
			self:GenerateSequence("slot_mega_greevil")--1.7%
		else
			playerHero.PGS.nSpinLossesInARow = 0
			self:GenerateSequence("slot_gold_greevil")--0.3%
		end
	else
		self:GenerateSequence(self.symbols[testWin])
	end

	--self:PrintField()

	self.currentCycle = 1

	self.activeSymbols = {}
	self.nActiveSymbols = 0
	self.spinsPerStrip = {}
	self.completeStripCounter = 0

	for x = 1, self.slotWidth do
		self.spinsPerStrip[x] = 0
	end

	--self:SpawnRow()

	Timers:CreateTimer(1.0/3.0, function()
	  return self:SpawnRow()
	end)
end

function SlotMachine:Wrap(num)
	local wrapd = num % self.stripLength

	if wrapd == 0 then
		wrapd = self.stripLength
	end

	return wrapd
end

function SlotMachine:SpawnRow()

	local xSpacing = 256
	local xStartOffset = xSpacing * -math.floor(self.slotWidth/2)
	local stop = false

	for x = self.completeStripCounter + 1, self.slotWidth do

	  local cycleWrapdInner = self:Wrap(self.currentCycle + self.offsets[x])
	  local location = Vector(xStartOffset + (x-1)*xSpacing, 800)
	  local symbol = self.field[x][cycleWrapdInner]
	  local symbol_creature = CreateUnitByName("npc_" .. symbol, location, false, nil, nil, DOTA_TEAM_GOODGUYS)

	  symbol_creature:SetHullRadius(2)
	  symbol_creature:AddNewModifier(symbol_creature, nil, "modifier_super_speed_lua", nil)
	  symbol_creature:AddNewModifier(symbol_creature, nil, "modifier_item_phase_boots_active", nil)
	  symbol_creature:AddNewModifier(symbol_creature, nil, "modifier_invulnerable", nil)
	  symbol_creature:AddNewModifier(symbol_creature, nil, "modifier_spectre_spectral_dagger_path_phased", nil)

	  if self.rotateSymbol[symbol] ~= nil then
	    symbol_creature:SetForwardVector(Vector(1, 0))
	  end

	  --[[
	  modifier_item_phase_boots_active --good
	  modifier_pudge_meat_hook_pathingfix --makes them flying
	  modifier_attack_immune
	  modifier_invulnerable
	  modifier_spectre_spectral_dagger_path_phased --makes them flying
	  modifier_truesight
	  --]]

	  symbol_creature.SLOT_Creep = true

	  self.activeSymbols[self.nActiveSymbols] = symbol_creature
	  symbol_creature.SymbolIndex = self.nActiveSymbols
	  self.nActiveSymbols = self.nActiveSymbols + 1

	  local target = Vector(location.x, -location.y)

	  if self.spinsPerStrip[x] > self.offsets[x] and cycleWrapdInner == 1 then
	    target.y = 0
	    self.completeStripCounter = self.completeStripCounter + 1

	    Timers:CreateTimer(1.0, function()
	    EmitGlobalSound("Hero_OgreMagi.Fireblast.x1") end)

	    if x == self.slotWidth then
	      stop = true

	      Timers:CreateTimer(1.0, function()
	        if self.lost then

	          Notifications:TopToAll({text=self.currentPlayer.PGS.playerName .. " ", duration=5, style={color="rgb(".. self.currentPlayer.PGS.customColor[1] .. "," .. self.currentPlayer.PGS.customColor[2] .. "," .. self.currentPlayer.PGS.customColor[3] .. ")"}, continue=false})
	          Notifications:TopToAll({text="#no_luck", duration=5, style={color="red"}, continue=true})

	          --"ogre_magi_ogmag_ability_failure_01"
	          --"ogre_magi_ogmag_ability_failure_09"
	          EmitGlobalSound("ogre_magi_ogmag_ability_failure_0"..math.random(1, 9))
	          StartAnimation(self.ogre, {duration=3, activity=ACT_DOTA_DISABLED, rate=1})



	        else
	         self:PayoutSymbol(self.field[x][1], false)

	        end
	      end)


	    end
	  else
	    Timers:CreateTimer(2.0, function()

	      symbol_creature:AddNoDraw()
	      symbol_creature:ForceKill(false)
	      self.activeSymbols[symbol_creature.SymbolIndex] = nil

	      return nil
	    end)
	  end

	  local order = {
	    UnitIndex = symbol_creature:GetEntityIndex(),
	    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	    Position = target,
	    Queue = true
	  }

	  ExecuteOrderFromTable(order)

	  self.spinsPerStrip[x] = self.spinsPerStrip[x] + 1
	end

	self.currentCycle = self.currentCycle + 1

	if stop then
	  Timers:CreateTimer(5.0, function()

	      for key,value in pairs(self.activeSymbols) do
	        if value ~= nil then
	          value:AddNoDraw()
	          value:ForceKill(false)
	        end
	      end

	      self.currentPlayer = NULL_TABLE

	      return nil
	  end)
	  return nil
	end

	return 1.0/3.0
end

function SlotMachine:PayoutSymbol(symbol, toAllPlayers)

  local goldWinnings = nil

  if self.payouts[symbol].betMult ~= nil then
    goldWinnings = self.currentBet * self.payouts[symbol].betMult
  end

  local itemReward = nil

  if self.payouts[symbol].item ~= nil then
    itemReward = self.payouts[symbol].item[math.random(1, #self.payouts[symbol].item)]
  end

  if goldWinnings ~= nil then

    if toAllPlayers then
      for k, v in pairs(self.vPlayers) do
        v:ModifyGold(goldWinnings, true, 0)

        local _value = CustomNetTables:GetTableValue("players_SpinBalance", "player" .. v:GetPlayerID())
        _value.value = _value.value + goldWinnings
        CustomNetTables:SetTableValue( "players_SpinBalance", "player" .. player:GetPlayerID(), {value = _value.value} )
      end
    else
      self.currentPlayer:ModifyGold(goldWinnings, true, 0)

      local _value = CustomNetTables:GetTableValue("players_SpinBalance", "player" .. self.currentPlayer:GetPlayerID())
      _value.value = _value.value + goldWinnings
      CustomNetTables:SetTableValue( "players_SpinBalance", "player" .. self.currentPlayer:GetPlayerID(), {value = _value.value} )

    end
  end

  if itemReward ~= nil then

    if self.currentPlayer:GetNumItemsInInventory() < 6 then
      self.currentPlayer:AddItemByName(itemReward)
    else
      local newItem = CreateItem(itemReward, self.currentPlayer, self.currentPlayer)
      newItem:SetPurchaseTime(0)
      CreateItemOnPositionSync(self.currentPlayer:GetAbsOrigin(), newItem)
    end
    --i only use this on boos drops for now
    --self.currentPlayer.PGS.nItemRewards = self.PGS.currentPlayer.nItemRewards + 1
    GameMode:ItemTutorial(self.currentPlayer)

    local _value = CustomNetTables:GetTableValue("players_SpinBalance", "player" .. self.currentPlayer:GetPlayerID())
    _value.value = _value.value + GetItemCost(itemReward)
    CustomNetTables:SetTableValue( "players_SpinBalance", "player" .. self.currentPlayer:GetPlayerID(), {value = _value.value} )

  end

  Notifications:TopToAll(self.msgTable[symbol])
  Notifications:TopToAll({text=self.currentPlayer.PGS.playerName .. " ", duration=5, style={color="rgb(".. self.currentPlayer.PGS.customColor[1] .. "," .. self.currentPlayer.PGS.customColor[2] .. "," .. self.currentPlayer.PGS.customColor[3] .. ")"}, continue=false})

  if goldWinnings ~= nil then
    Notifications:TopToAll({text= " " .. goldWinnings .. " #gold", duration=5, style={color="yellow"}, continue=true})
  end

  if itemReward ~= nil then
    Notifications:TopToAll({item=itemReward, continue=true})
  end

  EmitGlobalSound("Hero_OgreMagi.Fireblast.x3")

  StartAnimation(self.ogre, {duration=3, activity=ACT_DOTA_TELEPORT, rate=3})

end