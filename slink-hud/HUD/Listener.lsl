string configurationNotecardName = "Slink.Config";
key notecardQueryId;
integer notecardLine;
list itemConfiguration=[];
integer itemConfigurationCount=0;

// Level
// 0 - Error
// 1 - Warning
// 2 - Info
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=3;
list Levels=["Error","Warning","Info","Debug","Extreme Debug"];

Initialization()
{
    itemConfiguration=[];
    itemConfigurationCount=0;
    ReadConfiguration();    
}

OwnerSay(integer Level, string Procedure, string Message) 
{
    if (Level<=defaultLevel)
    llOwnerSay(llGetScriptName()+": "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+llList2String(Levels,Level)+ " - "+Procedure+" - "+Message);
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
ProcessTexture(string textLayer, string textUUID) 
{
    integer i;
    OwnerSay(3,"ProcessTexture", textLayer);
    for (i=0;i<itemConfigurationCount;i++)
    {
        OwnerSay(3,"ProcessTexture", textLayer+" "+llList2String(llList2List(itemConfiguration,i,i),0));
        if (llList2String(llParseString2List(llList2String(itemConfiguration,i),[","],[" "]),0)==textLayer)
        {
            OwnerSay(3,"ProcessTexture", "found "+textLayer+" "+llList2String(llList2List(itemConfiguration,i,i),1));
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
        OwnerSay(3,"default.listen",msg);
        ProcessTexture(llList2String(message,0),llList2String(message,1));
        
    }
    dataserver(key request_id, string data)
    {
        if (request_id == notecardQueryId) ProcessConfiguration(data);
    }    
} 