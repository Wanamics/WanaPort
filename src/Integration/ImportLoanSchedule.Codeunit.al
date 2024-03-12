codeunit 87098 "WanaPort Loan Schedule"
{
    TableNo = "Gen. Journal Line";
    trigger OnRun()
    var
        MustBeEmptyErr: Label 'Journal must be empty';
    begin
        Rec.Reset();
        Rec.SetRange("Journal Template Name", Rec."Journal Template Name");
        Rec.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        Rec.SetRange(Amount, 0);
        Rec.DeleteAll(true);
        Rec.SetRange(Amount);
        if not Rec.IsEmpty() then
            Error(MustBeEmptyErr);
        GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        GenJournalBatch.TestField("Bal. Account No.");
        GenJournalBatch.TestField("No. Series");
        Import();
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
        GenJournalBatch: Record "Gen. Journal Batch";
        ExcelBuffer: Record "Excel Buffer" temporary;
        Default: Record "Gen. Journal Line";
        Balance: Record "Gen. Journal Line";

    procedure Import()
    var
        IStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('', '', '', FileName, IStream) then begin
            ExcelBuffer.OpenBookStream(IStream, ExcelBuffer.SelectSheetsNameStream(IStream));
            ExcelBuffer.ReadSheet();
            Process();
        end;
    end;

    local procedure Process()
    var
        Progress: Codeunit "WanaPort Progress";
        Next: Integer;
        GLAccounts: Dictionary of [Integer, Code[20]];
        Helper: Codeunit "WanaPort Helper";
        xExcelBuffer: Record "Excel Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Initialize();
        if ExcelBuffer.FindLast() then;
        Progress.Open('', ExcelBuffer."Row No.");
        ExcelBuffer.SetFilter("Column No.", Select(GLAccounts));
        ExcelBuffer.SetFilter("Row No.", '>1');
        if ExcelBuffer.FindSet then
            repeat
                Progress.Update();
                Default.Validate("Posting Date", Helper.ToDate(ExcelBuffer."Cell Value as Text"));
                Default."Document No." := IncStr(Default."Document No.");
                Balance."Posting Date" := Default."Posting Date";
                Balance."Document No." := Default."Document No.";
                Balance.Amount := 0;
                xExcelBuffer := ExcelBuffer;
                if ExcelBuffer.Next() <> 0 then
                    repeat
                        GenJournalLine := Default;
                        GenJournalLine.Validate("Account No.", GLAccounts.Get(ExcelBuffer."Column No."));
                        GenJournalLine.Validate(Amount, Helper.ToDecimal(ExcelBuffer."Cell Value as Text"));
                        InsertLine(GenJournalLine);
                        Balance.Amount -= GenJournalLine.Amount;
                        Next := ExcelBuffer.Next();
                    until (Next = 0) or (ExcelBuffer."Row No." <> xExcelBuffer."Row No.");
                Balance.Validate(Amount);
                InsertLine(Balance);
            until Next = 0;
        Progress.Done('');
    end;

    local procedure Initialize()
    begin
        SetDefault(Default);
        Balance := Default;
        Balance.Validate("Account Type", GenJournalBatch."Bal. Account Type");
        Balance.Validate("Account No.", GenJournalBatch."Bal. Account No.");
    end;

    local procedure SetDefault(var pRec: Record "Gen. Journal Line")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        pRec."Journal Template Name" := GenJournalBatch."Journal Template Name";
        pRec."Journal Batch Name" := GenJournalBatch.Name;
        GenJournalTemplate.Get(GenJournalBatch."Journal Template Name");
        pRec."Source Code" := GenJournalTemplate."Source Code";
        pRec."Reason Code" := GenJournalBatch."Reason Code";
        pRec."Posting No. Series" := GenJournalBatch."Posting No. Series";
        // pRec."Copy VAT Setup to Jnl. Lines" := GenJournalBatch."Copy VAT Setup to Jnl. Lines";
        pRec."Document No." := NoSeriesManagement.TryGetNextNo(GenJournalBatch."No. Series", 0D) + '.000';
        pRec.Description := GenJournalBatch.Description;
    end;

    local procedure Select(var pGLAccounts: Dictionary of [Integer, Code[20]]) ReturnValue: Text;
    begin
        ReturnValue := '1';
        ExcelBuffer.SetRange("Row No.", 1);
        ExcelBuffer.SetFilter("Column No.", '> 1');
        if ExcelBuffer.FindSet() then
            repeat
                pGLAccounts.Add(ExcelBuffer."Column No.", ExcelBuffer."Cell Value as Text");
                ReturnValue += '|' + format(ExcelBuffer."Column No.");
            until ExcelBuffer.Next() = 0;
    end;

    local procedure InsertLine(var pRec: Record "Gen. Journal Line")
    begin
        if pRec.Amount = 0 then
            exit;
        Default."Line No." += 10000;
        pRec."Line No." := Default."Line No.";
        pRec.Description := Default.Description;
        pRec.Insert(true);
        AfterInsert(pRec);
    end;

    local procedure AfterInsert(var pRec: Record "Gen. Journal Line")
    var
        i: Integer;
    begin
        pRec.Validate("Shortcut Dimension 1 Code", ShortcutDimCode[1]);
        pRec.Validate("Shortcut Dimension 2 Code", ShortcutDimCode[2]);
        for i := 3 to 8 do
            if ShortcutDimCode[i] <> '' then
                pRec.ValidateShortcutDimCode(i, ShortcutDimCode[i]);
        pRec.Modify(true);
    end;
}
