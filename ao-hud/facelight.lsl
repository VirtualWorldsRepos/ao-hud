integer handle;
integer mychannel;
integer facelighttoggle;
key owner; 

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

    owner = llGetOwner();
    mychannel = Key2Number(owner);
    llListenRemove(handle);//shouldn't be necessary but can't hurt
    handle =llListen(mychannel,"","","");
    OwnerSay("attach","Facelight listening on channel: "+(string)mychannel);

    llReleaseControls();
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    
    facelighttoggle=0;
    llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, <1, 1, 1>, facelighttoggle, 2.0, 0.002]);
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
        {
            initialize();
        }
        else
        {
            llListenRemove(handle);
            llReleaseControls();    // detached
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        
        if ((llGetOwnerKey(id) == owner) & (message=="facelighttoggle"))
        {
            if (facelighttoggle==0) {facelighttoggle=1;} else {facelighttoggle=0;};
            if (facelighttoggle==1) {OwnerSay("listen","Facelight On");} else {OwnerSay("listen","Facelight Off");};
            llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, <1, 1, 1>, facelighttoggle, 2.0, 0.002]);
            
        }
    }
    run_time_permissions( integer _perm ) 
    {
        integer hasPerms = llGetPermissions();
        llTakeControls( 0 , FALSE, TRUE);
    }
}