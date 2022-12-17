page 87094 "WanaPort Constant"
{

    Caption = 'WanaPort Constants';
    PageType = List;
    SourceTable = "WanaPort Constant";

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
                field(TableNo; Rec.TableNo)
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field(FieldNo; Rec.FieldNo)
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                }
                field("Field Type Name"; Rec."Field Type Name")
                {
                    ApplicationArea = All;
                }
                field(Constant; Rec.Constant)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

