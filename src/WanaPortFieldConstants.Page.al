namespace Wanamics.Wanaport;

using System.Reflection;
page 87094 "WanaPort Field Constants"
{
    Caption = 'Field Constants';
    PageType = List;
    SourceTable = "WanaPort Field Constant";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(TableNo; Rec."Table No.")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                    Width = 6;
                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Table Caption");
                    end;
                }
                field(TableName; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    Width = 20;
                }
                field(FieldNo; Rec."Field No.")
                {
                    ApplicationArea = All;
                    Width = 6;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    Width = 20;
                }
                field("Field Type Name"; Rec."Field Type Name")
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field(Constant; Rec.Constant)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

