// ZHAO-II-interface - Ziggy Puff, 06/07

////////////////////////////////////////////////////////////////////////
// Interface script - handles all the UI work, sends link 
// messages to the ZHAO-II 'engine' script
//
// Interface definition: The following link_message commands are 
// handled by the core script. All of these are sent in the string 
// field. All other fields are ignored
//
// ZHAO_RESET                          Reset script
// ZHAO_LOAD|<notecardName>            Load specified notecard
// ZHAO_NEXTSTAND                      Switch to next stand
// ZHAO_STANDTIME|<time>               Time between stands. Specified 
//                                     in seconds, expects an integer.
//                                     0 turns it off
// ZHAO_AOON                           AO On
// ZHAO_AOOFF                          AO Off
// ZHAO_SITON                          Sit On
// ZHAO_SITOFF                         Sit Off
// ZHAO_RANDOMSTANDS                   Stands cycle randomly
// ZHAO_SEQUENTIALSTANDS               Stands cycle sequentially
// ZHAO_SETTINGS                       Prints status
// ZHAO_SITS                           Select a sit
// ZHAO_GROUNDSITS                     Select a ground sit
// ZHAO_WALKS                          Select a walk
//
// ZHAO_SITANYWHERE_ON                 Sit Anywhere mod On 
// ZHAO_SITANYWHERE_OFF                Sit Anywhere mod Off 
//
// ZHAO_TYPE_ON                        Typing AO On 
// ZHAO_TYPE_OFF                       Typing AO Off 
//
// ZHAO_TYPEKILL_ON                    Typing Killer On 
// ZHAO_TYPEKILL_OFF                   Typing Killer Off 
//
// So, to send a command to the ZHAO-II engine, send a linked message:
//
//   llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
//
////////////////////////////////////////////////////////////////////////


// SINdecade PLAY! AO - almost based on the 1.0.14 release from Marcus Gray / Johann Ehrler.
//          Slightly different. Stand-ON/OFF-toggle function as well as help button have not been integrated.
//          So look for the original ZHAO-II MB2 2.0.16 release.

// Johann Ehrler, 12/13/2008:
//          ZHAO failed to recognize owner change...FIXED!
//          This interface send a reset request to all other scripts if owner changed.

// Johann Ehrler, 09/16/2008:
//          Provisory added ability to control the ZHAO's power switch via chat line or a gesture.
//          TODO: Rethink about the currently implementation. xD
//
//          WARNING: This script was MONO-recompiled!

// Marcus Gray, 04/06/2008:
//          Added TypingAO support with new NC-token [ Typing ] & Typing-kill-functionality (core)
//          Dialog-Menu entries for TypingAO & TypingKill ...made 14 buttons which forces me to do multipage dialog... f**k!!! (interface)
//          Freed huge amount of mem by moving NC-loading to an extra script (core --> zhao-II-loadcards)

// Marcus Gray, 03/26/2008:
//          Included Seamless Sit mod by Moeka Kohime (core script).
//          Freed some memory DELETING THE DEFAULT UNOVERRIDABLE ANIMS!!!!!!!! (core script)
//          Added sit anywhere functionality to replace stands by groundsits (core script).
//          Therefore changed functionality of Sit-ON/OFF button to work as Sit Anywhere button (interface).

// Johann Ehrler, 08/01/2007:
//          Color-mod - Now you can use standard RGB-notation for the ON-OFF-states.
//          Link names - You can use the link names instead the link numbers

// Marcus Gray, 08/01/2007:
//          Added some extra buttons for easier access of the main functions.
//          Created new funtions loadNotecard() and toggleSit() containing the code now used by Dialog/Listen AND Button handling.
//          In addition, swapped Menu and Sit-ON/OFF buttons

// Ziggy, 07/16/07 - Single script to handle touches, position changes, etc., since idle scripts take up
// 
// Ziggy, 06/07:
//          Single script to handle touches, position changes, etc., since idle scripts take up
//          scheduler time
//          Tokenize notecard reader, to simplify notecard setup
//          Remove scripted texture changes, to simplify customization by animation sellers

// Fennec Wind, January 18th, 2007:
//          Changed Walk/Sit/Ground Sit dialogs to show animation name (or partial name if too long) 
//          and only show buttons for non-blank entries.
//          Fixed minor bug in the state_entry, ground sits were not being initialized.
//

// Dzonatas Sol, 09/06: Fixed forward walk override (same as previous backward walk fix). 


// Based on Francis Chung's Franimation Overrider v1.8

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.

// CONSTANTS
//////////////////////////////////////////////////////////////////////////////////////////////////////////

integer handle;
integer mychannel;

integer Key2Number(key objKey) 
{
    return ((integer)("0x"+llGetSubString((string)objKey,-8,-1)) & 0x3FFFFFFF) ^ 0x3FFFFFFF;
}


// ON/OFF Textures
key t_zhaoOn = "10708838-d262-5610-8734-5546c2d876fa";
key t_zhaoOff = "dfb1121e-1d4d-8915-21dc-a2a3a6476fbc";

// Help notecard
string helpNotecard = "READ ME - ZHAO-II";

// How long before flipping stand animations
integer standTimeDefault = 30;

// Listen channel for pop-up menu... 
// should be different from channel used by ZHAO engine (-91234)
//
// Mod: Channel will now be generated from owner UUID.
integer listenChannel = -2; //-91235;

integer listenHandle;                          // Listen handlers - only used for pop-up menu, then turned off
integer listenState = 0;                       // What pop-up menu we're handling now

// Mod: Channel for chat control.
integer chatControlChannel = 2330;

// Overall AO state
integer zhaoOn = TRUE;

////////////////////////////////////////////////////////////
// BEGIN mod by Johann Ehrler - 08/01/2007
//
// Link names/numbers for the extra buttons:
string btnMenu = "menu";                //Menu button
string btnLNC = "load";                 //Load notecard button
string btnTSitOnOff = "sit_toggle";     //Sit-ON/OFF button
string btnTSitAW = "sit_aw_toggle";     //Sit ANYWHERE-ON/OFF button
string btnWalk = "walks";               //Choose walk button
string btnGSits = "groundsits";         //Choose groundsit button
string btnSits = "sits";                //Choose sit button
string btnNStand = "nextstand";         //Play next stand button
string btnMinMax = "minmax";            //Minimize/Maximize button
//
// END Mod by Johann Ehrler
////////////////////////////////////////////////////////////


// Interface script now keeps track of these states. The defaults
// match what the core script starts out with
integer sitOverride = TRUE;
integer sitAnywhere = FALSE;
integer randomStands = FALSE;
integer typingOverrideOn = TRUE;            // Whether we're overriding typing or not
integer typingKill = FALSE;                 // Whether we're killing the typing completely

key Owner = NULL_KEY;

// MENU VARS
integer MMAIN       = 0;
integer MSIT        = 1;
integer MSTAND      = 2;
integer MOPTIONS    = 3;    //new sub-menu by Trin Trevellion for PLAY!AO

integer menuState = MMAIN;

// CODE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Initialize listeners, and reset some status variables

DoMenu() 
{
    // The rows are inverted in the actual dialog box. This must match
    // the checks in the listen() handler
    string menutxt = "\n\tSelect your Choice!";
    list buttons = [];
    
    if(menuState == MMAIN)
    {
        //menutxt += "Submenus:";
        //menutxt += "\n \tSIT: Sit-submenu";
        //menutxt += "\n \tSTAND: Stand-submenu";
        
        buttons = [
            "Walks", "SIT", "STAND", 
            "TypingAO", "TypingKill",
            "Presets", "Settings", "Next Stand",
            "Options"
        ];

        listenState = 0;
    }
    else if(menuState == MSIT)
    {
        buttons = [
            "Sits", "Ground Sits",
            "Sit On/Off", "Sit Anywhere",
            "Return"
        ];
    }
    else if(menuState == MSTAND)
    {
        buttons = [
            "Rand/Seq", "Stand Time", "Next Stand",
            "Return"
        ];
    }
    else if(menuState == MOPTIONS)
    {
        buttons = [
            "Basic Style", "Noire Style", "Reset", "Face Light", "Keyboard", "Gravity",
            "Return"
        ];
    }
    llListenControl(listenHandle, TRUE);
    llDialog( Owner, menutxt, buttons, listenChannel );
}

////////////////////////////////////////////////////////////
// BEGIN mod by Marcus Gray - 08/01/2007
// new functions for now multi-used code for loading notecards and toggling sit
//

toggleAO()
{
    if (zhaoOn) {
        llMessageLinked(LINK_SET, 0, "ZHAO_AOOFF", NULL_KEY);
        llSetTexture(t_zhaoOff, ALL_SIDES);
    } else {
        llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
        llSetTexture(t_zhaoOn, ALL_SIDES);
    }
    zhaoOn = !zhaoOn;
}

toggleSit()
{
    if (sitOverride == TRUE) 
    {
        SetLinkPrimParams("ZHAO_SITOFF");
    } else 
    {
        SetLinkPrimParams("ZHAO_SITON");
    }
    sitOverride = !sitOverride;
}

toggleSitAnywhere()
{
    if (sitAnywhere == TRUE) {
        SetLinkPrimParams("ZHAO_SITANYWHERE_OFF");
    } else {
        SetLinkPrimParams("ZHAO_SITANYWHERE_ON");
    } 
    sitAnywhere = !sitAnywhere;
}

toggleTyping()
{
    // BUTTON COLOR IS HANDLED BY A SCRIPT INSIDE THE BUTTON ITSELF!!!
    if (typingOverrideOn == TRUE) {
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEAO_OFF", NULL_KEY);
    } else {
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEAO_ON", NULL_KEY);
    }
    typingOverrideOn = !typingOverrideOn;
}

toggleTypingKill()
{
    //SIT ANYWHERE BUTTON COLOR IS HANDLED BY A SCRIPT INSIDE THE BUTTON ITSELF!!!
    if (typingKill == TRUE) {
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEKILL_OFF", NULL_KEY);
    } else {
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEKILL_ON", NULL_KEY);
    }
    typingKill = !typingKill;
}

// END mod by Marcus Gray

styleBasic() //switchable interface theme by Trin Trevellion for PLAY!AO
{
        t_zhaoOn = "10708838-d262-5610-8734-5546c2d876fa";
        t_zhaoOff = "dfb1121e-1d4d-8915-21dc-a2a3a6476fbc";
        llSetTexture( t_zhaoOn, ALL_SIDES); //onoff

        list things1 = [5,4,7,4,6,4,9,4,8,4,11,4,10,4,4,4,2,4,4,0];
        string texture1 = "ec820e90-a430-f272-4cde-54476050e370";
        changestyle(things1, texture1, "STYLE_BASIC");

        SetLinkTextureFast(  2,"96df75ac-200e-f2c2-1eb1-42d8c1aa4bc4", 0); //sitanyONpreload
        SetLinkTextureFast( 12,"3d7501b6-5f4e-edf7-c651-4e7a8f634c32", 4); //sit_aw_toggle
        SetLinkTextureFast(  3,"3d7501b6-5f4e-edf7-c651-4e7a8f634c32", 4); //sit_aw_toggle2
        SetLinkTextureFast(  3,"dfb1121e-1d4d-8915-21dc-a2a3a6476fbc", 0); //powerOFFpreload
}

styleNoire()  //switchable interface theme by Trin Trevellion for PLAY!AO
{
        t_zhaoOn = "8c9b72a3-efc0-4a06-05cf-fdd5b729b659";
        t_zhaoOff = "ff29dd27-a7b1-3f0d-df31-6e07a391909a";
        llSetTexture( t_zhaoOn, ALL_SIDES); //onoff

        list things1 = [5,4,7,4,6,4,9,4,8,4,11,4,10,4,4,4,2,4,4,0];
        string texture1 = "0f5b2f0c-15c9-8a7f-3cc0-3843510efa78";
        changestyle(things1, texture1, "STYLE_NOIRE");

        SetLinkTextureFast(  2,"39f9e8e5-41a7-09ec-c340-ebf44737ec58", 0); //sitanyONpreload
        SetLinkTextureFast( 12,"398cb919-ba0f-15ce-0927-ac7f876612af", 4); //sit_aw_toggle
        SetLinkTextureFast(  3,"398cb919-ba0f-15ce-0927-ac7f876612af", 4); //sit_aw_toggle2
        SetLinkTextureFast(  3,"ff29dd27-a7b1-3f0d-df31-6e07a391909a", 0); //powerOFFpreload
}

// change the prim texture style
changestyle(list _sides, string _texture, string _style)
{
        integer x;
        integer length = llGetListLength(_sides);
        
        llMessageLinked(LINK_SET, 0, _style, NULL_KEY);
        for (x = 0; x < length; x=x+2)
        {
            SetLinkTextureFast(  llList2Integer(_sides,x), _texture, llList2Integer(_sides,x+1));
        }                    
}

// CHANGE PRIM PARAMETERS
SetLinkPrimParams(string _message)
{
    integer i;
    string primname;
    list params;
    vector repeats;
    vector offsets;
    float rotation_in_radians;

// ON/OFF Textures
     
    
    key t_sawOn = "96df75ac-200e-f2c2-1eb1-42d8c1aa4bc4";
    key t_sawOff = "3d7501b6-5f4e-edf7-c651-4e7a8f634c32";

    llMessageLinked(LINK_SET, 0, _message, NULL_KEY);

    for(i = 1; i <= llGetNumberOfPrims(); i++)
    {
        primname = (string)llGetLinkPrimitiveParams(i, [PRIM_NAME]);
        params = llGetLinkPrimitiveParams(i, [PRIM_TEXTURE, 4]);
        repeats = llList2Vector(params,1);
        offsets = llList2Vector(params,2);
        rotation_in_radians = llList2Float(params,3);

        if (( _message == "ZHAO_SITON" ) & ( primname == "sit_toggle"))
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, /* green */ <0.4,0.7,0.1>, (float)TRUE]);
        } 
        else if (( _message == "ZHAO_SITOFF" )  & ( primname == "sit_toggle"))
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_COLOR, ALL_SIDES, /* red */ <1.0,0.1,0.3>, (float)TRUE]);
        }

        // Coming from an interface script
        if (( _message == "ZHAO_SITANYWHERE_ON" )  & ( primname == "sit_aw_toggle"))
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_TEXTURE, 4, t_sawOn, repeats, offsets, rotation_in_radians]);
        } 
        else if (( _message == "ZHAO_SITANYWHERE_OFF" )  & ( primname == "sit_aw_toggle"))
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_TEXTURE, 4, t_sawOff, repeats, offsets, rotation_in_radians]);
        } 
        else if ( _message == "STYLE_BASIC" ) 
        { // Switchable interface theme by Trin Trevellion for PLAY!AO
          t_sawOn = "96df75ac-200e-f2c2-1eb1-42d8c1aa4bc4";
          t_sawOff = "3d7501b6-5f4e-edf7-c651-4e7a8f634c32";
        } else if ( _message == "STYLE_NOIRE" ) 
        { // Switchable interface theme by Trin Trevellion for PLAY!AO
          t_sawOn = "39f9e8e5-41a7-09ec-c340-ebf44737ec58";
          t_sawOff = "398cb919-ba0f-15ce-0927-ac7f876612af";
        }
                
    }
}


SetLinkTextureFast(integer link, string texture, integer face)
{
    // Obtain the current texture parameters and replace the texture only.
    // If we are going to apply the texture to ALL_SIDES, we need
    // to adjust the returned parameters in a loop, so that each face
    // keeps its current repeats, offsets and rotation.
    list Params = llGetLinkPrimitiveParams(link, [PRIM_TEXTURE, face]);
    integer idx;
    face *= face > 0; // Make it zero if it was ALL_SIDES
    // This part is tricky. The list returned by llGLPP has a 4 element stride
    // (texture, repeats, offsets, angle). But as we modify it, we add two
    // elements to each, so the completed part of the list has 6 elements per
    // stride.
    integer NumSides = llGetListLength(Params) / 4; // At this point, 4 elements per stride
    for (idx = 0; idx < NumSides; ++idx)
    {
        // The part we've completed has 6 elements per stride, thus the *6.
        Params = llListReplaceList(Params, [PRIM_TEXTURE, face++, texture], idx*6, idx*6);
    }
    llSetLinkPrimitiveParamsFast(link, Params);
}

OwnerSay(string Procedure, string Message)
{   llOwnerSay(llGetScriptName()+": "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+Procedure+" - "+Message);}

printFreeMemory()
{   OwnerSay("printFreeMemory", (string) (llGetFreeMemory()/1024) + "Kb memory free." );
    OwnerSay("printFreeMemory",  (string) (llGetUsedMemory()/1024) + "Kb memory used." );
    OwnerSay("printFreeMemory",  (string) ((llGetUsedMemory() + llGetFreeMemory())/1024) + "Kb memory total." );}

Initialize() {
    Owner = llGetOwner();
    mychannel = Key2Number(Owner);
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    integer memoryLimit = 40*1024;
    llSetMemoryLimit(memoryLimit);
    printFreeMemory();
    // On init, open a new listener...
    if ( listenHandle )
        llListenRemove( listenHandle );

    // Generate the channel from the owner UUID and adds 1 cuz we need a different channel as the core script.
    listenChannel = ( 1 + (integer)( "0xF" + llGetSubString( llGetOwner(), 0, 6) ) ) + 1;
    
    listenHandle = llListen( listenChannel, "", Owner, "" );

    // ... And turn it off
    llListenControl(listenHandle, FALSE);
}

// STATE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

default {
    state_entry() {

        Initialize();

        // Sleep a little to let other script reset (in case this is a reset)
        llSleep(2.0);

        // We start out as AO ON
        zhaoOn = TRUE;
        llSetTexture(t_zhaoOn, ALL_SIDES);
        llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
        
        //sit override ON by default
        SetLinkPrimParams("ZHAO_SITON");
        sitOverride = TRUE;
        
        //sit anywhere OFF by default
//        llMessageLinked(LINK_SET, 0, "ZHAO_SITANYWHERE_OFF", NULL_KEY);
        SetLinkPrimParams("ZHAO_SITANYWHERE_OFF");
        sitAnywhere = FALSE;
        
        //show ZHAO
        llMessageLinked(LINK_SET, 0, "ZHAO_SHOW", NULL_KEY);
        
        //typing AO & typing Killer
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEAO_ON", NULL_KEY);
        llMessageLinked(LINK_SET, 0, "ZHAO_TYPEKILL_OFF", NULL_KEY);
        
        //ability to toggle the power state via chat line or a gesture
        //llListen( chatControlChannel, "", Owner, chatControlString );
        llListen( chatControlChannel, "", Owner, "" );
    }

    on_rez( integer _code ) {
        Initialize();
    }

    touch_start( integer _num ) {
        
        ////////////////////////////////////////////////////////////
        // BEGIN mod by Marcus Gray - 08/01/2007
        //
        integer lntmp = llDetectedLinkNumber(0);
        string btmp = llGetLinkName(lntmp);
        
        if (btmp == btnMenu) {
            // Menu prim... use number instead of name
            DoMenu();
        }
        //
        // Added button handlers
        //
        else if (btmp == btnLNC) {
            llMessageLinked(LINK_SET, 0, "ZHAO_LOAD" , NULL_KEY);
        }
        else if (btmp == btnTSitAW) {
            toggleSitAnywhere();
        }
        else if (btmp == btnTSitOnOff) { //while btnTSit == btnTSitAW this won't be reached!
            toggleSit();
        }
        else if (btmp == btnWalk) {
            llMessageLinked(LINK_SET, 0, "ZHAO_WALKS", NULL_KEY);
        }
        else if (btmp == btnGSits) {
            llMessageLinked(LINK_SET, 0, "ZHAO_GROUNDSITS", NULL_KEY);
        }
        else if (btmp == btnSits) {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITS", NULL_KEY);
        }
        else if (btmp == btnNStand) {
            llMessageLinked(LINK_SET, 0, "ZHAO_NEXTSTAND", NULL_KEY);
        }
        else if (btmp == btnMinMax) {
            llMessageLinked(LINK_SET, 0, "ZHAO_TOGGLE_SHOW", NULL_KEY);
        }

                // END mod by Marcus Gray
        ////////////////////////////////////////////////////////////
        

        else if (lntmp == 1) {
            // On/Off prim ==> MYSELF ^^
            toggleAO();
        }
    }
    
    listen( integer _channel, string _name, key _id, string _message) {

        // Turn listen off. We turn it on again if we need to present 
        // another menu
        llListenControl(listenHandle, FALSE);

        if ( _channel == chatControlChannel && _id == Owner && _message == "playao" ) {
            toggleAO();
            //code changed by Trin Trevellion for PLAY!AO
        }

        else if ( _channel == chatControlChannel && _id == Owner && _message == "sitanywhere" ) {
            toggleSitAnywhere();
            //code changed by Trin Trevellion for PLAY!AO
        }

        else if ( _channel == chatControlChannel && _id == Owner && _message == "sit" ) {
            toggleSit();
            //code changed by Trin Trevellion for PLAY!AO
        }

        else if ( _message == "Reset" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_RESET", NULL_KEY);
            styleBasic();
            llSleep(2.0);
            llResetScript();
        }
        else if ( _message == "Settings" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_SETTINGS", NULL_KEY);
        }
        else if ( _message == "Return" ) {
            menuState = MMAIN;
            DoMenu();
        }
        else if ( _message == "SIT" ) {
            menuState = MSIT;
            DoMenu();
        }
        else if ( _message == "STAND" ) {
            menuState = MSTAND;
            DoMenu();
        }
        else if ( _message == "Options" ) {
            menuState = MOPTIONS;
            DoMenu();
        }
        else if ( _message == "Sit On/Off" ) {
            //code moved to toggleSit() by Marcus Gray
            toggleSit();
        }
        else if ( _message == "TypingAO" ) {
            //code moved to toggleTyping() by Marcus Gray
            toggleTyping();
        }
        else if ( _message == "TypingKill" ) {
            //code moved to toggleTypingKill() by Marcus Gray
            toggleTypingKill();
        }
        else if ( _message == "Sit Anywhere" ) {
            //toggleSitAnywhere() by Marcus Gray
            toggleSitAnywhere();
        }
        else if ( _message == "Rand/Seq" ) {
            if (randomStands == TRUE) {
                llMessageLinked(LINK_SET, 0, "ZHAO_SEQUENTIALSTANDS", NULL_KEY);
                randomStands = FALSE;
            } else {
                llMessageLinked(LINK_SET, 0, "ZHAO_RANDOMSTANDS", NULL_KEY);
                randomStands = TRUE;
            }
        }
        else if ( _message == "Next Stand" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_NEXTSTAND", NULL_KEY);
        }
        else if ( _message == "Presets" ) {
            //code moved to loadNotecard() by Marcus Gray
            llMessageLinked(LINK_SET, 0, "ZHAO_LOAD", NULL_KEY);
        }
        else if ( _message == "Stand Time" ) {
            // Pick stand times
            list standTimes = ["0", "5", "10", "15", "20", "30", "40", "60", "90", "120", "180", "240"];
            llListenControl(listenHandle, TRUE);
            llDialog( Owner, "Select stand cycle time (in seconds). \n\nSelect '0' to turn off stand auto-cycling.", 
                      standTimes, listenChannel);
            listenState = 2;
        }
        else if ( _message == "Sits" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITS", NULL_KEY);
        }
        else if ( _message == "Walks" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_WALKS", NULL_KEY);
        }
        else if ( _message == "Ground Sits" ) {
            llMessageLinked(LINK_SET, 0, "ZHAO_GROUNDSITS", NULL_KEY);
        }
        else if ( listenState == 2 ) {
            // Stand time change
            llMessageLinked(LINK_SET, 0, "ZHAO_STANDTIME|" + _message, NULL_KEY);
        }
        else if ( _message == "Basic Style" ) { //Interface theme by Trin Trevellion for PLAY!AO
            styleBasic();
        }
        else if ( _message == "Noire Style" ) { //Interface theme by Trin Trevellion for PLAY!AO
            styleNoire();
        } 
        else if ( _message == "Face Light" ) { //Interface theme by Trin Trevellion for PLAY!AO
            llRegionSayTo(Owner,mychannel,"facelighttoggle");
        } 
        else if ( _message == "Keyboard" ) { //Interface theme by Trin Trevellion for PLAY!AO
            llRegionSayTo(Owner,mychannel,"keyboardtoggle");
        } 
        else if ( _message == "Gravity" ) { //Interface theme by Trin Trevellion for PLAY!AO
            llMessageLinked(LINK_THIS, 0, "GRAVITY>>MENU",llGetOwner()); 
        } 
    }

    changed(integer _change) {
        if(_change & CHANGED_OWNER) {
            llMessageLinked(LINK_SET, 0, "ZHAO_RESET", NULL_KEY);
            llSleep(1.0);
            llResetScript();
        }
    }

    attach(key attached)
    {
        if(attached){
            Owner = llGetOwner();
            mychannel = Key2Number(Owner);
        }
    }    

   run_time_permissions( integer _perm ) 
    {
      if (_perm == (PERMISSION_TAKE_CONTROLS)) llTakeControls(CONTROL_BACK, FALSE, TRUE);
    }
 }