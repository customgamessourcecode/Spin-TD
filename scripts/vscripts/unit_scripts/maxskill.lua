function MaxSkill(ability)

    if ability then
        local MaxLevel = ability:GetMaxLevel()
        ability:SetLevel(MaxLevel )
    end
end

function Spawn( entityKeyValues )
    local name = thisEntity:GetUnitName()

    --[[if      name == "tower_templar" then
        MaxSkill(thisEntity:FindAbilityByName("templar_assassin_psi_blades"))
    elseif  name == "tower_sven"    then
        MaxSkill(thisEntity:FindAbilityByName("sven_great_cleave"))
    elseif  name == "tower_venomancer" then
        MaxSkill(thisEntity:FindAbilityByName("custom_venomancer_poison_sting"))
    elseif name == "tower_phantom_assassin" then
        MaxSkill(thisEntity:FindAbilityByName("phantom_assassin_coup_de_grace"))
    end

    if name == "tower_phantom_assassin" then
        local a = thisEntity:FindAbilityByName("phantom_assassin_coup_de_grace")
        a:SetLevel(1)
    elseif name == "tower_venomancer" then
        local a = thisEntity:FindAbilityByName("venomancer_poison_sting")
        a:SetLevel(3)
    elseif name == "tower_shadow_fiend" then
        local a = thisEntity:FindAbilityByName("nevermore_necromastery")
        a:SetLevel(1)
    elseif name == "tower_luna" then
        local a = thisEntity:FindAbilityByName("luna_moon_glaive")
        a:SetLevel(3)
    else
        for i = 0, thisEntity:GetAbilityCount()-1 do
          local a = thisEntity:GetAbilityByIndex(i)

          if a ~= nil then
            MaxSkill(a)
          end
        end
    end
]]--
end