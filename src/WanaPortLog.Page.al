namespace Wanamics.Wanaport;
page 87095 "WanaPort Log"
{

    Caption = 'WanaPort Log';
    Editable = false;
    PageType = List;
    SourceTable = "WanaPort Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                }
                field(DateTime; Rec.DateTime)
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field(Position; Rec.PositionCaption)
                {
                    ApplicationArea = All;
                    Caption = 'Identifier';
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(View)
            {
                ApplicationArea = All;
                Caption = 'Show';
                Image = View;

                trigger OnAction()
                begin
                    Rec.Show;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(View_Promoted; View)
                {
                }
            }
        }
    }
}

