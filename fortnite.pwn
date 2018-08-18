/********************************************************
*														*
*			  Fortnite: Battle Royal Mode			    *
*		Build: 1	Version 1.0		SVersion: 0.3.7		*
*												   		*
*	- Developer: XeonTM									*
* 	- File: Main file of FBR Filterscript.				*
*														*
*********************************************************/

#define FILTERSCRIPT

// Includes
#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <zcmd>
#include <foreach>

// PriateShip Settings (@pirateship.pwn)
#define NUM_SHIP_ROUTE_POINTS   25
#define SHIP_OBJECT_ID          8493
#define SHIP_SKULL_ATTACH       3524
#define SHIP_RAILS_ATTACH       9159
#define SHIP_LINES_ATTACH       8981
#define SHIP_MOVE_SPEED         10.0
#define SHIP_DRAW_DISTANCE      800.0

#define SHIP_POS_START_X        0.0
#define SHIP_POS_START_Y        0.0
#define SHIP_POS_START_Z        0.0

#define SHIP_POS_FINISH_X       0.0
#define SHIP_POS_FINISH_Y       0.0
#define SHIP_POS_FINISH_Z       0.0

// Main Const.
#define FORTNITE_VIRTUAL_WORLDS 100
#define MAX_BATTLES 100

#undef MAX_PLAYERS
	#define MAX_PLAYERS 100

// Variables
new 
	ShipObject[MAX_BATTLES],
	ShipAttachements[MAX_BATTLES][6],

	FortnitePlayers[MAX_PLAYERS],

	DoorsOpenTime[MAX_BATTLES],
	DoorsOpened[MAX_BATTLES],

	LastStopCount[MAX_BATTLES],
	bool:IsInShip[MAX_PLAYERS][MAX_BATTLES]
;

// Main Game Settings.
StartFortnite(gameid)
{
	ShipObject[gameid] = CreateDynamicObject(SHIP_OBJECT_ID, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);

	ShipAttachements[gameid][0] = CreateDynamicObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][0], ShipObject[gameid], 4.11, -5.53, -9.78, 0.0, 0.0, 90.0);

	ShipAttachements[gameid][1] = CreateDynamicObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][1], ShipObject[gameid], -4.11, -5.53, -9.78, 0.0, 0.0, -90.0);
	
	ShipAttachements[gameid][2] = CreateDynamicObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][2], ShipObject[gameid], -4.3378, -15.2887, -9.7863, 0.0, 0.0, -90.0);
	
	ShipAttachements[gameid][3] = CreateDynamicObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][3], ShipObject[gameid], 4.3378, -15.2887, -9.7863, 0.0, 0.0, 90.0);
	
	ShipAttachements[gameid][4] = CreateDynamicObject(SHIP_RAILS_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][4], ShipObject[gameid], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	
	ShipAttachements[gameid][5] = CreateDynamicObject(SHIP_LINES_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, FORTNITE_VIRTUAL_WORLDS+gameid, -1, -1, SHIP_DRAW_DISTANCE);
	AttachDynamicObjectToObject(ShipAttachements[gameid][5], ShipObject[gameid], -0.5468, -6.1875, -0.4375, 0.0, 0.0, 0.0);

	MoveDynamicObject(ShipObject[gameid], 0.0, 0.0, 0.0, SHIP_MOVE_SPEED);
	foreach(new i : Player)
	{
		if(FortnitePlayers[i] == gameid)
		{
			SetPlayerVirtualWorld(i, FORTNITE_VIRTUAL_WORLDS+gameid);
			AttachCameraToDynamicObject(i, ShipObject[gameid]);

			SetPlayerWorldBounds(playerid, -2758.5, 277.28564453125, -2658.5, 377.28564453125);
			ResetPlayerWeapons(playerid);

			IsInShip[i][gameid] = true;
			GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 99);
			GivePlayerWeapon(playerid, WEAPON_SHOVEL, 99);
		}
	}	
	DoorsOpenTime[gameid] = -1;
	DoorsOpened[gameid] = false;
	OpenDoors(gameid, 10);
	return 1;
}

AnnounceBattleRoyalText(gameid, string[])
{

}

OpenDoors(gameid, seconds)
{
	if(DoorsOpenTime[gameid] == 0)
	{
		DoorsOpenTime[gameid] = -1;
		DoorsOpened[gameid] = true;
		LastStopCount[gameid] = -1;
		LastStopCountStart(gameid, 20);
		return 1;
	}
	if(DoorsOpenTime[gameid] == -1)
	{
		DoorsOpenTime[gameid] = seconds;
	}
	if(DoorsOpenTime[gameid] != -1)
	{
		new string[45];
		format(string, sizeof(string), "{FFFFFF}Doors will open in {FF00EA}%d Seconds", DoorsOpenTime[gameid]);
		AnnounceBattleRoyalText(gameid, string);
		DoorsOpenTime[gameid]--;
		OpenDoors(gameid, DoorsOpenTime[gameid]);
	}
	return 1;
}

LastStopCountStart(gameid, seconds)
{
	if(LastStopCount[gameid] == 0)
	{
		LastStopCount[gameid] = -1;
		foreach(new i : Player)
		{
			if(FortnitePlayers[i] == gameid)
			{
				if(IsInShip[i][gameid])
				{
					SetPlayerPos(i, SHIP_POS_FINISH_X, SHIP_POS_FINISH_Y, SHIP_POS_FINISH_Z);
					SetCameraBehindPlayer(i);
				}
			}
		}

		StormEyeMaking(gameid, 60);
		return 1;
	}
	if(LastStopCount[gameid] == -1)
	{
		LastStopCount[gameid] = seconds;
	}
	if(LastStopCount[gameid] != -1)
	{
		new string[54];
		format(string, sizeof(string), "{FFFFFF}Everybody off, Last stop in {FF00EA}%d Seconds", LastStopCount[gameid]);
		AnnounceBattleRoyalText(gameid, string);
		LastStopCount[gameid]--;
		LastStopCountStart(gameid, LastStopCount[gameid]);
	}
	return 1;
}

StormEyeMaking(gameid, seconds)
{

}
