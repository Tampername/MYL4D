#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_VERSION "1.0"
#define FCVAR_FLAG FCVAR_SPONLY|FCVAR_NOTIFY

public Plugin:myinfo = {
	name = "easy11mode",
	author = "NiceT",
	description = "easy11mode",
	version = PLUGIN_VERSION,
	url = ""
};

new Handle:h_Revive = INVALID_HANDLE;
new Handle:h_Damage = INVALID_HANDLE;

new bool:takeDamage = false;
new i_count[MAXPLAYERS+1] = 0;

public OnPluginStart()
{
	CreateConVar("l4d_11mod_Version", PLUGIN_VERSION, "The version of 11mod");

	h_Revive = CreateConVar("l4d_revive", 	"30.0", "revive temp health buffer", 		FCVAR_FLAG);
	h_Damage = CreateConVar("l4d_damage", 	"20", "a success attack damage to survivor", 	FCVAR_FLAG);

	HookEvent("player_incapacitated", Event_Incapacitated);
	HookEvent("player_death", Event_Playerdeath);
	HookEvent("player_team", Event_Playerteam);
	HookEvent("versus_round_start", Event_Roundstart);
}

public OnMapStart(){
	SetConVarInt(FindConVar("director_no_bosses"), 1);
	SetConVarInt(FindConVar("director_no_death_check"), 1);
	SetConVarInt(FindConVar("director_no_mobs"), 1);
	SetConVarInt(FindConVar("director_no_survivor_bots"), 1);
	SetConVarInt(FindConVar("versus_special_respawn_interval"), 10);
	SetConVarInt(FindConVar("z_versus_boomer_limit"), 0);
	SetConVarInt(FindConVar("z_versus_charger_limit"), 0);
	SetConVarInt(FindConVar("z_versus_hunter_limit"), 1);
	SetConVarInt(FindConVar("z_versus_jockey_limit"), 0);
	SetConVarInt(FindConVar("z_versus_smoker_limit"), 0);
	SetConVarInt(FindConVar("z_versus_spitter_limit"), 0);
	SetConVarFloat(FindConVar("survivor_revive_health"), GetConVarFloat(h_Revive));
	for(int i = 1; i < MaxClients; i++){
		if(IsClientInGame(i)){
			if(!IsValidClient(i)){
				KickClientEx(i);
			}
		}
	}
}


public OnClientPutInServer(client)
{
	if(IsValidClient(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public OnClientDisconnect(client)
{
	if (client > 0 && IsClientInGame(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

stock bool:IsValidClient(client)
{
	if(client>0 && client<=MaxClients)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			return true;
		}
	}
	return false;
}

public Action:Event_Incapacitated(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	i_count[client] += 1;
	CreateTimer(0.5, RevivePlayer, client);
}

public Action:Event_Playerdeath(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetClientTeam(client) == 2){
		SetConVarInt(FindConVar("director_no_death_check"), 0);
	}
}

public Action:Event_Playerteam(Handle:event, const String:name[], bool:dontBroadcast){
	for(int i = 1; i < MaxClients; i++){
		if(IsClientInGame(i)){
			if(!IsValidClient(i)){
				KickClientEx(i);
			}
		}
	}
}

public Action:Event_Roundstart(Handle:event, const String:name[], bool:dontBroadcast){
	for(int i = 1; i < MaxClients; i++){
		i_count[i] = 0;
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(GetClientTeam(attacker) == 3 && !takeDamage){
		damage = GetConVarFloat(h_Damage);
		takeDamage = true;
		CreateTimer(0.1, Suicide, attacker);
		//ForcePlayerSuicide(attacker);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:Suicide(Handle:timer, any:client){
	ForcePlayerSuicide(client);
	takeDamage = false;
}

public Action:RevivePlayer(Handle:timer, any:client){
	if(i_count[client] <= 2){
		//CheatCommand(client, "give", "health");
		//CreateTimer(0.3, RevivePlayer2, client);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 0, 1);
		SetEntProp(client, Prop_Send, "m_iHealth", 1.0);
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", GetConVarFloat(h_Revive));
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
	else{
		//CreateTimer(0.3, RevivePlayer3, client);
		CreateTimer(0.1, Suicide, client);
	}
}
/***********************
stock CheatCommand(client, const String:command[], const String:arguments[]){
	if(!client){
		return;
	}
	new admindata = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, admindata);
}

public Action:RevivePlayer2(Handle:timer, any:client){
	SetEntPropFloat(client, Prop_Send, "m_health", 1.0);
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", GetConVarFloat(h_Revive));
}

public Action:RevivePlayer3(Handle:timer, any:client){
	SetEntPropFloat(client, Prop_Send, "m_health", 0.0);
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 1.0);
}

*************************/
