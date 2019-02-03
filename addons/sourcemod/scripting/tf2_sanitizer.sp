/************************************************************************ 
*************************************************************************
[TF2] Sanitizer
Description: This plugin is meant to clean up any "unnecessary" entities
    that help to bog down a server, are annoying, or make using holiday
    modes on the server more annoying. Specifically, holidays this plugin
    is aimed at is Halloween and Fullmoon mode (though Halloween mode sees
    the most benefit from the plugin). This can allow server owners to run
    Halloween mode with all the benefits (can see graphics, items, strange
    items specific to the mode) without all the annoying parts of the mode
    all year round. This plugin is also meant to help clean up certain entities
    to help make the server a bit more efficient. 
    
Author of No Thriller Taunt:
    pheadxdll
    
Author:
    Mr. Silence
    
*************************************************************************
*************************************************************************
This plugin is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or
later version. 

This plugin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*************************************************************************/

#pragma semicolon 1

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// Defines
#define HALLOWEEN_MODE 2
#define FULLMOON_MODE 9
#define FILE_GAMEDATA "thriller.plugin"
#define PLUGIN_VERSION "1.2"

// Handles
new Handle:cvar_TFSHolidayMode = INVALID_HANDLE;
new Handle:cvar_TFSSanitizerEnabled = INVALID_HANDLE;
new Handle:cvar_TFSRemoveBread = INVALID_HANDLE;
new Handle:cvar_TFSReplaceHKits = INVALID_HANDLE;
new Handle:cvar_TFSRemoveSouls = INVALID_HANDLE;
new Handle:cvar_TFSRemovePumpkinLoot = INVALID_HANDLE;
new Handle:cvar_TFSRemoveThrillerTaunt = INVALID_HANDLE;

// Holiday-related
new g_vHolidayMode;

// Thriller taunt
new Address:g_addrPatch = Address_Null;
new g_iMemoryPatched = 0;
new bool:g_bThrillerSet = true;

///////////////////////////////////
//===============================//
//=====[ PLUGIN INFO ]===========//
//===============================//
///////////////////////////////////
public Plugin:myinfo =
{
    name = "[TF2] Sanitizer",
    author = "Mr. Silence",
    description = "Removes/replaces various holiday items, taunts, etc.",
    version = PLUGIN_VERSION,
    url = "www.removetftrash.org"
}

public OnPluginStart()
{
    // Grab holiday convar for later
    cvar_TFSHolidayMode = FindConVar("tf_forced_holiday");
    
    // Plugin convars
    cvar_TFSSanitizerEnabled    = CreateConVar("sm_tf2s_sanitizer_enabled", "1", "Enable/Disable TF2 Sanitization plugin. \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    cvar_TFSRemoveBread         = CreateConVar("sm_tf2s_remove_bread", "1", "Enable/Disable removal of bread from teleporters. \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    cvar_TFSReplaceHKits        = CreateConVar("sm_tf2s_replace_hkits", "1", "Enable/Disable replacement of holiday healthkits with normal healthkits. \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    cvar_TFSRemoveSouls         = CreateConVar("sm_tf2s_remove_souls", "1", "Enable/Disable removal of halloween souls (removes sound as well). \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    cvar_TFSRemovePumpkinLoot   = CreateConVar("sm_tf2s_remove_pumpkin_loot", "1", "Enable/Disable removal of pumpkin loot/candy dropped from players in halloween mode. \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    cvar_TFSRemoveThrillerTaunt = CreateConVar("sm_tf2s_remove_thriller_taunt", "1", "Enable/Disable the thriller taunt from being activated. \nEnable = 1  \nDisable = 0", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);

    // Plugin version
    CreateConVar("sm_tf2s_sanitizer_version", PLUGIN_VERSION, "[TF2] TF2 Sanitizer Version.", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

    // Create a config file for the plugin
    AutoExecConfig(true, "plugin.tf2sanitizer");
}

public OnConfigsExecuted()
{
    // Enable the thriller taunt after configs have loaded, then set it 
    // so that we never run this every time OnConfigsExecuted is run.
    if(GetConVarBool(cvar_TFSRemoveThrillerTaunt) && g_bThrillerSet)
    {
        Patch_Enable();
        g_bThrillerSet = false;
    }
    // If its been enabled and we change the cvar + reload the plugin, this will disable/remove the patch
    if(!GetConVarBool(cvar_TFSRemoveThrillerTaunt) && !g_bThrillerSet)
    {
        Patch_Disable();
        g_bThrillerSet = true;
    }
}

public OnEntityCreated(entity, const String:classname[])
{
    if (GetConVarBool(cvar_TFSSanitizerEnabled))
    {   
        if (IsValidEntity(entity))
        {
            // Remove bread
            if (GetConVarBool(cvar_TFSRemoveBread) && StrContains(classname, "bread") && StrEqual(classname, "prop_physics_override"))
            {
                LogMessage("DEBUG: sees bread");
                SDKHook(entity, SDKHook_SpawnPost, KillEntityOnSpawn);
            }
        
            // If its not bread, its probably a holiday item. 
            // Find out which mode we have so we can kill the thing!
            g_vHolidayMode = GetConVarInt(cvar_TFSHolidayMode);
            if (g_vHolidayMode == HALLOWEEN_MODE || g_vHolidayMode == FULLMOON_MODE)
            {
                // Replace healthkit
                if (GetConVarBool(cvar_TFSReplaceHKits) && strncmp(classname, "item_healthkit_", 15) == 0)
                {      
                    SDKHook(entity, SDKHook_SpawnPost, OnHealthKitSpawned);
                }
                
                // Remove halloween soul packs. This one isn't a model, so it must be killed by other means
                if (GetConVarBool(cvar_TFSRemoveSouls) && StrEqual(classname,"halloween_souls_pack"))
                {   
                    SDKHook(entity, SDKHook_SpawnPost, KillSoulsOnSpawn);
                }
                
                // Remove pumpkin loot
                if (GetConVarBool(cvar_TFSRemovePumpkinLoot) && StrContains(classname, "pumpkin_") && StrEqual(classname, "prop_physics_override"))
                {   
                    SDKHook(entity, SDKHook_SpawnPost, KillEntityOnSpawn);
                }
            }
        }
    }
}

/////////////////////////////////////////////
//=========================================//
//=====[ REMOVAL/REPLACEMENT RELATED ]=====//
//=========================================//
/////////////////////////////////////////////
// Specific to health kits. Replaces them with the normal version of healthkits
public OnHealthKitSpawned(entity)
{
	SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", 0, _, 2);
}

// Specifically for any entities that have model data.
// In this case, we are suing it for both bread and pumpkin loot entities since both 
// are physics override entities that randomly spawn when triggered.
public KillEntityOnSpawn(entity)
{
    // Get the model name, we'll need it later
    decl String:m_ModelName[PLATFORM_MAX_PATH];
    GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

    // Always remove bread. ALWAYS
    if (StrContains(m_ModelName, "c_bread_") != -1 || StrContains(m_ModelName, "pumpkin_loot") != -1)
    {
        LogMessage("DEBUG: Kills entity");
        AcceptEntityInput(entity, "Kill");
    }
}

// This will remove entities when they spawn. This will be more generic so we can kill tons of trash
public KillSoulsOnSpawn(entity)
{
    AcceptEntityInput(entity, "Kill");
}

//////////////////////////////////
//==============================//
//=====[ THRILLER RELATED ]=====//
//==============================//
//////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NOTE: All code here came from the thriller.sp file from https://forums.alliedmods.net/showthread.php?t=171343        //
// This requires gamedata and should be checked regularly to ensure optimial performance                                //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public OnPluginEnd()
{
	// Assuming the thriller taunt was enabled already, once the plugin ends (ie: when we kill/reset the server)
    // We will disable the thriller taunt in order to release the address.
    if(GetConVarBool(cvar_TFSRemoveThrillerTaunt) && !g_bThrillerSet)
    {
        Patch_Disable();
        g_bThrillerSet = true;
    }
}

// Enable the patch to remove the thriller taunt, this will check several pieces of info prior to patching
Patch_Enable()
{
    g_addrPatch = Address_Null;
    g_iMemoryPatched = 0;
	
    // The "tf" in the gamedata probably makes game check redundant
    decl String:strGame[10];
    GetGameFolderName(strGame, sizeof(strGame));
    if(strcmp(strGame, "tf") != 0)
    {
        LogMessage("Failed to load thriller: Can only be loaded on Team Fortress.");
        return;
    }

    // Find our gamedata file, if it exists
    new Handle:hGamedata = LoadGameConfigFile(FILE_GAMEDATA);
    if(hGamedata == INVALID_HANDLE)
    {
        LogMessage("Failed to load thriller: Missing gamedata/%s.txt.", FILE_GAMEDATA);
        return;
    }

    // Find the offset from  our gamedata file, if it exists
    new iPatchOffset = GameConfGetOffset(hGamedata, "Offset_ThrillerTaunt");
    if(iPatchOffset == -1)
    {
        LogMessage("Failed to load thriller: Failed to lookup patch offset.");
        CloseHandle(hGamedata);
        return;
    }

    // Create the payload for loading to remove the taunt, assuming we can do so
    new iPayload = GameConfGetOffset(hGamedata, "Payload_ThrillerTaunt");
    if(iPayload == -1)
    {
        LogMessage("Failed to load thriller: Failed to lookup patch payload.");
        CloseHandle(hGamedata);
        return;
    }

    // Get the address of the triller taunt to disable it, if we can
    g_addrPatch = GameConfGetAddress(hGamedata, "ThrillerTaunt");
    if(g_addrPatch == Address_Null)
    {
        LogMessage("Failed to load thriller: Failed to locate signature.");
        CloseHandle(hGamedata);
        return;
    }

    CloseHandle(hGamedata);

    // Patch the triller taunt, disabling it from being activated
    g_addrPatch += Address:iPatchOffset;
    LogMessage("Patching ThrillerTaunt at address: 0x%.8X..", g_addrPatch);
    g_iMemoryPatched = LoadFromAddress(g_addrPatch, NumberType_Int8);
    StoreToAddress(g_addrPatch, iPayload, NumberType_Int8);
}

// Disables the the patch used to disable the thriller taunt
Patch_Disable()
{
    if(g_addrPatch == Address_Null) 
    {
        return;
    }
    if(g_iMemoryPatched <= 0) 
    {
        return;
    }
    
    LogMessage("Unpatching ThrillerTaunt at address: 0x%.8X..", g_addrPatch);
    StoreToAddress(g_addrPatch, g_iMemoryPatched, NumberType_Int8);

    g_addrPatch = Address_Null;
    g_iMemoryPatched = 0;
}