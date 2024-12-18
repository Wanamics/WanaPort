namespace Wanamics.Wanaport;

using System.Threading;
page 87091 "WanaPort Job Queue"
{
    Caption = 'WanaPort Job Queue';
    PageType = List;
    SourceTable = "Job Queue Entry";
    SourceTableView = where("Recurring Job" = const(true));
    ApplicationArea = All;

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
                }
                field("User ID"; Rec."User ID")
                {
                    Visible = false;
                }
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                }
                field("Object Caption to Run"; Rec."Object Caption to Run")
                {
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    Visible = false;
                }
                field(JobQueueLogEntryEndDateTime; JobQueueLogEntry."End Date/Time")
                {
                    Caption = 'Last Job';
                }
                field("Earliest Start Date/Time"; Rec."Earliest Start Date/Time")
                {
                    Caption = 'Next Job';
                }
                field(JobQueueLogEntryStatus; JobQueueLogEntry.Status)
                {
                    Caption = 'Last Status';
                    OptionCaption = 'Success,In Process,Error';
                }
                field("Recurring Job"; Rec."Recurring Job")
                {
                    Visible = false;
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                }
                field("Run on Mondays"; Rec."Run on Mondays")
                {
                    Visible = false;
                }
                field("Run on Tuesdays"; Rec."Run on Tuesdays")
                {
                    Visible = false;
                }
                field("Run on Wednesdays"; Rec."Run on Wednesdays")
                {
                    Visible = false;
                }
                field("Run on Thursdays"; Rec."Run on Thursdays")
                {
                    Visible = false;
                }
                field("Run on Fridays"; Rec."Run on Fridays")
                {
                    Visible = false;
                }
                field("Run on Saturdays"; Rec."Run on Saturdays")
                {
                    Visible = false;
                }
                field("Run on Sundays"; Rec."Run on Sundays")
                {
                    Visible = false;
                }
                field(Schedule; Schedule)
                {
                    Caption = 'Schedule';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    Visible = true;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    Visible = true;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Process)
            {
                Caption = 'Job &Queue';
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Job Queue Entries";
                    RunPageLink = ID = FIELD(ID);
                    // ShortCutKey = 'Shift+Ctrl+C';
                }
                action(SetStatusReady)
                {
                    Caption = 'Set Status Ready';
                    Image = ClearFilter;
                    trigger OnAction()
                    begin
                        Rec.LockTable;
                        Rec.Get(Rec.ID);
                        Rec.Status := Rec.Status::Ready;
                        CurrPage.Update;
                    end;
                }
                action(SetStatusOnHold)
                {
                    Caption = 'Set On Hold';
                    trigger OnAction()
                    begin
                        Rec.LockTable;
                        Rec.Get(Rec.ID);
                        Rec.Status := Rec.Status::"On Hold";
                        CurrPage.Update;
                    end;
                }
                action(Log)
                {
                    Caption = 'Log';
                    RunObject = Page "Job Queue Log Entries";
                    RunPageLink = ID = FIELD(ID);
                    // ShortCutKey = 'Shift+Ctrl+N';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(ResetStatusPromoted; SetStatusReady)
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
        JobQueueLogEntry.SetRange(ID, Rec.ID);
        if not JobQueueLogEntry.FindLast then
            JobQueueLogEntry.Init;
        Schedule := ltSchedule;
        if not Rec."Run on Mondays" then
            Schedule[1] := '-';
        if not Rec."Run on Tuesdays" then
            Schedule[2] := '-';
        if not Rec."Run on Wednesdays" then
            Schedule[3] := '-';
        if not Rec."Run on Thursdays" then
            Schedule[4] := '-';
        if not Rec."Run on Fridays" then
            Schedule[5] := '-';
        if not Rec."Run on Saturdays" then
            Schedule[6] := '-';
        if not Rec."Run on Sundays" then
            Schedule[7] := '-';
        // JobQueueLogEntryStatusOnForma;
    end;

    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        Schedule: Text;

    // local procedure JobQueueLogEntryStatusOnForma()
    // begin
    //     if gJobQueueLogEntry.Status = gJobQueueLogEntry.Status::Error then; // Red
    // end;
}

