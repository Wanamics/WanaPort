namespace Wanamics.Wanaport;

using Microsoft.Finance.GeneralLedger.Journal;
pageextension 87097 "WanaPort Gen. Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("wan Import Object Type"; Rec."WanaPort Object Type")
            {
                ApplicationArea = All;
            }
            field("wan Import Object ID"; Rec."WanaPort Object ID")
            {
                ApplicationArea = All;
            }
        }
    }
}
