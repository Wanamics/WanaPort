namespace Wanamics.Wanaport;

using System.Threading;
page 87091 "WanaPort Job Queue"
{

    Caption = 'WanaPort Job Queue';
    PageType = List;
    SourceTable = "Job Queue Entry";
    SourceTableView = where("Recurring Job" = const(true));

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                Editable = false;
                ShowCaption = false;
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                    ApplicationArea = All;
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                    ApplicationArea = All;
                }
                field("Object Caption to Run"; Rec."Object Caption to Run")
                {
                    ApplicationArea = All;
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("gJobQueueLogEntry.""End Date/Time"""; gJobQueueLogEntry."End Date/Time")
                {
                    ApplicationArea = All;
                    Caption = 'Last Job';
                }
                field("Earliest Start Date/Time"; Rec."Earliest Start Date/Time")
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
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                ??*/
                field("Recurring Job"; Rec."Recurring Job")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = All;
                }
                field("Run on Mondays"; Rec."Run on Mondays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Tuesdays"; Rec."Run on Tuesdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Wednesdays"; Rec."Run on Wednesdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Thursdays"; Rec."Run on Thursdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Fridays"; Rec."Run on Fridays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Saturdays"; Rec."Run on Saturdays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Run on Sundays"; Rec."Run on Sundays")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(gSchedule; gSchedule)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Ending Time"; Rec."Ending Time")
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

                    trigger OnAction()
                    begin
                        Rec.LockTable;
                        Rec.Get(Rec.ID);
                        Rec.Status := Rec.Status::Ready;
                        CurrPage.Update;
                    end;
                }
                action("Mettre en attente")
                {
                    ApplicationArea = All;
                    Caption = 'Set On Hold';

                    trigger OnAction()
                    begin
                        Rec.LockTable;
                        Rec.Get(Rec.ID);
                        Rec.Status := Rec.Status::"On Hold";
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
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Réinitialiser statut_Promoted"; "Réinitialiser statut")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ltSchedule: Label 'MTWTFSS';
        ltNone: Label '-';
    begin
        gJobQueueLogEntry.SetRange(ID, Rec.ID);
        if not gJobQueueLogEntry.FindLast then
            gJobQueueLogEntry.Init;
        gSchedule := ltSchedule;
        if not Rec."Run on Mondays" then
            gSchedule[1] := '-';
        if not Rec."Run on Tuesdays" then
            gSchedule[2] := '-';
        if not Rec."Run on Wednesdays" then
            gSchedule[3] := '-';
        if not Rec."Run on Thursdays" then
            gSchedule[4] := '-';
        if not Rec."Run on Fridays" then
            gSchedule[5] := '-';
        if not Rec."Run on Saturdays" then
            gSchedule[6] := '-';
        if not Rec."Run on Sundays" then
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

