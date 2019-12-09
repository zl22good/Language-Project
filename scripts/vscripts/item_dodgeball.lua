--[[Author: The-l3asics
	Created: 12.2.2019
	This is a dodgeball item to be used for dodgeball, obviously]]

--[[Used in the kv files/ghad a modifier not implemented]]
item_dodgeball = class ({})
LinkLuaModifier( "modifier_dodgeball_throw", LUA_MODIFIER_MOTION_NONE )

--[[This may or may not be the same as the method below. Anyways, item isnt broke 
and troubleshooting things not broken is worthless]]
if item_dodgeball == nil then
	print ( '[item_dodgeball] creating item_dodgeball' )
	item_dodgeball = {} -- Creates an array to let us beable to index itemFunctions when creating new functions
	item_dodgeball.__index = item_dodgeball
end

--[[Creates a new item_dodgeball. I do not believe this works
	as its for lua_ability, and the item is data_driven because 2015 barebones info
	is floating around. This would be the easier, superior way]]
function item_dodgeball:new() -- Creates the new class
	print ( '[item_dodgeball] item_dodgeball:new' )
	o = o or {}
	setmetatable( o, item_dodgeball )
	return o
end


--[[Hey, you. You're finally awake. You were trying to code the project the night
before, right? Walked right into that Volvo ambush, same as us, and that neckbeard over there.
But seriously, drops and item on death and gives it a charge.]]
function DropItemOnDeath(keys) -- keys is the information sent by the ability
	print( '[item_dodgeball] DropItemOnDeath Called' )
	local killedUnit = EntIndexToHScript( keys.caster_entindex ) -- EntIndexToHScript takes the keys.caster_entindex, which is the number assigned to the entity that ran the function from the ability, and finds the actual entity from it.
	local itemName = tostring(keys.ability:GetAbilityName()) -- In order to drop only the item that ran the ability, the name needs to be grabbed. keys.ability gets the actual ability and then GetAbilityName() gets the configname of that ability such as juggernaut_blade_dance.
	if killedUnit:IsHero() or killedUnit:HasInventory() then -- In order to make sure that the unit that died actually has items, it checks if it is either a hero or if it has an inventory.
		Say(nil, ("Goodbye: "  .. keys.ability:GetInitialCharges()), false)
		for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
        	if killedUnit ~= nil then --checks to make sure the killed unit is not nonexistent.
        		local Item = killedUnit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
        		if Item ~= nil and Item:GetName() == itemName then -- makes sure that the item exists and making sure it is the correct item
        			local newItem = CreateItem(itemName, nil, nil) -- creates a new variable which recreates the item we want to drop and then sets it to have no owner
        			CreateItemOnPositionSync(killedUnit:GetOrigin(), newItem) -- takes the newItem variable and creates the physical item at the killed unit's location
        			newItem:SetCurrentCharges(1)
        			killedUnit:RemoveItem(Item) -- finally, the item is removed from the original units inventory.
        		end
        	end
		end
	end

end

function item_dodgeball:start() -- Runs whenever the item_dodgeball.lua is ran
	print('[item_dodgeball] item_dodgeball started!')
end

--[[When the spell starts with the associated ability in keys.ability
This will use a charge, and delete it once the charges run out. Then call
ThrownBall and pass the keys down to do logic]]
function OnSpellStart( keys )
	print('[item_dodgeball] item_dodgeball OnSpellStart started!')
	local ball = keys.ability --reference to dodgeball item
	
	--If there is only 1 ball, use it, delete dodgeball item
	if(ball:GetCurrentCharges() <= 1) then 
		ball:SetCurrentCharges(0)
		deleteItem(keys)
		return
	else
		--Holding multiple balls? just throw one
		ball:SetCurrentCharges(ball:GetCurrentCharges() - 1)
	end

	--Call ThrowBall, all of the logic on spell start
	ThrowBall(keys)
end



--[[Author: The-l3asics
	Date: 12.1.2019
	Should throw a ball from hero location. 12/8/2019 working item
	has been created. ]]
function ThrowBall( keys )
	local caster = keys.caster
	local caster_location = keys.caster:GetOrigin()
	local target_point = keys.caster:GetCursorPosition()
	local ability = keys.ability

	--Grab speical ball values from kv file (npc_items_custom)
	keys.ability.ball_speed = keys.ability:GetSpecialValueFor("ball_speed")
	keys.ability.ball_width = keys.ability:GetSpecialValueFor( "ball_width" )
	keys.ability.tooltip_duration = keys.ability:GetSpecialValueFor( "tooltip_duration" )
	keys.ability.ball_damage = keys.ability:GetSpecialValueFor( "ball_damage" )

	--Gets the correct direction to throw/aim projectile
	keys.ability.ball_direction = (target_point - caster_location):Normalized()

	--Projectile info. To be used to create the 
	--projectile
	local info = {
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf", --Particle used, might change to ball
		Ability = keys.ability, -- Associated ability
		vSpawnOrigin = keys.caster:GetOrigin(), -- Get casters origin when casted
		fStartRadius = keys.ability.ball_width, --How wide the ball is
		fEndRadius = keys.ability.ball_width, -- Same value, width doesnt change
		vVelocity = keys.ability.ball_direction * keys.ability.ball_speed, -- Its velocity yo, no much to be said (direction * speed)
		fDistance = keys.ability:GetCastRange( keys.caster:GetOrigin(), keys.caster ), -- How far does it go
		Source = keys.caster, -- Who does it come from
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY, --Potential targets of projectile (enemies), not ability
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- Heros and creeps
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- Taret flag associated to magic immune enemies, look up on api
		bProvidesVision = true, --Does it get rid of fog of war?
		iVisionTeamNumber = keys.caster:GetTeamNumber(), -- Whos vision should it be for
	}

	--Start time and location at start
	--We need to know where it goes and cause uh, physics
	keys.ability.ball_start = caster_location
	keys.ability.ball_start_time = GameRules:GetGameTime()

	--Create the vision timer, think timer and the actual projectile
	keys.flVisionTimer = keys.ability.ball_width / keys.ability.ball_speed
	keys.flLastThinkTime = GameRules:GetGameTime()
	keys.nProjID = ProjectileManager:CreateLinearProjectile( info )
end

--[[This projectile hit something congrats! Associated with KV
"OnProjectileHitUnit" and "Run script"]]
function OnProjectileHit( hTarget, vLocation)
	
	--If we have a target that it hit, calculate the damage
	if hTarget ~= nil then
		local damage = {
			victim = hTarget.target, --projectile hit this one
			attacker = hTarget.caster, --Comes from this entity, used for kills, assists 
			damage = hTarget.ability.ball_damage, -- damage associated with the ability
			damage_type = DAMAGE_TYPE_PURE, -- Damage type, its pure, no reductions cause math bad
			ability = hTarget.ability, -- The ability associated
		}
		
		ApplyDamage( damage ) -- Apply this table using ApplyDamage global method	
	end
	return false
end

--Does this actually hit? who knows, but I am not risking taking it out
function OnProjectileThink( keys, vLocation )
	print(vLocation) --prints vLocation

	keys.flVisionTimer = keys.flVisionTimer - ( GameRules:GetGameTime() - keys.flLastThinkTime ) -- associated with vision
	if keys.flVisionTimer <= 0.0 then -- if the timer ran out
		local vVelocity = ProjectileManager:GetLinearProjectileVelocity( keys.nProjID )
		keys.flVisionTimer = keys.ability.ball_width / keys.ability.ball_speed
	end
	print(vLocation)
end

--Prints a KV table associated
--Important for when an API is nonexistent
function printKVTable(tempTable)
	for k in pairs(tempTable) do print(k) end
end

--Delete the item associated in the key, also known as
--self for lua_ability
function deleteItem( keys )
	local unit = EntIndexToHScript( keys.caster_entindex ) -- EntIndexToHScript takes the keys.caster_entindex, which is the number assigned to the entity that ran the function from the ability, and finds the actual entity from it.
	local itemName = tostring(keys.ability:GetAbilityName()) -- Get the item name of the ability linked

	for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
		local Item = unit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
		if Item ~= nil and Item:GetName() == itemName then -- makes sure that the item exists and making sure it is the correct item
			unit:RemoveItem(Item) -- finally, the item is removed from the original units inventory.
		end
	end
end


--[[Create an item on this specific point
This is used for when the ball hits an individual, or, runs out of its 
length. Acting as dodgeball, must be associated with a team to determine where a valid random spot is 
for the ball to spawn]]
function createItemOnPoint()

end