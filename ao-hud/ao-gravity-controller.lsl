key User;
key Owner;
float Force;
float Volume = 1.0;
integer Channel;
integer Handle;
list Options = ["Moon","*Normal*","Heavy","Crush","Feather","Space","â€¢>>","^-SkyDive-^","< <â€¢","---","<<â€¢>>","+++"];
Menu(){
    Handle = llListen(Channel, "", Owner, "");
    string Info = "\n*Select your desired level of Gravity; SkyDive will send you about 1000m up.\n*The +++ & --- options will increase or decrease your \"current\" gravity by a factor of 0.5\n\nNOTE>> Use the \"Normal\" option to restore normality =)";
    llDialog(Owner, Info, Options, Channel);
    llSetTimerEvent(60.0);
}

OwnerSay(string Procedure, string Message)
{   llOwnerSay("Gravity-Cotroller: "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+Procedure+" - "+Message);}

printFreeMemory()
{   OwnerSay("printFreeMemory", (string) (llGetFreeMemory()/1024) + "Kb memory free." );
    OwnerSay("printFreeMemory",  (string) (llGetUsedMemory()/1024) + "Kb memory used." );
    OwnerSay("printFreeMemory",  (string) ((llGetUsedMemory() + llGetFreeMemory())/1024) + "Kb memory total." );}
 
default{
//
    state_entry(){
        integer memoryLimit = 20*1024;
        llSetMemoryLimit(memoryLimit);
        printFreeMemory();
        Owner = llGetOwner();
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
        Channel = (integer)llFrand(DEBUG_CHANNEL) * -1;
    }
//
    on_rez(integer total_number){
        if (Owner != llGetOwner()){
            llResetScript();
        }
    }

    link_message(integer sender, integer num, string str, key id){
        if (str == "GRAVITY>>MENU"){
            llSetObjectName("Gravity Control");
            Menu();
        }     
    }
//
    timer(){//Remove lag/listen after llSetTimerEvent
        llSetTimerEvent(0.0);//Dont want to keep stopping.. so we end the timer.
        llListenRemove(Handle);//& do what timer is here for; remove listen/lag.
    }
// 
    listen(integer channel, string name, key id, string message){
        if (llListFindList(Options, [message]) != -1){
            float Mass = llGetMass(); 
            if(message == "+++"){
                Force += 0.25;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();//re-open the menu
            }
            else if(message == "---"){
                Force -= 0.25;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            }  
            else if(message == "Moon"){
                Force = 6.5;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            }
            else if(message == "Heavy"){
                Force = -9.8;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            }
            else if(message == "Feather"){
                Force = 9.25;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            } 
            else if(message == "Crush"){
                Force = 2147483647.0;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,-Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            }
            else if(message == "Space"){ 
                Force = 9.8;   
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,Force>, TRUE);
                llOwnerSay("/me >> Gravity : " + (string)Force+" :");
                Menu();
            }
            else if(message == "*Normal*"){
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,0>, TRUE);
                llOwnerSay("/me >> Gravity : Normal (<0,0,0>) :");
            }                                                               
            else if(message == "^-SkyDive-^"){
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,2147483647.0>, TRUE);
                llOwnerSay("/me >> Gravity : SkyDive :");
                llSleep(5.0);
                llTriggerSound("be0cd87b-ae95-2fb5-6250-dcdd4d2ce732",Volume);
                llSetForce(Mass*<0,0,0>, TRUE);
                llOwnerSay("/me >> Gravity : Restored :\n       (Parachute on?..)");
                llResetScript();
            }
        }
    }
    run_time_permissions( integer _perm ) 
    {
      if (_perm == (PERMISSION_TAKE_CONTROLS)) llTakeControls(CONTROL_BACK, FALSE, TRUE);
    }
    
//
} 