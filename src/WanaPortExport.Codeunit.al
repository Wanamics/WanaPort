codeunit 87092 "wanaPort Export"
{

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        lWanaPort: Record "wanaPort";
        lPos: Integer;
        lObject: Record "AllObj";
    begin
        rec.TestField("Parameter String");
        lPos := StrPos(rec."Parameter String", '::');
        if lPos = 0 then begin
            lObject."Object Type" := lObject."Object Type"::Codeunit;
            Evaluate(lObject."Object ID", rec."Parameter String");
        end else begin
            Evaluate(lObject."Object Type", CopyStr(rec."Parameter String", 1, lPos - 1));
            lObject."Object Name" := DelChr(CopyStr(rec."Parameter String", lPos + 2), '<>', '"');
            lObject.SetCurrentKey("Object Type", "Object Name");
            lObject.SetRange("Object Type", lObject."Object Type");
            lObject.SetRange("Object Name", lObject."Object Name");
            lObject.FindFirst;
        end;
        lWanaPort.Get(lObject."Object Type", lObject."Object ID");
        WanaPortMgt.Export(lWanaPort);
    end;

    var
        WanaPortMgt: Codeunit "wanaPort Management";
        ExportFile: File;
        ProgressDialog: Codeunit "Progress Dialog";
        NewLine: Boolean;
        FieldSeparator: Char;
        TextDelimiter: Char;
        CR: Char;
        LF: Char;


    procedure IsEmpty(var pWanaPort: Record "wanaPort")
    var
        ltNothingToExport: Label 'There is nothing to export for "%1".';
    begin
        if GuiAllowed then
            Message(ltNothingToExport, pWanaPort."Object Caption");
    end;


    procedure Create(var pWanaPort: Record "wanaPort"; pCount: Integer)
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
        //??    ExportFile.Create("Export Path" + '\' + "WanaPort File Name");

        ProgressDialog.OpenCopyCountMax(pWanaPort."Object Caption", pCount);
    end;


    procedure Update(var pWanaPort: Record "wanaPort")
    begin
        ProgressDialog.UpdateCopyCount();
    end;


    procedure Close(var pWanaPort: Record "wanaPort")
    var
        ltDone: Label 'File %1 available in folder %2.';
    begin
        pWanaPort."Last Export DateTime" := CurrentDateTime;
        pWanaPort.Modify;
        //??ExportFile.Close;

        //??ProgressDialog.Close;
        if GuiAllowed then
            Message(ltDone, pWanaPort."WanaPort File Name", pWanaPort."Export Path");
    end;


    procedure ExportText(pText: Text)
    var
        i: Integer;
        c: Char;
    begin
        /*??
        ExportSeparator;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);
        //??pText := Tools.Ascii2Ansi(pText);
        for i := 1 to StrLen(pText) do begin
            c := pText[i];
            ExportFile.Write(c);
            if c = TextDelimiter then
                ExportFile.Write(TextDelimiter);  // Double
        end;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);
        ??*/
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
        /*??
        if NewLine then
            NewLine := false
        else
            ExportFile.Write(FieldSeparator);
        ??*/
    end;


    procedure ExportEndOfLine()
    var
        c: Char;
    begin
        /*??
        c := 13;
        ExportFile.Write(c); // Hexa=0D CarriageReturn
        c := 10;
        ExportFile.Write(c); // Hexa=0A LineFeed
        NewLine := true;
        ??*/
    end;


    procedure ExportNote(var pRecordRef: RecordRef; pNote: Text)
    var
        lRecordLink: Record "Record Link";
        lInStream: InStream;
        c: Char;
        t: Text[1];
    begin
        /*??
        ExportSeparator;
        if TextDelimiter <> 0 then
            ExportFile.Write(TextDelimiter);

        lRecordLink.SetRange(Type, lRecordLink.Type::Note);
        lRecordLink.SetFilter("Record ID", Format(pRecordRef.RecordId));
        lRecordLink.SetRange(Description, pNote);
        lRecordLink.SetRange(Company, CompanyName);
        if lRecordLink.FindFirst then begin
            lRecordLink.CalcFields(Note);
            if lRecordLink.Note.HasValue then begin
                lRecordLink.Note.CreateInStream(lInStream);
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
        ??*/
    end;
}

