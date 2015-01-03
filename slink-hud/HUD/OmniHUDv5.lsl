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
integer defaultLevel=4;

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
        if (llGetSubString(llGetLinkName(i),-5,-1) == "-text")
        {
            llSetLinkPrimitiveParamsFast(i, [PRIM_TEXT, "no texture", <1.000, 0.522, 0.106>, 1.0]);
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
            llSetLinkPrimitiveParamsFast(getLink(llGetInventoryName(INVENTORY_TEXTURE, count)+"-text"), [PRIM_TEXT, "", ZERO_VECTOR, 0.0]);
        }
    }
}

default
{
    state_entry()
    {
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        llListen(channel,"","","");
        disableButtons();
        enableButtons();            
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) //note that it's & and not &&... it's bitwise!
        {
            OwnerSay(2,"default.changed","The inventory has changed.");
            disableButtons();
            enableButtons();            
        }
    }
    touch_start(integer total_number)
    {
            OwnerSay(2,"default.touch_start","llGetLinkName(llDetectedLinkNumber(0))="+llGetLinkName(llDetectedLinkNumber(0)));
        integer channel = (integer)("0x"+llGetSubString((string)llGetOwner(),-16,-1));
        
        if (llGetLinkName(llDetectedLinkNumber(0))=="delete-textures") deleteTextures();
        
        if (llGetInventoryType(llToUpper(llGetLinkName(llDetectedLinkNumber(0))))==INVENTORY_TEXTURE)        // if a texture exists ...
        {
            key uuid = llGetInventoryKey(llToUpper(llGetLinkName(llDetectedLinkNumber(0))));
            llSay(channel, "text-util,"+llGetLinkName(llDetectedLinkNumber(0))+","+(string)uuid);
        }        
        
    }
}