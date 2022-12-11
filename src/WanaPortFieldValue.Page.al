page 87094 "wanaPort Field Value"
{

    Caption = 'WanaPort Field Value';
    PageType = List;
    SourceTable = "wanaPort Field Value";

    layout
    {
        area(content)
        {
            repeater(Control8149000)
            {
                ShowCaption = false;
                field("Object Type"; rec."Object Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Object ID"; rec."Object ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(TableNo; rec.TableNo)
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field(FieldNo; rec.FieldNo)
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; rec."Field Caption")
                {
                    ApplicationArea = All;
                }
                field("Field Type Name"; rec."Field Type Name")
                {
                    ApplicationArea = All;
                }
                field(Constant; rec.Constant)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

