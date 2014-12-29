string configurationNotecardName = "Slink.Config";
key notecardQueryId;
integer notecardLine;
string textureLayer;
string textureUUID;

// Level
// 0 - Error
// 1 - Warning
// 2 - Info
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=3;
list Levels=["Error","Warning","Info","Debug","Extreme Debug"];

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
            if (llList2String(llParseString2List(data,[","],[" "]),0)==textureLayer)
            {
                OwnerSay(3,"ProcessConfiguration", "found "+textureLayer);
                llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE,(integer)llList2String(llParseString2List(data,[","],[" "]),1), textureUUID, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0]);
            };
        };
        ++notecardLine;
        notecardQueryId = llGetNotecardLine(configurationNotecardName, notecardLine);
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
        }
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
        OwnerSay(3,"default.listen",msg);
        textureLayer=llList2String(message,0);
        textureUUID=llList2String(message,1);
        ReadConfiguration();    
    }
    dataserver(key request_id, string data)
    {
        if (request_id == notecardQueryId) ProcessConfiguration(data);
    }    
} 