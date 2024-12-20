namespace Wanamics.Wanaport;

using System.Reflection;
page 87096 "WanaPort Field Value Map"
{
    ApplicationArea = All;
    Caption = 'Field Value Map';
    PageType = List;
    SourceTable = "WanaPort Field Value Map";

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
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.';
                }
                field("Target Code"; Rec."Target Code")
                {
                    ToolTip = 'Specifies the value of the Target Code field.';
                }
            }
        }
    }
}
