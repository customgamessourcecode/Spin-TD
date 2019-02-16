local WAVES = {}

local function Wave(creep, numTotal, numPerSpawn, bonusEndGold, bigLeadTax)
  local newWave = {}
  
  newWave.isBoss = false
	newWave.creep = creep
	newWave.numTotal = numTotal
	newWave.numPerSpawn = numPerSpawn
  newWave.bonusEndGold = bonusEndGold
  newWave.lifePenalty = 1
  newWave.bigLeadTax = bigLeadTax

	return newWave
end

local function Boss(creep, numTotal, numPerSpawn, bonusEndGold, lifePenalty)
  local newWave = {}

  newWave.isBoss = true
  newWave.creep = creep
  newWave.numTotal = numTotal
  newWave.numPerSpawn = numPerSpawn
  newWave.bonusEndGold = bonusEndGold
  newWave.lifePenalty = lifePenalty
  newWave.bigLeadTax = 5

  return newWave
end

WAVES.waveTable = {}

WAVES.waveTable[1] 	  = Wave("creep_boar",                            18, 3, 6, 0.25)
WAVES.waveTable[2] 	  = Wave("creep_donkey",                          21, 3, 6, 0.25)
WAVES.waveTable[3] 	  = Wave("creep_imp",                             24, 3, 6, 0.25)
WAVES.waveTable[4] 	  = Wave("creep_necro_warrior",                   33, 3, 0, 0.25)
WAVES.waveTable[5] 	  = Wave("creep_snowleopard",                     39, 3, 0, 0.25)

WAVES.waveTable[6] 	  = Wave("creep_ogre_med",                        45, 3, 0, 0.5)
WAVES.waveTable[7]	  = Wave("creep_centaur_med",                     45, 3, 0, 0.5)
WAVES.waveTable[8] 	  = Wave("creep_beast",                           45, 3, 0, 0.5)
WAVES.waveTable[9] 	  = Wave("creep_worg_large",                      45, 3, 0, 0.5)
WAVES.waveTable[10] 	= Boss("boss_fish_hex",                         1, 1, 0, 5)

WAVES.waveTable[11] 	= Wave("creep_horse",                           30, 2, 0, 1.0)
WAVES.waveTable[12] 	= Wave("creep_virulent_matriarchs_spiderling",  45, 3, 0, 1.0)
WAVES.waveTable[13] 	= Wave("creep_shroomling_treant",               45, 3, 0, 1.0)
WAVES.waveTable[14] 	= Wave("creep_golem",                           45, 3, 0, 1.0)
WAVES.waveTable[15] 	= Boss("boss_spamm_messer",                     1, 1, 0, 3)

WAVES.waveTable[16] 	= Wave("creep_bad_melee_diretide",              40, 2, 0, 1.50)
WAVES.waveTable[17] 	= Wave("creep_radiant_melee_diretide",          45, 3, 0, 1.50)
WAVES.waveTable[18] 	= Wave("creep_kobold",                          45, 3, 0, 1.50)
WAVES.waveTable[19] 	= Wave("creep_skeleton",                        45, 3, 0, 1.50)
WAVES.waveTable[20] 	= Boss("boss_pudge",                            1, 1, 0, 5)

WAVES.waveTable[21]   = Wave("creep_weaver_bug",                      54, 5, 0, 1.75)
WAVES.waveTable[22]   = Wave("creep_centaur_lrg",                     45, 3, 0, 1.75)
WAVES.waveTable[23]   = Wave("creep_gargoyle",                        45, 3, 0, 1.75)
WAVES.waveTable[24]   = Wave("creep_troll",                           45, 3, 0, 1.75)
WAVES.waveTable[25]   = Boss("boss_high_priest",                      3, 1, 0, 5)

WAVES.waveTable[26]   = Wave("creep_treant",                          45, 3, 0, 2)
WAVES.waveTable[27]   = Wave("creep_forge_spirit",                    45, 3, 0, 2)
WAVES.waveTable[28]   = Wave("creep_spirit_bear",                     45, 3, 0, 2)
WAVES.waveTable[29]   = Wave("creep_black_dragon",                    45, 3, 0, 2)
WAVES.waveTable[30]   = Boss("boss_lycan",                            1, 1, 0, 8)

WAVES.waveTable[31]   = Wave("creep_spiderling",                      45, 3, 0, 2.25)
WAVES.waveTable[32]   = Wave("creep_warlock_demon",                   45, 3, 0, 2.25)
WAVES.waveTable[33]   = Wave("creep_beast_wolf",                      45, 3, 0, 2.25)
WAVES.waveTable[34]   = Wave("creep_fernando",                        45, 3, 0, 2.25)
WAVES.waveTable[35]   = Boss("boss_nyx",                              1, 1, 0, 8)

WAVES.waveTable[36]   = Wave("creep_harpy",                           45, 3, 0, 2.5)
WAVES.waveTable[37]   = Wave("creep_torchbearer",                     45, 3, 0, 2.5)
WAVES.waveTable[38]   = Wave("creep_beastmaster_bird",                45, 3, 0, 2.5)
WAVES.waveTable[39]   = Wave("creep_wolf_hunter_true_form",           45, 3, 0, 2.5)
WAVES.waveTable[40]   = Boss("boss_faceless_void",                    1, 1, 0, 10)

WAVES.waveTable[41]   = Wave("creep_radiant_ranged_mega",             45, 3, 0, 2.5)
WAVES.waveTable[42]   = Wave("creep_radiant_melee_mega",              45, 3, 0, 2.5)
WAVES.waveTable[43]   = Wave("creep_dire_ranged_mega",                45, 3, 0, 2.5)
WAVES.waveTable[44]   = Wave("creep_bad_melee_mega",                  45, 3, 0, 2.5)
WAVES.waveTable[45]   = Boss("boss_tony",                             1, 1, 0, 10)

WAVES.waveTable[46]   = Wave("creep_beast_heart_marauder_raven",      45, 3, 0, 2.5)
WAVES.waveTable[47]   = Wave("creep_furion_treant_nelum_red",         45, 3, 0, 2.5)
WAVES.waveTable[48]   = Wave("creep_nightlord_crypt_sentinel",        45, 3, 0, 2.5)
WAVES.waveTable[49]   = Wave("creep_ravenous_woodfang",               45, 3, 0, 2.5)
WAVES.waveTable[50]   = Boss("boss_roshan_spintd",                         1, 1, 0, 10)

return WAVES