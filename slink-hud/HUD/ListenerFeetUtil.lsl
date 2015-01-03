//
// Initialise the Library 
//
#include "OwnerSay.lsl" 
//-----------------------------------------------------------------------------
// write the rest of your code
//-----------------------------------------------------------------------------

integer defaultSkin=0;
integer defaultNail=1;
integer defaultTattoo=3;
integer defaultStock=2;
integer toggleNail=FALSE;
integer toggleTattoo=FALSE;
integer toggleStock=FALSE;

// Level
// 0 - Error
// 1 - Warning
// 2 - Info
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=2;

ProcessMessage(string command) 
{
    OwnerSay(3,"ProcessMessage", command);
    //process utilities
    //Nail
    if (llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_COLOR, 1]),1)==1.0)
    {
        toggleNail=TRUE;
        OwnerSay(3,"ProcessMessage","toggleNail=TRUE");
    };
    //Stockings
    if (llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_COLOR, 2]),1)==1.0)
    {
        toggleStock=TRUE;
        OwnerSay(3,"ProcessMessage","toggleStock=TRUE");
    };
    //Tattoo
    if (llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_COLOR, 3]),1)==1.0)
    {
        toggleTattoo=TRUE;
        OwnerSay(3,"ProcessMessage","toggleTattoo=TRUE");
    };
    //process nail length
    switch(command)
    {
        case "btn_tattoo_on":
        {
            toggleTattoo=TRUE;
            OwnerSay(3,"ProcessMessage","toggleTattoo=TRUE");
            break;
        }
        case "btn_tattoo_off":
        {
            toggleTattoo=FALSE;
            OwnerSay(3,"ProcessMessage","toggleTattoo=FALSE");
            break;
        }
        case "btn_stockings_on":
        {
            toggleStock=TRUE;
            OwnerSay(3,"ProcessMessage","toggleStock=TRUE");
            break;
        }
        case "btn_stockings_off":
        {
            toggleStock=FALSE;
            OwnerSay(3,"ProcessMessage","toggleStock=FALSE");
            break;
        }
        case "btn_nails_on":
        {
            toggleNail=TRUE;
            OwnerSay(3,"ProcessMessage","toggleNail=TRUE");
            break;
        }
        case "btn_nails_off":
        {
            toggleNail=FALSE;
            OwnerSay(3,"ProcessMessage","toggleNail=FALSE");
            break;
        }
    };
    if (toggleNail==TRUE)
    {
        OwnerSay(3,"ProcessMessage","Activate Default Nail on "+(string)defaultNail);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 1.0]);
    }
    else
    {
        OwnerSay(3,"ProcessMessage","De-activate Default Nail on "+(string)defaultNail);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
    };
    if (toggleTattoo==TRUE)
    {
        OwnerSay(3,"ProcessMessage","Tattoo on "+(string)defaultTattoo);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultTattoo, <1.0, 1.0, 1.0>, 1.0]);
    }
    else
    {
        OwnerSay(3,"ProcessMessage","Tattoo off "+(string)defaultTattoo);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultTattoo, <1.0, 1.0, 1.0>, 0.0]);
    };
    if (toggleStock==TRUE)
    {
        OwnerSay(3,"ProcessMessage","Stockings on "+(string)defaultStock);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultStock, <1.0, 1.0, 1.0>, 1.0]);
    }
    else
    {
        OwnerSay(3,"ProcessMessage","Stockings off "+(string)defaultStock);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultStock, <1.0, 1.0, 1.0>, 0.0]);
    };
}
default
{
    
    changed(integer change)
    {
        if (change & CHANGED_OWNER  )
        {
            OwnerSay(3,"default.changed","I have been changeded!");
            llResetScript();
        };
    }
    attach(key id)
    {
        if (id)     // is a valid key and not NULL_KEY
        {
            OwnerSay(3,"default.attach","I have been attached!");
            llResetScript();
        }
        else
        {
            OwnerSay(3,"default.attach","I have been detattached!");
        }
    }
    state_entry()
    {
        OwnerSay(3,"default.state_entry","listening!");
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
    }

    listen(integer channel, string name, key id, string msg)
    {
        list message =  llParseString2List(msg,[","],[" "]);
        if (llList2String(message,0)=="feet-util")
        {
            OwnerSay(3,"default.listen",msg);
            ProcessMessage(llList2String(message,1));
        };
    }
} 