integer getLink(string linkName)
{
    integer i;
    integer linkcount = llGetNumberOfPrims();
    integer LINK_TARGET = -1;
    for (i = 1; i <= linkcount; ++i)
    {
        if (llGetLinkName(i) == llToLower(linkName))
        {
            LINK_TARGET = i;
        }
    }
    return LINK_TARGET;
}
default
{
    state_entry()
    {
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
    }
    touch_start(integer total_number)
    {
        llOwnerSay(llGetLinkName(llDetectedLinkNumber(0)));
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        
        key uuid = llGetInventoryKey(llToUpper(llGetLinkName(llDetectedLinkNumber(0))));
        llSay(channel, "nails-util,"+llGetLinkName(llDetectedLinkNumber(0)));        
    }
}