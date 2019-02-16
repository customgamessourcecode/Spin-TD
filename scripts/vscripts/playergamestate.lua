local function lock_new_member(t, k, v)
  print("warning adding new PGS member after new: " .. k)
end

PlayerGameState = {}

function PlayerGameState:new(plyID)

  newObj = 
  {
    player = PlayerResource:GetPlayer(plyID),
    playerName = PlayerResource:GetPlayerName(plyID),
    playerID = plyID,
    customColor = {255, 255, 255},
    nSpinLossesInARow = 0,
    nSpinLosses = 0,
    nItemRewards = 0,
    nTDCreepKills = 0,
    towerList = {},
    towerPlatformsList = {},
    stunPlayerUnitsNextTurn = false,
    spawnerDisabled = false,
    networth = 0,
    leadTaxAcc = 0,
    spawnerName = "",
    spawnerOffset = 0,
    speedLane = {}
  }

  self.__index = self
  self.__newindex = lock_new_member

  return setmetatable(newObj, self)
end

function PlayerGameState:IsDev()
  local steamID = PlayerResource:GetSteamAccountID(self.playerID)

  return steamID == 7888421 or steamID == 18159666
end