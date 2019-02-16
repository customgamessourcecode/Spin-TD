modifier_super_speed_lua = class({})

--------------------------------------------------------------------------------

function modifier_super_speed_lua:DeclareFunctions()
  local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_super_speed_lua:IsHidden()
    return true
end

function modifier_super_speed_lua:GetTexture()
  return "rune_regen"
end

function modifier_super_speed_lua:GetModifierMoveSpeed_Max( params )
    return 4000
end

function modifier_super_speed_lua:GetModifierMoveSpeed_Limit( params )
    return 4000
end


