//
// Initialise the Library 
//
#include "OwnerSay.lsl" 
//-----------------------------------------------------------------------------
// write the rest of your code
//-----------------------------------------------------------------------------

string configurationNotecardName = "Slink.Config";
key notecardQueryId;
integer notecardLine;
list itemConfiguration=[];
integer itemConfigurationCount=0;
integer defaultNail;
integer defaultTattoo;
integer toggleNail=FALSE;
integer toggleTattoo=FALSE;

// Level
// 0 - Error
// 1 - Warning
// 2 - Info
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=2;

Initialization()
{
    itemConfiguration=[];
    itemConfigurationCount=0;
    ReadConfiguration();    
}

ReadConfiguration() 
{
    if(llGetInventoryType(configurationNotecardName) != INVENTORY_NOTECARD)
    {
        OwnerSay(0,"ReadConfiguration","Missing inventory notecard: " + configurationNotecardName);
        return;
    }
    notecardLine=0;
    notecardQueryId = llGetNotecardLine(configurationNotecardName, notecardLine);
}
ProcessConfiguration(string data) {
    if(data == EOF)
    {
        OwnerSay(2,"ProcessConfiguration","We are done reading the configuration");
    }
    else
    {
        OwnerSay(3,"ProcessConfiguration", data);
        if(data != "")
        {
            itemConfiguration = (itemConfiguration=[]) + itemConfiguration + data;
            ++itemConfigurationCount;
            OwnerSay(3,"ProcessConfiguration", llList2String(llParseString2List(data,[","],[" "]),0));
        };
        ++notecardLine;
        notecardQueryId = llGetNotecardLine(configurationNotecardName, notecardLine);
    }; 
}

ProcessMessage(string command) 
{
    OwnerSay(3,"ProcessMessage", command);
    //process utilities
    integer i;
    for (i=0;i<itemConfigurationCount;i++)
    {
        string configurationItem=llList2String(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),0);
        integer face=llList2Integer(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),1);
        OwnerSay(3,"CycleNails",configurationItem);
        //Identify default nail
        if (llGetSubString(configurationItem,-5,-1)=="-nail")
        {
            if (llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_COLOR, face]),1)==1.0)
            {
                defaultNail=i;
                toggleNail=TRUE;
                OwnerSay(3,"CycleNails","defaultNail="+(string)i);
            };
        };
        //Identify toggle tattoo
        if (configurationItem=="hand-tattoo")
        {
            defaultTattoo=llList2Integer(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),1);
            if (llList2Float(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_COLOR, defaultTattoo]),1)==1.0)
            {
                toggleTattoo=TRUE;
                OwnerSay(3,"CycleNails","toggleTattoo=TRUE");
            };
        };
    };
    //process on-off
    if (command=="btn_off")
    {
    };
    //process nail length
    switch(command)
    {
        case "btn_tattoo_on":
        {
            OwnerSay(3,"CycleNails","btn_tattoo_on");
            if (toggleTattoo==FALSE)
            {
                toggleTattoo=TRUE;
                OwnerSay(3,"CycleNails","toggleTattoo=TRUE");
            };
            break;
        }
        case "btn_tattoo_off":
        {
            OwnerSay(3,"CycleNails","btn_tattoo_on");
            if (toggleTattoo==TRUE)
            {
                toggleTattoo=FALSE;
                OwnerSay(3,"CycleNails","toggleTattoo=FALSE");
            };
            break;
        }
        case "btn_off":
        {
            OwnerSay(3,"CycleNails","btn_off");
            if (toggleNail==TRUE)
            {
                toggleNail=FALSE;
                OwnerSay(3,"CycleNails","toggleNail=FALSE");
            }
            else
            {
                toggleNail=TRUE;
                OwnerSay(3,"CycleNails","toggleNail=TRUE");
            };
            break;
        }
        case "btn_short":
        {
            
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
            defaultNail=1;
            OwnerSay(3,"CycleNails","btn_short");
            break;
        }
        case "btn_medium":
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
            defaultNail=4;
            OwnerSay(3,"CycleNails","btn_medium");
            break;
        }
        case "btn_long":
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
            defaultNail=2;
            OwnerSay(3,"CycleNails","btn_long");
            break;
        }
        case "btn_pointed":
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
            defaultNail=3;
            OwnerSay(3,"CycleNails","btn_pointed");
            break;
        }
    };
    if (toggleNail==TRUE)
    {
        OwnerSay(3,"CycleNails","Activate Default Nail on "+(string)defaultNail);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 1.0]);
    }
    else
    {
        OwnerSay(3,"CycleNails","De-activate Default Nail on "+(string)defaultNail);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultNail, <1.0, 1.0, 1.0>, 0.0]);
    };
    if (toggleTattoo==TRUE)
    {
        OwnerSay(3,"CycleNails","Tattoo on "+(string)defaultTattoo);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultTattoo, <1.0, 1.0, 1.0>, 1.0]);
    }
    else
    {
        OwnerSay(3,"CycleNails","Tattoo off "+(string)defaultTattoo);
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, defaultTattoo, <1.0, 1.0, 1.0>, 0.0]);
    };
    llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_COLOR, 0, <1.0, 1.0, 1.0>, 1.0]);    
}
default
{
    
    changed(integer change)
    {
        if (change & CHANGED_OWNER  )
        {
            OwnerSay(3,"default.changed","I have been changeded!");
            llResetScript();
            Initialization();
        }
    }
    attach(key id)
    {
        if (id)     // is a valid key and not NULL_KEY
        {
            OwnerSay(3,"default.attach","I have been attached!");
            llResetScript();
            Initialization();
        }
        else
        {
            OwnerSay(3,"default.attach","I have been detattached!");
        }
    }
    state_entry()
    {
        OwnerSay(3,"default.state_entry","listening!");
        Initialization();
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
    }

    listen(integer channel, string name, key id, string msg)
    {
        list message =  llParseString2List(msg,[","],[" "]);
        if (llList2String(message,0)=="hands-util")
        {
            OwnerSay(3,"default.listen",msg);
            ProcessMessage(llList2String(message,1));
        };
    }
    dataserver(key request_id, string data)
    {
        if (request_id == notecardQueryId) ProcessConfiguration(data);
    }    
}