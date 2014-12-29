deleteTextures()
{
    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);  // Count of all items in prim's contents
    while (count--)
    {
        llRemoveInventory(llGetInventoryName(INVENTORY_TEXTURE, count));
    }
    disableButtons();
}
disableButtons()
{
    integer i;
    integer linkcount = llGetNumberOfPrims();
    for (i = 1; i <= linkcount; ++i)
    {
        if (llGetSubString(llGetLinkName(i),-7,-1) == "-status")
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_ROT_LOCAL, <0.00000, 0.00000, 0.00000, 1.00000>]);    
        }
    }
}
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
enableButtons()
{
    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);  // Count of all items in prim's contents
    integer linkNumber;
    integer linkStatusNumber;
    rotation rot90x = llEuler2Rot(<0, 90, 0> * DEG_TO_RAD );//  Create a rotation constant
    while (count--)
    {
        linkNumber=getLink(llGetInventoryName(INVENTORY_TEXTURE, count));
        if (linkNumber==-1) 
        {
            llRemoveInventory(llGetInventoryName(INVENTORY_TEXTURE, count));
        }
        else
        {    
            linkStatusNumber=getLink(llGetInventoryName(INVENTORY_TEXTURE, count)+"-status");
            llSetLinkPrimitiveParamsFast(linkStatusNumber, 
            [ PRIM_ROT_LOCAL, rot90x*llList2Rot(llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_ROT_LOCAL]), 0)]);    
        }
    }
}

integer breastsTrans = 1;
default
{
    state_entry()
    {
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) //note that it's & and not &&... it's bitwise!
        {
            llOwnerSay("The inventory has changed.");
            disableButtons();
            enableButtons();            
        }
    }
    touch_start(integer total_number)
    {
        llOwnerSay(llGetLinkName(llDetectedLinkNumber(0)));
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        
        if (llGetLinkName(llDetectedLinkNumber(0))=="delete-textures") deleteTextures();
        
        if (llGetInventoryType(llToUpper(llGetLinkName(llDetectedLinkNumber(0))))==INVENTORY_TEXTURE)        // if a texture exists ...
        {
            key uuid = llGetInventoryKey(llToUpper(llGetLinkName(llDetectedLinkNumber(0))));
            llSay(channel, llGetLinkName(llDetectedLinkNumber(0))+","+(string)uuid);
        }        
        
    }
}