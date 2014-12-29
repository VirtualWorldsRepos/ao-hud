vector rothidden_d = <270, 0, 0>;
vector rotshown_d = <270, 0, 270>;

rotation rotshown;
rotation rothidden;

integer hudshown = TRUE;

rotation calcrot(vector rot)
{
    rot *= DEG_TO_RAD;
    return llEuler2Rot(rot);
}

position(integer show)
{
    integer attachPoint = llGetAttached();
    
    if(attachPoint != 0)
    {
        float y;
        float z;
        vector size = llGetScale(); 
        
        //llOwnerSay((string)size);          
                
        y = size.z / 2.0;
        
        // Nasty if else block
        
        if(show)
        {
            llSetRot(rotshown);
            z = size.x - 0.025;
        }
        else
        {
            llSetRot(rothidden);
            z = size.y;
        }
        
        if (attachPoint == 32) // HUD Top Right
        {
            llSetPos(<0, y, z>);
        }
        else if (attachPoint == 33) // HUD Top
        {
            llSetPos(<0,0,-z>);
        }
        else if (attachPoint == 34) // HUD Top Left
        {
            llSetPos(<0,-y,-z>);
        }
        else if (attachPoint == 36) // HUD Bottom Left
        {
            llSetPos(<0, -y, z>);
        }
        else if (attachPoint == 37) // HUD Bottom
        {
            llSetPos(<0, 0, z>);
        }
        else if (attachPoint == 38) // HUD Bottom Right
        {
            llSetPos(<0, y, z>);
        }    
    }
}

OwnerSay(string Procedure, string Message)
{   llOwnerSay("Carl-Position-Handler: "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+Procedure+" - "+Message);}

printFreeMemory()
{   OwnerSay("printFreeMemory", (string) (llGetFreeMemory()/1024) + "Kb memory free." );
    OwnerSay("printFreeMemory",  (string) (llGetUsedMemory()/1024) + "Kb memory used." );
    OwnerSay("printFreeMemory",  (string) ((llGetUsedMemory() + llGetFreeMemory())/1024) + "Kb memory total." );}

default
{
    state_entry()
    {
        integer memoryLimit = 12*1024;
        llSetMemoryLimit(memoryLimit);
        printFreeMemory();
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
        rotshown = calcrot(rotshown_d);
        rothidden = calcrot(rothidden_d);
        position(hudshown);
    }
    
    attach(key id)
    {
        if (id != NULL_KEY)
        {
            position(hudshown);
        }
    }
    
    link_message(integer sender, integer num, string msg, key id)
    {
        if("ZHAO_TOGGLE_SHOW" == msg)
        {
            hudshown = !hudshown;
            position(hudshown);
        }
        if("ZHAO_SHOW" == msg)
        {
            hudshown = TRUE;
            position(hudshown);
        }
    }
    run_time_permissions( integer _perm ) 
    {
      if (_perm == (PERMISSION_TAKE_CONTROLS)) llTakeControls(CONTROL_BACK, FALSE, TRUE);
    }
 
 }
