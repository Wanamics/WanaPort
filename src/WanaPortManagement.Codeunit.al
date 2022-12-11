codeunit 87090 "wanaPort Management"
{

    trigger OnRun()
    begin
    end;


    procedure FileCount(pPath: Text; pFileNameFilter: Text): Integer
    var
    //??lFile: Record File;
    begin
        /*??
        if pPath = '' then
            exit(0);
        lFile.SetRange(Path, '');
        if lFile.FindFirst then; // Required to refresh

        lFile.SetRange(Path, pPath);
        lFile.SetFilter(Name, pFileNameFilter);
        exit(lFile.Count)
        ??*/
    end;


    procedure ShowFileList(pPath: Text; pFileNameFilter: Text)
    var
    //??lFile: Record File;
    begin
        /*??
        Clear(lFile);
        lFile.SetRange(Path, '');
        if lFile.FindFirst then; // Required to refresh
        lFile.SetRange(Path, pPath);
        lFile.SetFilter(Name, pFileNameFilter);
        lFile.SetRange("Is a file", true);
        PAGE.RunModal(PAGE::"WanaPort File List", lFile);
        ??*/
    end;


    procedure GetExportFileName(var pRec: Record "wanaPort"): Text
    begin
        // %1 "Last File No. Used"
        // %2 TimeStamp yyyymmddhhmmss
        if StrPos(pRec."File Name Mask", '%1') <> 0 then
            pRec."Last File No. Used" := IncStr(pRec."Last File No. Used");
        exit(
            StrSubstNo(
            pRec."File Name Mask",
            pRec."Last File No. Used",
            Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>')));
    end;


    procedure Import(var pRec: Record "wanaPort")
    var
        //??lFile: Record File;
        lWindow: Dialog;
        lImportFile: File;
        lInStream: InStream;
        lOutStream: OutStream;
        ltConfirm: Label 'Do-you want to process "%1" for %2 files?';
        ltNoFile: Label 'No file to import for %1.';
        ltProgress: Label 'Export in progress...';
    begin
        pRec.TestField("Object Type");
        pRec.TestField("Object ID");
        pRec.TestField("Import Path");
        pRec.TestField("Archive Path");
        pRec.CalcFields("Object Caption");

        /*??
        lFile.SetRange(Path, "Import Path");
        lFile.SetRange("Is a file", true);
        lFile.SetFilter(Name, "File Name Filter");

        if not lFile.FindSet then begin
            if GuiAllowed then
                Message(ltNoFile, "Object Caption");
        end else begin

            if GuiAllowed then begin
                if not Confirm(ltConfirm, true, "Object Caption", lFile.Count) then
                    exit;
                lWindow.Open(ltProgress, "Object Caption");
            end;

            LogBegin;
            repeat
                if GuiAllowed then
                    lWindow.Update(2, lFile.Name);
                "WanaPort File Name" := lFile.Path + '\' + lFile.Name;
                Modify;
                case "Object Type" of
                    "Object Type"::Report:
                        REPORT.RunModal("Object ID", false);
                    "Object Type"::Codeunit:
                        begin
                            CODEUNIT.Run("Object ID", pRec);
                        end;
                    "Object Type"::XMLport:
                        begin
                            lImportFile.Open("WanaPort File Name");
                            lImportFile.CreateInStream(lInStream);
                            XMLPORT.Import("Object ID", lInStream);
                            lImportFile.Close;
                        end;
                end;
                FILE.Rename("WanaPort File Name", "Archive Path" + '\' + lFile.Name);
                Commit;
                Find('='); // pRec can be modified (ex : "Last Export Entry No.")
                LogProcess;
            until lFile.Next = 0;
            LogEnd;

            if GuiAllowed then
                lWindow.Close;

        end;
        ???*/

        pRec."Last Import DateTime" := CurrentDateTime;
        pRec.Modify;

    end;


    procedure Export(var pRec: Record "wanaPort")
    var
        //??lFile: Record File;
        lWindow: Dialog;
        lExportFile: File;
        lInStream: InStream;
        lOutStream: OutStream;
        ltConfirm: Label 'Do-you want to process "%1"?';
    begin
        pRec.TestField("Object Type");
        pRec.TestField("Object ID");
        pRec.TestField("Export Path");
        pRec.CalcFields("Object Caption");

        if GuiAllowed then
            if not Confirm(ltConfirm, true, pRec."Object Caption") then
                exit;

        pRec."WanaPort File Name" := GetExportFileName(pRec);

        pRec.LogBegin;
        case pRec."Object Type" of
            pRec."Object Type"::Report:
                REPORT.RunModal(pRec."Object ID", false);
            pRec."Object Type"::Codeunit:
                CODEUNIT.Run(pRec."Object ID", pRec);
            pRec."Object Type"::XMLport:
                begin
                    /*??
                    lExportFile.Create(pRec."Export Path" + '\' + pRec."WanaPort File Name");
                    lExportFile.CreateOutStream(lOutStream);
                    XMLPORT.Export(pRec."Object ID", lOutStream);
                    lExportFile.Close;
                    ??*/
                end;
        end;
        pRec.LogEnd;
    end;


    procedure Schedule(var pJobQueueEntry: Record "Job Queue Entry") Return: Text
    var
        ltSchedule: Label 'MTWTFSS';
        ltNone: Label '-';
    begin
        if not pJobQueueEntry."Recurring Job" then
            exit(Format(pJobQueueEntry."Earliest Start Date/Time"));
        Return := ltSchedule;
        if not pJobQueueEntry."Run on Mondays" then
            Return[1] := '-';
        if not pJobQueueEntry."Run on Tuesdays" then
            Return[2] := '-';
        if not pJobQueueEntry."Run on Wednesdays" then
            Return[3] := '-';
        if not pJobQueueEntry."Run on Thursdays" then
            Return[4] := '-';
        if not pJobQueueEntry."Run on Fridays" then
            Return[5] := '-';
        if not pJobQueueEntry."Run on Saturdays" then
            Return[6] := '-';
        if not pJobQueueEntry."Run on Sundays" then
            Return[7] := '-';
        if (pJobQueueEntry."Starting Time" <> 0T) or (pJobQueueEntry."Ending Time" <> 0T) then
            Return := Return + ' ' + Format(pJobQueueEntry."Starting Time", 5) + '..' + Format(pJobQueueEntry."Ending Time", 5);
    end;


    procedure FormatDuration(pStart: DateTime; pEnd: DateTime) Return: Text
    var
        ltHours: Label 'h';
        lHours: Integer;
        lMinutes: Text;
        lSeconds: Text;
        lInteger: BigInteger;
        lThousands: Text;
        ltMinutes: Label '''';
        ltSeconds: Label '"';
    begin
        lInteger := pEnd - pStart;
        lInteger := lInteger div 1000;
        if lInteger <> 0 then
            Return := Format(lInteger mod 60, 2) + ltSeconds + Return;
        lInteger := lInteger div 60;
        if lInteger <> 0 then
            Return := Format(lInteger mod 60, 2) + ltMinutes + Return;
        lInteger := lInteger div 60;
        if lInteger <> 0 then
            Return := Format(lInteger mod 60, 2) + ltHours + Return;
    end;


    procedure ShowJobQueue(var pWanaPort: Record "wanaPort")
    var
        lJobQueueEntry: Record "Job Queue Entry";
    begin
        lJobQueueEntry.SetRange("Object Type to Run", lJobQueueEntry."Object Type to Run"::Codeunit);
        lJobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"wanaPort Import", CODEUNIT::"wanaPort Export");
        lJobQueueEntry.SetRange("Parameter String", lParameterString(pWanaPort));
        if lJobQueueEntry.IsEmpty then begin
            lJobQueueEntry.Validate("Object Type to Run", lJobQueueEntry."Object Type to Run"::Codeunit);
            if pWanaPort."Import Path" <> '' then begin
                lJobQueueEntry.Validate("Object ID to Run", CODEUNIT::"wanaPort Import");
                lJobQueueEntry.Validate("Parameter String", lParameterString(pWanaPort));
                lJobQueueEntry.Insert(true);
            end else begin
                lJobQueueEntry.Validate("Object ID to Run", CODEUNIT::"wanaPort Export");
                lJobQueueEntry.Validate("Parameter String", lParameterString(pWanaPort));
                lJobQueueEntry.Insert(true);
            end;
            Commit;
        end;
        if (lJobQueueEntry.Count = 1) and lJobQueueEntry.FindFirst then
            PAGE.RunModal(PAGE::"Job Queue Entries", lJobQueueEntry)
        else
            PAGE.RunModal(0, lJobQueueEntry);
    end;


    procedure JobQueueSchedule(var pWanaPort: Record "wanaPort"): Text
    var
        lJobQueueEntry: Record "Job Queue Entry";
    begin
        lJobQueueEntry.SetRange("Object Type to Run", lJobQueueEntry."Object Type to Run"::Codeunit);
        lJobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"wanaPort Import", CODEUNIT::"wanaPort Export");
        lJobQueueEntry.SetRange("Parameter String", lParameterString(pWanaPort));
        if not lJobQueueEntry.FindFirst then
            exit('')
        else
            if lJobQueueEntry.Count = 1 then
                exit(Schedule(lJobQueueEntry))
            else
                exit('(' + Format(lJobQueueEntry.Count) + ')');
    end;


    procedure lParameterString(var pWanaPort: Record "wanaPort"): Text
    var
        ltParameterString: Label '%1::"%2"';
        lObject: Record "AllObj";
    begin
        if lObject.Get(pWanaPort."Object Type", pWanaPort."Object ID") then
            exit(StrSubstNo(ltParameterString, lObject."Object Type", lObject."Object Name"));
    end;
}

