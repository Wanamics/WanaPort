codeunit 87091 "WanaPort Import"
{

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        WanaPort: Record WanaPort;
        AllObj: Record AllObj;
        Pos: Integer;
    begin
        Rec.TestField("Parameter String");
        Pos := StrPos(Rec."Parameter String", '::');
        if Pos = 0 then begin
            AllObj."Object Type" := AllObj."Object Type"::Codeunit;
            Evaluate(AllObj."Object ID", Rec."Parameter String");
        end else begin
            Evaluate(AllObj."Object Type", CopyStr(Rec."Parameter String", 1, Pos - 1));
            AllObj."Object Name" := DelChr(CopyStr(Rec."Parameter String", Pos + 2), '<>', '"');
            AllObj.SetCurrentKey("Object Type", "Object Name");
            AllObj.SetRange("Object Type", AllObj."Object Type");
            AllObj.SetRange("Object Name", AllObj."Object Name");
            AllObj.FindFirst;
        end;
        WanaPort.Get(AllObj."Object Type", AllObj."Object ID");
        WanaPortMgt.Import(WanaPort);
    end;

    var
        gInStream: InStream;
        gFile: File;
        CR: Char;
        LF: Char;
        TAB: Char;
        WanaPortMgt: Codeunit "WanaPort Management";
        gDecimalPoint: Text[1];


    procedure FieldValue(var pMoniport: Record "WanaPort"; pTableID: Integer; pFieldID: Integer): Text
    var
        MoniportFieldValue: Record "WanaPort Field Constant";
    begin
        MoniportFieldValue.Get(pMoniport."Object Type", pMoniport."Object ID", pTableID, pFieldID);
        exit(MoniportFieldValue.Constant);
    end;

    procedure InitFieldValue(var pWanaPort: Record "WanaPort"; pTableID: Integer; var pRecordRef: RecordRef)
    var
        WanaPortFieldValue: Record "WanaPort Field Constant";
        FldRef: FieldRef;
        TableField: Record "Field";
        lInteger: Integer;
        lText: Text;
        lCode: Code[20];
        lDecimal: Decimal;
        lOption: Option;
        lBoolean: Boolean;
        lDate: Date;
        lTime: Time;
        lDateTime: DateTime;
    begin
        WanaPortFieldValue.SetRange("Object Type", pWanaPort."Object Type");
        WanaPortFieldValue.SetRange("Object ID", pWanaPort."Object ID");
        WanaPortFieldValue.SetRange("Table No.", pRecordRef.Number);
        if WanaPortFieldValue.FindSet then
            repeat
                FldRef := pRecordRef.Field(WanaPortFieldValue."Field No.");
                case Format(FldRef.Type) of
                    'Integer':
                        if Evaluate(lInteger, WanaPortFieldValue.Constant) then
                            FldRef.Value := lInteger;
                    'Text':
                        if Evaluate(lText, WanaPortFieldValue.Constant) then
                            FldRef.Value := lText;
                    'Code':
                        if Evaluate(lCode, WanaPortFieldValue.Constant) then
                            FldRef.Value := lCode;
                    'Decimal':
                        if Evaluate(lDecimal, WanaPortFieldValue.Constant) then
                            FldRef.Value := lDecimal;
                    'Option':
                        if Evaluate(lOption, WanaPortFieldValue.Constant) then
                            FldRef.Value := lOption;
                    'Boolean':
                        if Evaluate(lBoolean, WanaPortFieldValue.Constant) then
                            FldRef.Value := lBoolean;
                    'Date':
                        if Evaluate(lDate, WanaPortFieldValue.Constant) then
                            FldRef.Value := lDate;
                    'Time':
                        if Evaluate(lTime, WanaPortFieldValue.Constant) then
                            FldRef.Value := lTime;
                    'DateTime':
                        if Evaluate(lDateTime, WanaPortFieldValue.Constant) then
                            FldRef.Value := lDateTime;
                end;
            until WanaPortFieldValue.Next = 0;
    end;


#if ONPREM
    [Scope('OnPrem')]
    procedure Open(var pWanaPort: Record "WanaPort")
    begin
        TAB := 9;
        CR := 13;
        LF := 10;
        GetDecimalPoint;

        pWanaPort.TestField("WanaPort File Name");
        gFile.Open(pWanaPort."WanaPort File Name");
        gFile.CreateInStream(gInStream);
    end;
#endif


    procedure EOS(): Boolean
    begin
        exit(gInStream.EOS);
    end;


    procedure Skip()
    var
        c: Char;
    begin
        repeat
            gInStream.Read(c);
        until gInStream.EOS or (c in [CR, LF]);
        if c = CR then
            gInStream.Read(c); // LF
    end;

    local procedure GetNext() Return: Text
    var
        c: Char;
        t: Text[1];
    begin
        while not (gInStream.EOS or (c in [CR, LF, TAB])) do begin
            gInStream.Read(c);
            t[1] := c;
            if not (c in [CR, LF, TAB]) then
                Return := Return + t;
        end;
        if c = CR then
            gInStream.Read(c); // LF
    end;


    procedure GetText(var pText: Text)
    begin
        pText := CopyStr(GetNext, 1, MaxStrLen(pText));
    end;


    procedure GetCode(var pCode: Code[10])
    begin
        pCode := CopyStr(GetNext, 1, MaxStrLen(pCode));
    end;


    procedure GetDate(var pDate: Date)
    begin
        Evaluate(pDate, GetNext);
    end;


    procedure GetInteger(var pInteger: Integer)
    var
        lText: Text;
    begin
        lText := GetNext;
        if lText = '' then
            pInteger := 0
        else
            Evaluate(pInteger, lText);
    end;

    procedure GetDecimal(var pDecimal: Decimal)
    var
        lText: Text;
    begin
        lText := GetNext;
        if lText = '' then
            pDecimal := 0
        else
            if gDecimalPoint = '.' then
                Evaluate(pDecimal, ConvertStr(DelChr(Format(lText), '=', ' '), ',', '.'))
            else
                Evaluate(pDecimal, ConvertStr(DelChr(Format(lText), '=', ' '), '.', ','));
    end;


    procedure GetDecimalPoint(): Char
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        if StrPos(Format(GLSetup."Amount Rounding Precision"), ',') <> 0 then
            gDecimalPoint := ','
        else
            gDecimalPoint := '.';
    end;
}