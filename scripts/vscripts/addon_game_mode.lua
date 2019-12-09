-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	print("[testertester] Performing pre-load precache")
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode(5)
	ListenToGameEvent("dota_player_pick_hero", OnHeroPicked, nil)
end

function CAddonTemplateGameMode:InitGameMode(killLimit)
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	self.killLimit = killLimit
    ListenToGameEvent("entity_killed", Dynamic_Wrap(CAddonTemplateGameMode, "OnEntityKilled"), self)
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function GiveDodgeball (hero)
    if hero:HasRoomForItem("item_dodgeball_datadriven", true, true) then
       local dodgeball = CreateItem("item_dodgeball_datadriven", hero, hero)
       dodgeball:SetPurchaseTime(0)
       hero:AddItem(dodgeball)
    end
 end

function OnHeroPicked (event)
    local hero = EntIndexToHScript(event.heroindex)
    GiveDodgeball(hero)
 end

 function CAddonTemplateGameMode:OnEntityKilled ()
   if PlayerResource:GetTeamKills(DOTA_TEAM_GOODGUYS) == self.killLimit then
     GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
   elseif PlayerResource:GetTeamKills(DOTA_TEAM_BADGUYS) == self.killLimit then
     GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
   end
 end