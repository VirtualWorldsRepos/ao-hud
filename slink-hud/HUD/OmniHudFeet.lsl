//
// Initialise the Library 
//
#include "OwnerSay.lsl" 
//-----------------------------------------------------------------------------
// write the rest of your code
//-----------------------------------------------------------------------------

// Level
// 0 - Error
// 1 - Warning
// 2 - Info
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=2;

default
{
    state_entry()
    {
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
        OwnerSay(2,"default.state_entry","Listener Initialized");
    }
    touch_start(integer total_number)
    {
        OwnerSay(3,"default.touch_start","llDetectedLinkNumber(0)="+(string)llDetectedLinkNumber(0));
        OwnerSay(3,"default.touch_start","llGetLinkName(llDetectedLinkNumber(0))="+llGetLinkName(llDetectedLinkNumber(0)));
        if (llDetectedLinkNumber(0)!=1)
        {
            integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        
            key uuid = llGetInventoryKey(llToUpper(llGetLinkName(llDetectedLinkNumber(0))));
            llSay(channel, "feet-util,"+llGetLinkName(llDetectedLinkNumber(0)));        
        };
    }
}