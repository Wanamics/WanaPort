codeunit 87090 "WanaPort Management"
{
#if ONPREM
    [Scope('OnPrem')]
    procedure FileCount(pPath: Text; pFileNameFilter: Text): Integer
    var
        lFile: Record File;
    begin
        if pPath = '' then
            exit(0);
        lFile.SetRange(Path, '');
        if lFile.FindFirst then; // Required to refresh

        lFile.SetRange(Path, pPath);
        lFile.SetFilter(Name, pFileNameFilter);
        exit(lFile.Count)
    end;
#else
    procedure FileCount(pPath: Text; pFileNameFilter: Text): Integer
    begin
    end;
#endif

#if ONPREM
    [Scope('OnPrem')]
    procedure ShowFileList(pPath: Text; pFileNameFilter: Text)
    var
        lFile: Record File;
    begin
        Clear(lFile);
        lFile.SetRange(Path, '');
        if lFile.FindFirst then; // Required to refresh
        lFile.SetRange(Path, pPath);
        lFile.SetFilter(Name, pFileNameFilter);
        lFile.SetRange("Is a file", true);
        Page.RunModal(Page::"WanaPort File List", lFile);
    end;
#else
    procedure ShowFileList(pPath: Text; pFileNameFilter: Text)
    begin
    end;
#endif

    procedure GetExportFileName(var pRec: Record "WanaPort"): Text
    begin
        // %1 "Last File No. Used"
        // %2 Timestamp (yyyymmddhhmmss)
        if StrPos(pRec."Export File Name Pattern", '%1') <> 0 then
            pRec."Last File No. Used" := IncStr(pRec."Last File No. Used");
        exit(
            StrSubstNo(
            pRec."Export File Name Pattern",
            pRec."Last File No. Used",
            Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>')));
    end;

    procedure GetArchiveFileName(var pRec: Record "WanaPort") ReturnValue: Text
    var
        FileManagement: Codeunit "File Management";
    begin
        // %1 SourceFile NameWithoutExtension
        // %2 SourceFile Extension
        // %3 Timestamp (yyyymmddhhmmss)
        // %4 Date (yyyymmdd)
        if pRec."Archive File Name Pattern" = '' then
            exit(pRec."Archive Path" + '\' +
                FileManagement.GetFileName(pRec."WanaPort File Name"))
        else
            exit(pRec."Archive Path" + '\' +
                StrSubstNo(
                    pRec."Archive File Name Pattern",
                    FileManagement.GetFileNameWithoutExtension(pRec."WanaPort File Name"),
                    FileManagement.GetExtension(pRec."WanaPort File Name"),
                    Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'),
                    Format(Today, 0, '<Year4><Month,2><Day,2>')));
    end;

#if ONPREM
    [Scope('OnPrem')]
    procedure Import(var pRec: Record "WanaPort")
    var
        lFile: Record File;
        lWindow: Dialog;
        lImportFile: File;
        lInStream: InStream;
        lOutStream: OutStream;
        ConfirmLbl: Label 'Do-you want to process "%1" for %2 files?';
        NoFileLbl: Label 'No file to import for %1.';
        ProgressLbl: Label 'Import "@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@" in progress :\  @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
    begin
        pRec.TestField("Object Type");
        pRec.TestField("Object ID");
        pRec.TestField("Import Path");
        pRec.TestField("Archive Path");
        pRec.CalcFields("Object Caption");

        lFile.SetRange(Path, pRec."Import Path");
        lFile.SetRange("Is a file", true);
        lFile.SetFilter(Name, pRec."File Name Filter");

        if not lFile.FindSet then begin
            if GuiAllowed then
                Message(NoFileLbl, pRec."Object Caption");
        end else begin

            if GuiAllowed then begin
                if not Confirm(ConfirmLbl, true, pRec."Object Caption", lFile.Count) then
                    exit;
                lWindow.Open(ProgressLbl, pRec."Object Caption");
            end;

            pRec.LogBegin;
            repeat
                if GuiAllowed then
                    lWindow.Update(2, lFile.Name);
                pRec."WanaPort File Name" := lFile.Path + '\' + lFile.Name;
                pRec.Modify();
                case pRec."Object Type" of
                    pRec."Object Type"::Report:
                        Report.RunModal(pRec."Object ID", false);
                    pRec."Object Type"::Codeunit:
                        Codeunit.Run(pRec."Object ID", pRec);
                    pRec."Object Type"::XMLport:
                        begin
                            lImportFile.Open(pRec."WanaPort File Name");
                            lImportFile.CreateInStream(lInStream);
                            XMLport.Import(pRec."Object ID", lInStream);
                            lImportFile.Close;
                        end;
                end;
                File.Rename(pRec."WanaPort File Name", GetArchiveFileName(pRec));
                Commit;
                pRec.Find('='); // pRec can be modified (ex : "Last Export Entry No.")
                pRec.LogProcess;
            until lFile.Next = 0;
            pRec.LogEnd;

            if GuiAllowed then
                lWindow.Close;
        end;

        pRec."Last Import DateTime" := CurrentDateTime;
        pRec.Modify;
    end;
#else
    procedure Import(var pRec: Record "WanaPort")
    begin
    end;
#endif
#if ONPREM
    [Scope('OnPrem')]
    procedure Export(var pRec: Record "WanaPort")
    var
        lWindow: Dialog;
        lExportFile: File;
        lInStream: InStream;
        lOutStream: OutStream;
        ConfirmLbl: Label 'Do-you want to process "%1"?';
    begin
        pRec.TestField("Object Type");
        pRec.TestField("Object ID");
        pRec.TestField("Export Path");
        pRec.CalcFields("Object Caption");

        if GuiAllowed then
            if not Confirm(ConfirmLbl, true, pRec."Object Caption") then
                exit;

        pRec."WanaPort File Name" := GetExportFileName(pRec);

        pRec.LogBegin;
        case pRec."Object Type" of
            pRec."Object Type"::Report:
                Report.RunModal(pRec."Object ID", false);
            pRec."Object Type"::Codeunit:
                Codeunit.Run(pRec."Object ID", pRec);
            pRec."Object Type"::XmlPort:
                begin
                    lExportFile.Create(pRec."Export Path" + '\' + pRec."WanaPort File Name");
                    lExportFile.CreateOutStream(lOutStream);
                    Xmlport.Export(pRec."Object ID", lOutStream);
                    lExportFile.Close;
                end;
        end;
        pRec.LogEnd;
    end;
#else
    procedure Export(var pRec: Record "WanaPort")
    begin
    end;
#endif

    procedure Schedule(var pJobQueueEntry: Record "Job Queue Entry") Return: Text
    var
        ScheduleLbl: Label 'MTWTFSS';
        NoneLbl: Label '-';
    begin
        if not pJobQueueEntry."Recurring Job" then
            exit(Format(pJobQueueEntry."Earliest Start Date/Time"));
        Return := ScheduleLbl;
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
        HoursLbl: Label 'h';
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
            Return := Format(lInteger mod 60, 2) + HoursLbl + Return;
    end;

    procedure ShowJobQueue(var pWanaPort: Record "WanaPort")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"WanaPort Import", CODEUNIT::"WanaPort Export");
        JobQueueEntry.SetRange("Parameter String", ParameterString(pWanaPort));
        if JobQueueEntry.IsEmpty then begin
            JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            if pWanaPort."Import Path" <> '' then begin
                JobQueueEntry.Validate("Object ID to Run", CODEUNIT::"WanaPort Import");
                JobQueueEntry.Validate("Parameter String", ParameterString(pWanaPort));
                JobQueueEntry.Insert(true);
            end else begin
                JobQueueEntry.Validate("Object ID to Run", CODEUNIT::"WanaPort Export");
                JobQueueEntry.Validate("Parameter String", ParameterString(pWanaPort));
                JobQueueEntry.Insert(true);
            end;
            Commit;
        end;
        if (JobQueueEntry.Count = 1) and JobQueueEntry.FindFirst then
            PAGE.RunModal(PAGE::"Job Queue Entries", JobQueueEntry)
        else
            PAGE.RunModal(0, JobQueueEntry);
    end;

    procedure JobQueueSchedule(var pWanaPort: Record "WanaPort"): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"WanaPort Import", CODEUNIT::"WanaPort Export");
        JobQueueEntry.SetRange("Parameter String", ParameterString(pWanaPort));
        if not JobQueueEntry.FindFirst then
            exit('')
        else
            if JobQueueEntry.Count = 1 then
                exit(Schedule(JobQueueEntry))
            else
                exit('(' + Format(JobQueueEntry.Count) + ')');
    end;

    local procedure ParameterString(var pWanaPort: Record "WanaPort"): Text
    var
        ParameterStringLbl: Label '%1::"%2"', Locked = true;
        Object: Record "AllObj";
    begin
        if Object.Get(pWanaPort."Object Type", pWanaPort."Object ID") then
            exit(StrSubstNo(ParameterStringLbl, Object."Object Type", Object."Object Name"));
    end;

#if ONPREM
    [Scope('OnPrem')]
    procedure ServerDirectoryExists(pPath: Text): Boolean
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.ServerDirectoryExists(pPath))
    end;
#else
    procedure ServerDirectoryExists(pPath: Text): Boolean
    begin
    end;
#endif
}

