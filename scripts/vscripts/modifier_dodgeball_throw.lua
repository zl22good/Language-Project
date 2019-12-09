modifier_dodgeball_throw = class({})

--------------------------------------------------------------------------------

function IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf"
end

--------------------------------------------------------------------------------

function GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

--------------------------------------------------------------------------------

function OnCreated( key)
	keys.ability.armor_reduction = keys.ability:GetSpecialValueFor( "armor_reduction" )
end

--------------------------------------------------------------------------------

function OnRefresh( key, kv )
	keys.ability.armor_reduction = keys.ability:GetSpecialValueFor( "armor_reduction" )
end

--------------------------------------------------------------------------------

function DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

--------------------------------------------------------------------------------

function GetModifierPhysicalArmorBonus( keys, params )
	return keys.ability.armor_reduction
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
