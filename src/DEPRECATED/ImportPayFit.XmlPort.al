#if FALSE
namespace Wanamics.Gressier;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Reflection;
xmlport 50101 _ImportPayFit
{
    Caption = 'Import PayFit';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = ';';
    Format = VariableText;
    RecordSeparator = '<LF>';
    TableSeparator = '<None>';
    TextEncoding = UTF8;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Rec; "Gen. Journal Line")
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
                    Rec.Copy(Default);
                end;

                trigger OnBeforeInsertRecord()
                var
                    GLAccount: Record "G/L Account";
                begin
                    if not FirstLineSkipped then
                        FirstLineSkipped := true
                    else begin
                        Rec.Validate("Posting Date", WanaPort.ToDate(_EcritureDate, 'dd/MM/yyyy'));
                        if GLAccount.Get(WanaPort.Map(Database::"G/L Account", _CompteNum)) then begin
                            Rec.Validate("Account No.", GLAccount."No.");
                            Rec.Validate(Description, _CompteLib);
                        end else
                            Rec.Validate(Description, _CompteNum + ':' + _CompteLib);
                        if _Debit <> '' then
                            Rec.Validate("Debit Amount", WanaPort.ToDecimal(_Debit));
                        if _Credit <> '' then
                            Rec.Validate("Credit Amount", WanaPort.ToDecimal(_Credit));
                        Rec.Insert(true);
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
    //NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        WanaPort.Get(ObjectType::XmlPort, Xmlport::_ImportPayFit);
        Default."Journal Template Name" := Rec.GetFilter("Journal Template Name");
        Default."Journal Batch Name" := Rec.GetFilter("Journal Batch Name");
        GenJournalTemplate.Get(Default."Journal Template Name");
        Default.Validate("Source Code", GenJournalTemplate."Source Code");

        GenJournalBatch.Get(Default."Journal Template Name", Default."Journal Batch Name");
        GenJournalBatch.TestField("Copy VAT Setup to Jnl. Lines", false);
        //?? Default."Document No." := NoSeriesMgt.TryGetNextNo(GenJournalBatch."No. Series", WorkDate);
    end;
}
#endif
