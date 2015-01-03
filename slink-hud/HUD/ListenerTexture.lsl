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
ProcessMessage(string textLayer, string textUUID) 
{
    integer i;
    OwnerSay(3,"ProcessMessage", textLayer);
    for (i=0;i<itemConfigurationCount;i++)
    {
        OwnerSay(3,"ProcessMessage", textLayer+" "+llList2String(llList2List(itemConfiguration,i,i),0));
        //process texture
        if (llList2String(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),0)==textLayer)
        {
            OwnerSay(3,"ProcessMessage", "found "+textLayer+" "+llList2String(llList2List(itemConfiguration,i,i),1)+" on "+(string)llList2Integer(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),1));
            llSetTexture((key)textUUID, llList2Integer(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),1)  );
        };
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
        if (llList2String(message,0)=="text-util")
        {
            OwnerSay(3,"default.listen",msg);
            ProcessMessage(llList2String(message,1),llList2String(message,2));
        };
        
    }
    dataserver(key request_id, string data)
    {
        if (request_id == notecardQueryId) ProcessConfiguration(data);
    }    
} 