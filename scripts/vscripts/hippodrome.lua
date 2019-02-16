local function lock_new_member(t, k, v)
  print("warning adding new Hippodrome member after new: " .. k)
end

Hippodrome = {}

function Hippodrome:new()
	newObj = 
	{
		vHorses = {},
    raceUnderWay = false
	}

 	self.__index = self
  self.__newindex = lock_new_member
 	return setmetatable(newObj, self)
end

function Hippodrome:Init()
end

function Hippodrome:Start()
  self.raceUnderWay = true
end

function Hippodrome:IsRaceUnderWay()
  return self.raceUnderWay
end