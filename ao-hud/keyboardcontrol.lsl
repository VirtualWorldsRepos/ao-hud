integer handle;
integer mychannel;
// attachment vars
integer keyboardtoggle;

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
    integer memoryLimit = 12*1024;
    llSetMemoryLimit(memoryLimit);
    printFreeMemory();

    mychannel = Key2Number(llGetOwner());
    llListenRemove(handle);//shouldn't be necessary but can't hurt
    handle =llListen(mychannel,"","","");
    OwnerSay("initialize","listening on channel: "+(string)mychannel);

    llReleaseControls();
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    
// attachment code
    keyboardtoggle=0;
    llSetTimerEvent(.25);
    llSetTexture("5644cb8f-1fc2-9e90-0ae0-6d69becd2fa3",0); //romulan
//          llSetTexture("83e527c6-358b-b6f7-7b23-376de513df62",0); //borg           
//          llSetTexture("9e4651f3-890f-1bd3-5e73-affa231ffe36",0); //cardassian
//          llSetTexture("cc39d330-753f-ddd7-c7c7-0edce8800e44",0); //ferengi
//          llSetTexture("8238e23f-750c-bd8b-0155-14540c7c9d52",0); //klingon
}    
default
{
    state_entry()
    {
      initialize();
    }
    attach(key attached)
    {
        if(attached)
            initialize();
        else
        {
            llListenRemove(handle);
            llReleaseControls();    // detached
        }
    }

    listen(integer channel, string name, key id, string message)
    {

// attachment code
        if ((llGetOwnerKey(id) == llGetOwner()) & (message=="keyboardtoggle"))
        {
            if (keyboardtoggle==0) {keyboardtoggle=1;} else {keyboardtoggle=0;}
        }
    }
    timer()
    {
// attachment code
        if ( llGetAgentInfo(llGetOwner()) == 518 )
            llSetLinkPrimitiveParamsFast(LINK_THIS,[ PRIM_COLOR, ALL_SIDES,<255,255,255>, 1.0 ]);
        else
            llSetLinkPrimitiveParamsFast(LINK_THIS,[ PRIM_COLOR, ALL_SIDES,<255,255,255>, 0.0 ]);
    }
     run_time_permissions( integer _perm ) 
    {
        integer hasPerms = llGetPermissions();
        llTakeControls( 0 , FALSE, TRUE);
    }
}
