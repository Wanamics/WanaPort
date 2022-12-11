page 87091 "wanaPort Job Queue"
{

    Caption = 'WanaPort Job Queue';
    PageType = List;
    SourceTable = "Job Queue Entry";
    SourceTableView = WHERE("Recurring Job" = CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                }
                field("User ID"; rec."User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Object Type to Run"; rec."Object Type to Run")
                {
                    ApplicationArea = All;
                }
                field("Object ID to Run"; rec."Object ID to Run")
                {
                    ApplicationArea = All;
                }
                field("Object Caption to Run"; rec."Object Caption to Run")
                {
                    ApplicationArea = All;
                }
                field("Parameter String"; rec."Parameter String")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("gJobQueueLogEntry.""End Date/Time"""; gJobQueueLogEntry."End Date/Time")
                {
                    ApplicationArea = All;
                    Caption = 'Last Job';
                }
                field("Earliest Start Date/Time"; rec."Earliest Start Date/Time")
                {
                    ApplicationArea = All;
                    Caption = 'Next Job';
                }
                field(gJobQueueLogEntryStatus; gJobQueueLogEntry.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Last Status';
                    OptionCaption = 'Success,In Process,Error';
                }
                /*??
                field(Priority; rec.Priority)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                ??*/
                field("Recurring Job"; rec."Recurring Job")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No. of Minutes between Runs"; rec."No. of Minutes between Runs")
                {
                    ApplicationArea = All;
                }
                field("Run on Mondays"; rec."Run on Mondays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Tuesdays"; rec."Run on Tuesdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Wednesdays"; rec."Run on Wednesdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Thursdays"; rec."Run on Thursdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Fridays"; rec."Run on Fridays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Saturdays"; rec."Run on Saturdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Sundays"; rec."Run on Sundays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(gSchedule; gSchedule)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule';
                }
                field("Starting Time"; rec."Starting Time")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Ending Time"; rec."Ending Time")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Traitement)
            {
                Caption = 'Job &Queue';
                action(Fiche)
                {
                    ApplicationArea = All;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Job Queue Entries";
                    RunPageLink = ID = FIELD(ID);
                    ShortCutKey = 'Shift+Ctrl+C';
                }
                action("Réinitialiser statut")
                {
                    ApplicationArea = All;
                    Caption = 'Reset Status';
                    Image = ClearFilter;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        rec.LockTable;
                        rec.Get(rec.ID);
                        rec.Status := rec.Status::Ready;
                        CurrPage.Update;
                    end;
                }
                action("Mettre en attente")
                {
                    ApplicationArea = All;
                    Caption = 'Set On Hold';

                    trigger OnAction()
                    begin
                        rec.LockTable;
                        rec.Get(rec.ID);
                        rec.Status := rec.Status::"On Hold";
                        CurrPage.Update;
                    end;
                }
                action(Journal)
                {
                    ApplicationArea = All;
                    Caption = 'Log';
                    RunObject = Page "Job Queue Log Entries";
                    RunPageLink = ID = FIELD(ID);
                    ShortCutKey = 'Shift+Ctrl+N';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ltSchedule: Label 'MTWTFSS';
        ltNone: Label '-';
    begin
        gJobQueueLogEntry.SetRange(ID, rec.ID);
        if not gJobQueueLogEntry.FindLast then
            gJobQueueLogEntry.Init;
        gSchedule := ltSchedule;
        if not rec."Run on Mondays" then
            gSchedule[1] := '-';
        if not rec."Run on Tuesdays" then
            gSchedule[2] := '-';
        if not rec."Run on Wednesdays" then
            gSchedule[3] := '-';
        if not rec."Run on Thursdays" then
            gSchedule[4] := '-';
        if not rec."Run on Fridays" then
            gSchedule[5] := '-';
        if not rec."Run on Saturdays" then
            gSchedule[6] := '-';
        if not rec."Run on Sundays" then
            gSchedule[7] := '-';
        gJobQueueLogEntryStatusOnForma;
    end;

    var
        gJobQueueLogEntry: Record "Job Queue Log Entry";
        gSchedule: Text[30];

    local procedure gJobQueueLogEntryStatusOnForma()
    begin
        if gJobQueueLogEntry.Status = gJobQueueLogEntry.Status::Error then; // Red
    end;
}

