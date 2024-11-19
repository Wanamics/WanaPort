namespace Wanamics.Wanaport;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Reflection;
xmlport 87092 "WanaPort Import FEC"
{
    Caption = 'Import FEC Formated Text';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = ';';
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
                textelement(_JournalCode)
                {
                }
                textelement(_JournalLib)
                {
                }
                textelement(_EcritureDate)
                {
                }
                textelement(_CompteNum)
                {
                }
                textelement(_CompteLib)
                {
                }
                textelement(_Debit)
                {
                }
                textelement(_Credit)
                {
                }
                trigger OnAfterInitRecord()
                begin
                    Default."Line No." += 10000;
                    GenJournalLine.Copy(Default);
                end;

                trigger OnBeforeInsertRecord()
                var
                    GLAccount: Record "G/L Account";
                begin
                    if not FirstLineSkipped then
                        FirstLineSkipped := true
                    else begin
                        GenJournalLine.Validate("Posting Date", WanaPort.ToDate(_EcritureDate, 'dd/MM/yyyy'));
                        if GLAccount.Get(WanaPort.Map(Database::"G/L Account", _CompteNum)) then begin
                            GenJournalLine.Validate("Account No.", GLAccount."No.");
                            GenJournalLine.Validate(Description, _CompteLib);
                        end else
                            GenJournalLine.Validate(Description, _CompteNum + ':' + _CompteLib);
                        if _Debit <> '' then
                            GenJournalLine.Validate("Debit Amount", WanaPort.ToDecimal(_Debit));
                        if _Credit <> '' then
                            GenJournalLine.Validate("Credit Amount", WanaPort.ToDecimal(_Credit));
                        OnBeforeInsert(GenJournalLine);
                        GenJournalLine.Insert(true);
                    end;
                end;
            }
        }
    }
    var
        FirstLineSkipped: Boolean;
        WanaPort: Record WanaPort;
        Default: Record "Gen. Journal Line";
        TypeHelper: Codeunit "Type Helper";

    trigger OnPreXmlPort()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        WanaPort.Get(ObjectType::XmlPort, Xmlport::"WanaPort Import FEC");
        // GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        // WanaPort.Get(GenJournalBatch."WanaPort Object Type", GenJournalBatch."WanaPort Object ID");
        Default."Journal Template Name" := GenJournalLine.GetFilter("Journal Template Name");
        Default."Journal Batch Name" := GenJournalLine.GetFilter("Journal Batch Name");
        GenJournalTemplate.Get(Default."Journal Template Name");
        Default.Validate("Source Code", GenJournalTemplate."Source Code");

        GenJournalBatch.Get(Default."Journal Template Name", Default."Journal Batch Name");
        GenJournalBatch.TestField("Copy VAT Setup to Jnl. Lines", false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var pGenJournalLine: Record "Gen. Journal Line");
    begin
    end;
}
