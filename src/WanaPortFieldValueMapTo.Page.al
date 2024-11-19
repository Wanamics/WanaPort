namespace Wanamics.Wanaport;

using System.Reflection;
page 87097 "WanaPort Field Value Map-to"
{
    ApplicationArea = All;
    Caption = 'Field Value Map-to';
    PageType = List;
    SourceTable = "WanaPort Field Value Map-to";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ToolTip = 'Specifies the value of the Object Type field.';
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ToolTip = 'Specifies the value of the Object ID field.';
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the value of the Table No. field.';
                    LookupPageId = Objects;
                    Width = 6;
                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Table Caption");
                    end;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                }
                field("From Code"; Rec."From Code")
                {
                    ToolTip = 'Specifies the value of the From Code field.';
                }
                field("To Code"; Rec."To Code")
                {
                    ToolTip = 'Specifies the value of the To Code field.';
                }
            }
        }
    }
}
