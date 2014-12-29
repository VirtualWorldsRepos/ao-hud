// attachment vars
integer statusAO=0; //off
list overrides;
integer curDanceIndex;
integer numOverrides;
integer danceTimeDefault = 60;
// Link names/numbers for the extra buttons:
string btnMenu = "Menu";                //Menu button
string btnOptions  = "Options ";        //Options button
string btnOnOff = "Carl-Dance-Ao-Hud";  //ON/OFF button
string btnBack = "Back";                //Back button
string btnNext = "Next";                //Next button

printFreeMemory()
{
    OwnerSay("printFreeMemory", (string) (llGetFreeMemory()/1024) + "Kb memory free." );
    OwnerSay("printFreeMemory",  (string) (llGetUsedMemory()/1024) + "Kb memory used." );
    OwnerSay("printFreeMemory",  (string) ((llGetUsedMemory() + llGetFreeMemory())/1024) + "Kb memory total." );
}
OwnerSay(string Procedure, string Message)
{
    llOwnerSay(llGetScriptName()+": "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+Procedure+" - "+Message);
}

integer Key2Number(key objKey)
{
    return ((integer)("0x"+llGetSubString((string)objKey,-8,-1)) & 0x3FFFFFFF) ^ 0x3FFFFFFF;
}
initialize()
{
    integer memoryLimit = 32*1024;
    llSetMemoryLimit(memoryLimit);
    printFreeMemory();

    llReleaseControls();
    llRequestPermissions( llGetOwner(), PERMISSION_OVERRIDE_ANIMATIONS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_TAKE_CONTROLS );
    
// attachment code
    llSetTimerEvent(danceTimeDefault);
    llMinEventDelay( 0.0 );
    OwnerSay("initialize","Loading Animatinons..." );
    overrides = [];
    curDanceIndex = 0;
    integer i;
    for (i=0; i<llGetInventoryNumber(INVENTORY_ANIMATION); i++) overrides =  (overrides=[]) + overrides + [ llGetInventoryName(INVENTORY_ANIMATION, i)];
    numOverrides = llGetListLength(overrides);
    OwnerSay("initialize",(string)numOverrides + " animation entries found.");
    printFreeMemory();
}    
SetAnimationOverride(integer index)
{
    string dance = llList2String(overrides,index);
    llSetAnimationOverride("Standing", dance);
    OwnerSay("SetAnimationOverride", "Standing"+ " :: " + dance);
}
DoMenu()
{}
DoOptions()
{}
ToggleAO()
{}
DoBack()
{
    curDanceIndex--;
    if (curDanceIndex<0) curDanceIndex=numOverrides-1;
    SetAnimationOverride(curDanceIndex);
}
DoNext()
{
    curDanceIndex++;
    if (curDanceIndex>=numOverrides) curDanceIndex=0;
    SetAnimationOverride(curDanceIndex);
}

    
default
{
    state_entry()
    {
      initialize();
    }

    touch_start( integer _num ) 
    {
        
        integer lntmp = llDetectedLinkNumber(0);
        string btmp = llGetLinkName(lntmp);
        
        if (btmp == btnMenu) 
            DoMenu();
        else if (btmp == btnOptions)
            DoOptions();
        else if (btmp == btnOnOff)
        {
            //TURN OFF
            if (statusAO==1) 
            {
                llResetAnimationOverride("Standing");
                llSetLinkPrimitiveParamsFast(LINK_ALL_OTHERS,[PRIM_COLOR,ALL_SIDES,<1,1,1>,(float)FALSE]);
                llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR,ALL_SIDES,<1,0.251,0.251>,(float)TRUE]);
                statusAO=0;
            }
            else //TURN ON
            {
                DoNext();
                llSetLinkPrimitiveParamsFast(LINK_ALL_OTHERS,[PRIM_COLOR,ALL_SIDES,<1,1,1>,(float)TRUE]);
                llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR,ALL_SIDES,<1,1,1>,(float)TRUE]);
                statusAO=1;
            };
        }
        else if (btmp == btnBack) 
            DoBack();
        else if (btmp == btnNext) 
            DoNext();
    }
    
    attach(key attached)
    {
        if(attached)
            initialize();
        else
        {
            llReleaseControls();    // detached
        }
    }

    timer()
    {
// attachment code
    }
     run_time_permissions( integer _perm ) 
    {
        integer hasPerms = llGetPermissions();
        llTakeControls( 0 , FALSE, TRUE);
    }
}
