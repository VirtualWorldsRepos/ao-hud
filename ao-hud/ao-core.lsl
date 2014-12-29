list tokens = [
"Crouching",
"CrouchWalking",
"Falling Down",
"Flying",
"FlyingSlow",
"Hovering",
"Hovering Down",
"Hovering Up",
"Jumping",
"Landing",
"PreJumping",
"Running",
"Sitting",
"Sitting on Ground",
"Soft Landing",
"Standing",
"Standing Up",
"Striding",
"Taking Off",
"Turning Left",
"Turning Right",
"Walking",
"Typing"];

integer nonllAnimationOverrides=1;

float timerEventLength = 0.25;
integer standTimeDefault = 30;
integer memoryLimit;
integer standTime = standTimeDefault;
integer sitOverride = TRUE;
integer sitAnywhereOn = FALSE;
list overrides = [];
integer numStands;
integer curStandIndex;
integer randomStands = FALSE;
integer numWalks;
integer curWalkIndex;
integer randomWalks = FALSE;
integer numOverrides;
integer loadInProgress = FALSE;
integer listenState = 0;
integer listenHandle;
integer listenChannel = -1;
list lineanimations;
integer gotPermission  = FALSE;
integer animOverrideOn = TRUE;
string S_SIT_AW = "Sit anywhere: ";
string S_SIT = "Sit override: ";
string S_TYPE = "Typing override: ";
string SEPARATOR = "|";
key Owner = NULL_KEY;
string EMPTY = "";
// Level
// 0 - Error
// 1 - Warning
// 2 - Info/Debug
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=2;
list Levels=["Error","Warning","Info","Debug"];

integer typingStatus = FALSE;               // status of avatar typing
integer typingOverrideOn = TRUE;

printFreeMemory()
{
    OwnerSay(2, "printFreeMemory", (string) (llGetFreeMemory()/1024) + "Kb memory free." );
    OwnerSay(2, "printFreeMemory",  (string) (llGetUsedMemory()/1024) + "Kb memory used." );
    OwnerSay(2, "printFreeMemory",  (string) ((llGetUsedMemory() + llGetFreeMemory())/1024) + "Kb memory total." );
}

loadAnimations()
{

    overrides = [];
    curStandIndex = 0;
    loadInProgress = TRUE;
    integer i;
    integer j;
    numOverrides = 0;
    OwnerSay(2, "loadAnimations","Loading Animatinons..." );
    llMinEventDelay( 0.0 );
    
    integer numOverrides = llGetInventoryNumber(INVENTORY_ANIMATION);  // Count of all items in prim's contents
    string  ItemName;
    string BrokenItem;
    for (j=0; j<llGetListLength(tokens); j++)
    {
        BrokenItem = "";
        for ( i=0; i<numOverrides; i++)
        {
            ItemName = llGetInventoryName(INVENTORY_ANIMATION, i);
            if (llSubStringIndex(llToLower(ItemName), llToLower(    llList2String(tokens,j)     )+"_" )==0)
            {
                if (BrokenItem=="")
                {
                    BrokenItem=ItemName;
                    overrides =  (overrides=[]) + overrides + [llList2String(tokens,j)];
                }
                else
                {
                    BrokenItem=BrokenItem+"|"+ItemName;
                }
            }
        }
        if (BrokenItem!="")
        {
            overrides =  (overrides=[]) + overrides + [BrokenItem];
            if (llList2String(tokens,j) == "Standing")
            {
                numStands = llGetListLength(llParseString2List(BrokenItem,[SEPARATOR],[]));
            }
            if (llList2String(tokens,j) == "Walking")
            {
                numWalks = llGetListLength(llParseString2List(BrokenItem,[SEPARATOR],[]));
            }
            OwnerSay(3, "loadAnimations","AnimationType: "+llList2String(tokens,j)+" - "+BrokenItem);
        }
        BrokenItem = "";
    }
    OwnerSay(2, "loadAnimations",(string)numOverrides + " animation entries found.");
    llMessageLinked(LINK_SET, 0, "END_NC_LOAD|0", NULL_KEY);
    printFreeMemory();
    loadInProgress = FALSE;

}

integer CycleAnimation(integer random, integer num, integer max, string anim , integer UI)
{
    integer seq = 0;
    if ( max > 0)
    {
        if ( random )
            seq = llFloor( llFrand(max-1) );
        else  
            if (num == max-1)
                seq = 0;
            else
                seq = num + 1;
        if ( UI == TRUE ) OwnerSay(2, "CycleAnimation","Switching to another "+anim+" index: "+(string)seq+" of "+(string)max );
        SetAnimationOverride(anim, seq);
    }
    else if ( UI == TRUE ) OwnerSay(0, "CycleAnimation","No "+anim+" animations configured." );
    return seq;
}

doNextStand(integer fromUI)
{
    if (sitAnywhereOn == FALSE)
        curStandIndex = CycleAnimation(randomStands, curStandIndex, numStands, "Standing", fromUI);
    curWalkIndex = CycleAnimation(randomWalks, curWalkIndex, numWalks, "Walking", fromUI);    
    llResetTime();
}


doMultiAnimMenu( string _animType )
{
    list anims =  llParseString2List(llList2String(overrides,llListFindList( overrides, [_animType] ) +1),[SEPARATOR],[]) ;
    integer numAnims = llGetListLength( anims );
    if ( numAnims > 12 )
    {
        OwnerSay(0, "doMultiAnimMenu","Too many animations, only the first 12 will be displayed.");
        numAnims = 12;
        return;
    }

    list buttons = [];
    integer i;
    string animNames = EMPTY;
    for ( i=0; i<numAnims; i++ )
    {
        animNames += "\n" + (string)(i+1) + ". " + llList2String( anims, i );
        buttons += [(string)(i+1)];
    }
    
    if ( animNames == EMPTY ) {
        animNames = "\n\nNo overrides have been configured.";
    }
    llListenControl(listenHandle, TRUE);
    llDialog( Owner, "Select the " + _animType + " animation to use:\n\nCurrently: " + llGetAnimationOverride(_animType) + animNames,
              buttons, listenChannel );
}


SetAnimationOverrides()
{
    integer i;
    for (i=0; i<llGetListLength(tokens)-nonllAnimationOverrides; i++ ) SetAnimationOverride(llList2String(tokens,i),0);
}
SetAnimationOverride(string animationoverride, integer animationindex)
{
    integer tokenindex = llListFindList(overrides,[animationoverride]);
    if (tokenindex!=-1)
    {
        string animationType = llList2String(overrides,tokenindex);
        string animationName = llList2String( llParseString2List( llList2String(overrides,tokenindex+1),[SEPARATOR],[] ),animationindex );
        llSetAnimationOverride(animationType, animationName);
        OwnerSay(3, "SetAnimationOverride", animationType+ " : " + animationName);
    }
}
SetStandingAnimationOverride(string animationoverride, integer animationindex)
{
    integer tokenindex = llListFindList(overrides,[animationoverride]);
    if (tokenindex!=-1)
    {
        string animationType = llList2String(overrides,tokenindex);
        string animationName = llList2String( llParseString2List( llList2String(overrides,tokenindex+1),[SEPARATOR],[] ),animationindex );
        llSetAnimationOverride("Standing", animationName);
        OwnerSay(3, "SetStandingAnimationOverride", "Standing : " + animationName);
    }
}

ResetAnimationOverrides()
{
    integer i;
    for (i=0; i<llGetListLength(tokens)-nonllAnimationOverrides; i++ ) ResetAnimationOverride(llList2String(tokens,i));
}
ResetAnimationOverride(string animationoverride)
{
    llResetAnimationOverride(animationoverride);
}

OwnerSay(integer Level, string Procedure, string Message)
{
    if (Level<=defaultLevel)
    llOwnerSay(llGetScriptName()+": "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+llList2String(Levels,Level)+ " - "+Procedure+" - "+Message);
}

 

Initialize() {
    Owner = llGetOwner();
    OwnerSay(2, "Initialize","Initializing AO");

    gotPermission = FALSE;
    randomStands = FALSE;
    
    llSetTimerEvent( 0.0 );
    memoryLimit = 40*1024;
    llSetMemoryLimit(memoryLimit);
    printFreeMemory();
    
    if ( animOverrideOn )
        llSetTimerEvent( timerEventLength );

    gotPermission = FALSE;
    llRequestPermissions( llGetOwner(), PERMISSION_OVERRIDE_ANIMATIONS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_TAKE_CONTROLS );
    OwnerSay(3, "Initialize","Request Permissions");

    listenChannel = ( 1 + (integer)( "0xF" + llGetSubString( llGetOwner(), 0, 6) ) );
    
    if ( listenHandle )
        llListenRemove( listenHandle );
    listenHandle = llListen( listenChannel, EMPTY, Owner, EMPTY );
    llListenControl( listenHandle, FALSE );
    loadInProgress = TRUE;
    loadAnimations();
    llResetTime();
}

string str_replace(string subject, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls(subject, [search], []), replace);
}

default
{
    state_entry()
    {
        OwnerSay(3, "default","state_entry: Initialize");
        Initialize();
    }

    on_rez( integer _code )
    {
        OwnerSay(3, "default","on_rez: Initialize");
        Initialize();
    }

    attach( key _k )
    {
        if ( _k != NULL_KEY )
        {
            OwnerSay(3, "default","attach: Request Permissions");
            llRequestPermissions( llGetOwner(), PERMISSION_OVERRIDE_ANIMATIONS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_TAKE_CONTROLS );
        };
    }

    run_time_permissions( integer _perm )
    {
      if ( _perm != (PERMISSION_OVERRIDE_ANIMATIONS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_TAKE_CONTROLS) )
         gotPermission = FALSE;
      else
      {
         llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );
         gotPermission = TRUE;
      }
    }
 

    link_message(integer _sender, integer _num, string _message, key _id)
    {
        OwnerSay(3, "link_message","default: "+_message);
        
        if ( _message == "ZHAO_RESET" ) {
            OwnerSay(2, "link_message","default: Resetting..." );
            llResetScript();
        }
        else if ( _message == "ZHAO_AOON" )
        {
            
            OwnerSay(2, "link_message","default: ON");
            llSetTimerEvent( timerEventLength );
            animOverrideOn = TRUE;
            SetAnimationOverrides();
        }
        else if ( _message == "ZHAO_AOOFF" )
        {
            
            OwnerSay(2, "link_message","default: OFF");
            llSetTimerEvent( 0.0 );
            animOverrideOn = FALSE;
            ResetAnimationOverrides();
        }
        else if ( _message == "ZHAO_SITON" )
        {
            
            sitOverride = TRUE;
            OwnerSay(2, "link_message","default: "+ S_SIT + "On" );
            SetAnimationOverride("Sitting",0);    
        }
        else if ( _message == "ZHAO_SITOFF" )
        {
            
            sitOverride = FALSE;
            OwnerSay(2, "link_message","default: "+ S_SIT + "Off" );
            ResetAnimationOverride("Sitting");    
        
        }
        else if ( _message == "ZHAO_SITANYWHERE_ON" )
        {
            
            sitAnywhereOn = TRUE;
            OwnerSay(2, "link_message","default: "+ S_SIT_AW + "On" );
            SetStandingAnimationOverride("Sitting on Ground", 0);
        }
        else if ( _message == "ZHAO_SITANYWHERE_OFF" )
        {
            
            sitAnywhereOn = FALSE;
            OwnerSay(2, "link_message","default: "+ S_SIT_AW + "Off" );
            SetAnimationOverride("Standing",curStandIndex);    
        
        }
        else if ( _message == "ZHAO_TYPEAO_ON" )
        {
            typingOverrideOn = TRUE;
            typingStatus = FALSE;
            OwnerSay(2, "link_message","default: "+ S_TYPE + "On" );
        }
        else if ( _message == "ZHAO_TYPEAO_OFF" )
        {
            typingOverrideOn = FALSE;
            typingStatus = FALSE;
            OwnerSay(2, "link_message","default: "+ S_TYPE + "Off" );
        }
        else if ( _message == "ZHAO_RANDOMSTANDS" )
        {
            
            randomStands = TRUE;
            OwnerSay(2, "link_message","default: Stand cycling: Random" );
        
        }
        else if ( _message == "ZHAO_SEQUENTIALSTANDS" )
        {
            
            randomStands = FALSE;
            OwnerSay(2, "link_message","default: Stand cycling: Sequential" );
        
        }
        else if ( _message == "ZHAO_SETTINGS" )
        {
            
            if ( sitOverride )
            {
                OwnerSay(2, "link_message","default: "+ S_SIT + "On" );
            }
            else
            {
                OwnerSay(2, "link_message","default: "+ S_SIT + "Off" );
            }
            if ( sitAnywhereOn )
            {
                OwnerSay(2, "link_message","default: "+ S_SIT_AW + "On" );
            } else
            {
                OwnerSay(2, "link_message","default: "+  S_SIT_AW + "Off" );
            }
            if ( randomStands )
            {
                OwnerSay(2, "link_message","default: Stand cycling: Random" );
            }
            else
            {
                OwnerSay(2, "link_message","default: Stand cycling: Sequential" );
            }
            OwnerSay(2, "link_message","default: Stand cycle time: " + (string)standTime + " seconds" );
        }
        else if ( _message == "ZHAO_NEXTSTAND" )
        {
            doNextStand(TRUE);
        }
        else if ( llGetSubString(_message, 0, 14) == "ZHAO_STANDTIME|" )
        {
            standTime = (integer)llGetSubString(_message, 15, -1);
            OwnerSay(2, "link_message","default: Stand cycle time: " + (string)standTime + " seconds" );
        }
        else if ( llGetSubString(_message, 0, 8) == "ZHAO_LOAD" )
        {
            
            if ( loadInProgress == TRUE )
            {
                OwnerSay(2, "link_message","default: Still loading animations" );
                return;
            }
            loadAnimations();
        }
        else if ( _message == "ZHAO_SITS" )
        {
            doMultiAnimMenu( "Sitting" );
            listenState = 1;
        } else if ( _message == "ZHAO_WALKS" ) {
            doMultiAnimMenu( "Walking");
            listenState = 2;
        } else if ( _message == "ZHAO_GROUNDSITS" ) {
            if (sitAnywhereOn == TRUE)  doMultiAnimMenu("Sitting on Ground");
            listenState = 3;
        }
        else if ( llGetSubString(_message, 0, 10) == "END_NC_LOAD" )
        {
            SetAnimationOverrides();
        }
    }

    listen( integer _channel, string _name, key _id, string _message) {
        
        
        llListenControl(listenHandle, FALSE);

        if ( listenState == 1 ) {
            
            string _animType = "Sitting";
            SetAnimationOverride(_animType,(integer)_message - 1);            

        } else if ( listenState == 2 ) {
            
            string _animType = "Walking";
            SetAnimationOverride(_animType,(integer)_message - 1);            

        } else if ( listenState == 3 ) {
            
            SetStandingAnimationOverride("Sitting on Ground", (integer)_message - 1);            
        }
    }
  
    timer()
    {
        // Is it time to switch stand animations?
        // Stand cycling can be turned off
        if ( (standTime != 0) && ( llGetTime() > standTime ) )
        {
            // Don't interrupt the typing animation with a stand change.
            // Not from UI, no feedback
            if ( !typingStatus )
                doNextStand(FALSE);
        }
        // TYPING AO!!!!!!!!!!!
        if (typingOverrideOn)
        {            
//           are we typing
            OwnerSay(4, "timer","are we typing "+(string)llGetAgentInfo(llGetOwner()) );
            if ( llGetAgentInfo(llGetOwner()) == 518 )
            {
                SetStandingAnimationOverride("Typing", 0);
                typingStatus = TRUE;
            }
            else if (typingStatus)
            {
                SetAnimationOverride("Standing", curStandIndex);
                typingStatus = FALSE;
            };
                
        }
    

    }
}

