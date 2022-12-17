codeunit 87092 "WanaPort Export"
{

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        WanaPort: Record "WanaPort";
        Pos: Integer;
        Object: Record AllObj;
    begin
        Rec.TestField("Parameter String");
        Pos := StrPos(Rec."Parameter String", '::');
        if Pos = 0 then begin
            Object."Object Type" := Object."Object Type"::Codeunit;
            Evaluate(Object."Object ID", Rec."Parameter String");
        end else begin
            Evaluate(Object."Object Type", CopyStr(Rec."Parameter String", 1, Pos - 1));
            Object."Object Name" := DelChr(CopyStr(Rec."Parameter String", Pos + 2), '<>', '"');
            Object.SetCurrentKey("Object Type", "Object Name");
            Object.SetRange("Object Type", Object."Object Type");
            Object.SetRange("Object Name", Object."Object Name");
            Object.FindFirst;
        end;
        WanaPort.Get(Object."Object Type", Object."Object ID");
        WanaPortMgt.Export(WanaPort);
    end;

    var
        WanaPortMgt: Codeunit "WanaPort Management";
        ExportFile: File;
        ProgressDialog: Codeunit "Progress Dialog";
        NewLine: Boolean;
        FieldSeparator: Char;
        TextDelimiter: Char;
        CR: Char;
        LF: Char;


    procedure IsEmpty(var pWanaPort: Record "WanaPort")
    var
        NothingToExportMsg: Label 'There is nothing to export for "%1".';
    begin
        if GuiAllowed then
            Message(NothingToExportMsg, pWanaPort."Object Caption");
    end;


    procedure Create(var pWanaPort: Record "WanaPort"; pCount: Integer)
    begin
        CR := 13;
        LF := 10;
        NewLine := true;
        case pWanaPort."Field Separator" of
            pWanaPort."Field Separator"::Tab:
                FieldSeparator := 9;
            pWanaPort."Field Separator"::Comma:
                FieldSeparator := ',';
            pWanaPort."Field Separator"::SemiColon:
                FieldSeparator := ';';
        end;
        case pWanaPort."Text Delimiter" of
            pWanaPort."Text Delimiter"::None:
                TextDelimiter := 0;
            pWanaPort."Text Delimiter"::Quote:
                TextDelimiter := '"';
        end;

        pWanaPort.TestField(pWanaPort."WanaPort File Name");
        ExportFile.Create(pWanaPort."Export Path" + '\' + pWanaPort."WanaPort File Name");

        ProgressDialog.OpenCopyCountMax(pWanaPort."Object Caption", pCount);
    end;


    procedure Update(var pWanaPort: Record "WanaPort")
    begin
        ProgressDialog.UpdateCopyCount();
    end;


    procedure Close(var pWanaPort: Record "WanaPort")
    var
        ltDone: Label 'File %1 available in folder %2.';
    begin
        pWanaPort."Last Export DateTime" := CurrentDateTime;
        pWanaPort.Modify;
        ExportFile.Close;

        //ProgressDialog.Close;
        if GuiAllowed then
            Message(ltDone, pWanaPort."WanaPort File Name", pWanaPort."Export Path");
    end;


    procedure ExportText(pText: Text)
    var
        i: Integer;
        c: Char;
    begin
        ExportSeparator;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);
        //pText := Tools.Ascii2Ansi(pText);
        for i := 1 to StrLen(pText) do begin
            c := pText[i];
            ExportFile.Write(c);
            if c = TextDelimiter then
                ExportFile.Write(TextDelimiter);  // Double
        end;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);
    end;


    procedure ExportDecimal(pDecimal: Decimal; pFormat: Text)
    begin
        if pFormat = '' then
            pFormat := '<Sign><Integer><Decimals,3>'; // Warning : <Decimals,3> for '.99'
        ExportText(DelChr(ConvertStr(Format(Round(pDecimal, 0.01), 0, pFormat), ',', '.'), '=', ' '));
    end;


    procedure ExportInteger(pInteger: Integer)
    begin
        ExportText(DelChr(Format(pInteger, 0, '<Sign><Integer>'), '=', ' '));
    end;


    procedure ExportBoolean(pBoolean: Boolean)
    begin
        if pBoolean then
            ExportText('1')
        else
            ExportText('0');
    end;


    procedure ExportDate(pDate: Date)
    begin
        ExportText(Format(pDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;


    procedure ExportSeparator()
    var
        c: Char;
    begin
        if NewLine then
            NewLine := false
        else
            ExportFile.Write(FieldSeparator);
    end;


    procedure ExportEndOfLine()
    var
        c: Char;
    begin
        c := 13;
        ExportFile.Write(c); // Hexa=0D CarriageReturn
        c := 10;
        ExportFile.Write(c); // Hexa=0A LineFeed
        NewLine := true;
    end;


    procedure ExportNote(var pRecordRef: RecordRef; pNote: Text)
    var
        RecordLink: Record "Record Link";
        lInStream: InStream;
        c: Char;
        t: Text[1];
    begin
        ExportSeparator;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);

        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("Record ID", Format(pRecordRef.RecordId));
        RecordLink.SetRange(Description, pNote);
        RecordLink.SetRange(Company, CompanyName);
        if RecordLink.FindFirst then begin
            RecordLink.CalcFields(Note);
            if RecordLink.Note.HasValue then begin
                RecordLink.Note.CreateInStream(lInStream);
                while not lInStream.EOS do begin
                    lInStream.Read(c);
                    t := ' ';
                    t[1] := c;
                    //??            c := Tools.Ascii2Ansi(t) [1];
                    ExportFile.Write(c);
                    if c = TextDelimiter then
                        ExportFile.Write(c);
                end;
            end;
        end;

        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);
    end;
}

