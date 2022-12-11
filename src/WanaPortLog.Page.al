page 87095 "wanaPort Log"
{

    Caption = 'WanaPort Log';
    Editable = false;
    PageType = List;
    SourceTable = "wanaPort Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Object Type"; rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; rec."Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Caption"; rec."Object Caption")
                {
                    ApplicationArea = All;
                }
                field(DateTime; rec.DateTime)
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field(Position; rec.PositionCaption)
                {
                    ApplicationArea = All;
                    Caption = 'Identifier';
                }
                field(Message; rec.Message)
                {
                    ApplicationArea = All;
                }
                field("Table ID"; rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; rec."Table Caption")
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec.Show;
                end;
            }
        }
    }
}

