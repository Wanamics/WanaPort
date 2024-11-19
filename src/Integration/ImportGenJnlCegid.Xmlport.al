namespace Wanamics.Wanaport;

using Microsoft.Finance.GeneralLedger.Journal;
xmlPort 87090 "WanaPort Import Cegid"
{
    Caption = 'Import Cegid';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    RecordSeparator = '<LF>';
    TableSeparator = '<None>';
    TextEncoding = UTF8;

    schema
    {
        textelement(Root)
        {
            tableelement(GenJournalLine; "Gen. Journal Line")
            {
                AutoSave = false;
                textelement(_Type)
                {
                }
                textelement(_PostingDate)
                {
                }
                textelement(_SourceCode)
                {
                }
                textelement(_AccountNo)
                {
                }
                textelement(_CustVendNo)
                {
                }
                textelement(_Sense)
                {
                }
                textelement(_Amount)
                {
                }
                textelement(_Description)
                {
                }
                textelement(_DocumentNo)
                {
                }
                textelement(_Dim)
                {
                }

                trigger OnAfterInitRecord()
                begin
                    Default."Line No." += 10000;
                    GenJournalLine.Copy(Default);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if not FirstLineSkipped then
                        FirstLineSkipped := true
                    else
                        if (_Type = 'G') and (_CustVendNo = '') then
                            currXMLport.Skip
                        else begin
                            if BalanceGenJnlLine."Document No." = '' then
                                BalanceGenJnlLine."Document No." := _DocumentNo
                            else
                                if _DocumentNo <> BalanceGenJnlLine."Document No." then
                                    Balance();
                            Evaluate(GenJournalLine."Posting Date", _PostingDate.PadLeft(8, '0'));
                            GenJournalLine.Validate("Posting Date");
                            GenJournalLine.Validate("Document No.", _DocumentNo);
                            if _CustVendNo <> '' then begin
                                case GenJournalTemplate.Type of
                                    "Gen. Journal Template Type"::Sales:
                                        begin
                                            if _Sense = 'D' then
                                                Default."Document Type" := GenJournalLine."Document type"::Invoice
                                            else
                                                Default."Document Type" := GenJournalLine."Document type"::"Credit Memo";
                                            GenJournalLine.Validate("Account Type", GenJournalLine."Account type"::Customer);
                                            GenJournalLine.Validate("Account No.", _CustVendNo);
                                        end;
                                    "Gen. Journal Template Type"::Purchases:
                                        begin
                                            if _Sense = 'C' then
                                                Default."Document Type" := GenJournalLine."Document type"::Invoice
                                            else
                                                Default."Document Type" := GenJournalLine."Document type"::"Credit Memo";
                                            GenJournalLine.Validate("Account Type", GenJournalLine."Account type"::Vendor);
                                            GenJournalLine.Validate("Account No.", _CustVendNo);
                                        end;
                                end
                            end else
                                if _Type = 'A1' then begin
                                    GenJournalLine.Validate("Account Type", GenJournalLine."Account type"::"G/L Account");
                                    GenJournalLine.Validate("Account No.", _Dim);
                                end;
                            GenJournalLine.Validate("Document Type", Default."Document Type");
                            GenJournalLine.Validate(Description, _Description);
                            Evaluate(GenJournalLine.Amount, _Amount);
                            GenJournalLine.Amount *= (1 + GenJournalLine."VAT %" / 100);
                            if _Sense = 'D' then
                                GenJournalLine.Validate(Amount)
                            else
                                GenJournalLine.Validate(Amount, -GenJournalLine.Amount);
                            OnBeforeInsert(GenJournalLine);
                            GenJournalLine.Insert();
                            if _Type = 'A1' then
                                if (BalanceGenJnlLine."Line No." = 0) or (Abs(GenJournalLine.Amount) > Abs(BalanceGenJnlLine.Amount)) then
                                    BalanceGenJnlLine := GenJournalLine;
                            BalanceAmount += GenJournalLine.Amount;
                        end;
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    // var
    //     GenJournalBatch: Record "Gen. Journal Batch";
    begin
        WanaPort.Get(ObjectType::XmlPort, Xmlport::"WanaPort Import Cegid");
        // GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        // WanaPort.Get(GenJournalBatch."WanaPort Object Type", GenJournalBatch."WanaPort Object ID");
        Default."Journal Template Name" := GenJournalLine.GetFilter("Journal Template Name");
        Default."Journal Batch Name" := GenJournalLine.GetFilter("Journal Batch Name");
        GenJournalTemplate.Get(Default."Journal Template Name");
        Default.Validate("Source Code", GenJournalTemplate."Source Code");
    end;

    trigger OnPostXmlPort()
    begin
        Balance();
    end;


    var
        FirstLineSkipped: Boolean;
        WanaPort: Record WanaPort;
        Default: Record "Gen. Journal Line";
        BalanceGenJnlLine: Record "Gen. Journal Line";
        BalanceAmount: Decimal;
        GenJournalTemplate: Record "Gen. Journal Template";


    local procedure Balance()
    begin
        if BalanceAmount <> 0 then begin
            BalanceGenJnlLine.Validate(Amount, BalanceGenJnlLine.Amount - BalanceAmount);
            BalanceGenJnlLine.Modify();
            BalanceAmount := 0;
        end;
        Clear(BalanceGenJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var pGenJournalLine: Record "Gen. Journal Line");
    begin
    end;
}
