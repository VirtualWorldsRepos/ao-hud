string configurationNotecardName = "Slink.Config";
key notecardQueryId;
// Level
// 0 - Error
// 1 - Warning
// 2 - Info/Debug
// 3 - Debug
// 4 - Extreme Debug
integer defaultLevel=2;
list Levels=["Error","Warning","Info","Debug"];

OwnerSay(integer Level, string Procedure, string Message) 
{
    if (Level<=defaultLevel)
    llOwnerSay(llGetScriptName()+": "+llGetSubString( (string)llGetTimestamp() ,11 ,21 )+ " - "+llList2String(Levels,Level)+ " - "+Procedure+" - "+Message);
}
ReadConfiguration() {
    if(llGetInventoryType(configurationNotecardName) != INVENTORY_NOTECARD)
    {
        OwnerSay(0,"ReadConfiguration","Missing inventory notecard: " + configurationNotecardName);
        return;
    }
    notecardQueryId = llGetNotecardLine(configurationNotecardName, 0);
}
ProcessConfiguration(string data) {
    if(data == EOF)
    {
        OwnerSay(2,"ProcessConfiguration","We are done reading the configuration");
    };
 
    if(data != "")
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_DESC, data]);
    };
}
default
{
    
    changed(integer change)
    {
    if (change & CHANGED_OWNER  ) // Reset script on change of owner.
        llResetScript();
    }

    state_entry()
    {
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
        ReadConfiguration();
    }

    listen(integer channel, string name, key id, string msg)
    {
        list message =  llParseString2List(msg,[","],[" "]);
        list description = llParseString2List(llList2String(llGetLinkPrimitiveParams(LINK_THIS, [PRIM_DESC]),0),[","],[" "]);
        if (llList2String(description,0)==llList2String(message,0))
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE,(integer)llList2String(description,1), llList2String(message,1), <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0]);
    }
    dataserver(key request_id, string data)
    {
        if (request_id == notecardQueryId) ProcessConfiguration(data);
    }    
} 