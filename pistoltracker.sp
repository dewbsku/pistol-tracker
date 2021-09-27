#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define GLOW_TIME 5.0
Handle unglowTimer[MAXPLAYERS+1];


public Plugin myinfo = {
	name = "Pistol Tracker",
	author = "Dooby Skoo",
	description = "Spy pistol reveals enemy",
	version = "1.0.0",
	url = ""
};

int validWeapons[] =  { 460 };

//-----------------------------------------------------------------------------
public void OnPluginStart() {
	for( int client = 1; client <= MaxClients; client++ ) {
		if (!IsValidClient(client)) { continue; }
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

//-----------------------------------------------------------------------------
public void OnClientPutInServer( int client ) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

//-----------------------------------------------------------------------------
public Action OnTakeDamage( int victim, int &attacker, int &inflictor,
							float &damage, int &damagetype, int &weapon,
							float damageForce[3], float damagePosition[3],
							int damagecustom) {
	
	if( !IsValidClient(attacker) || !IsValidClient(victim) || !IsValidEntity(weapon) ) {return Plugin_Continue;}
	
	char weapon_classname[64];
	GetEntityClassname( weapon, weapon_classname, sizeof weapon_classname );
	if( strncmp( weapon_classname, "tf_weapon", 9 ) != 0 ) {return Plugin_Continue;}
	
	int index = GetEntProp( weapon, Prop_Send, "m_iItemDefinitionIndex" );
	if (!IntArrayContains(index, validWeapons, sizeof(validWeapons))) { //checking against item definition index
		return Plugin_Continue;
	}
	
	SetEntProp(victim, Prop_Send, "m_bGlowEnabled", 1);
    unglowTimer[victim] = CreateTimer(GLOW_TIME, unglowPlayer, victim);
    return Plugin_Continue;
}

public Action unglowPlayer(Handle timer, int client){
    SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
    unglowTimer[client] = null;
}

bool IsValidClient(int client) {
	return ( client > 0 && client <= MaxClients && IsClientInGame(client) );
}

bool IntArrayContains(int val, int[] array, int arraySize){
	for (int i = 0; i < arraySize;i++){
		if(val == array[i]){
			return true;
		}
	}
	return false;
}