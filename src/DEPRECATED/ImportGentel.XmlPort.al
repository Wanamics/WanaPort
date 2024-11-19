#if FALSE
namespace Wanamics.Gressier;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Customer;
using Microsoft.Bank.BankAccount;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
xmlport 50100 _ImportGentel
{
    Caption = 'Import Gentel';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;
    RecordSeparator = '<LF>';
    TableSeparator = '<None>';
    TextEncoding = UTF8;
    schema
    {
        textelement(Root)
        {
            tableelement(Rec; "Gen. Journal Line")
            {
                AutoSave = false;
                fieldelement(_LineNo; Rec."Line No.")
                {
                }
                fieldelement(_PostingDate; Rec."Posting Date")
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
                textelement(_Description)
                {
                }
                textelement(_DocumentNo)
                {
                }
                textelement(_Amount)
                {
                }
                textelement(_D_C)
                {
                }
                textelement(_DueDate)
                {
                }
                textelement(_CurrencyCode)
                {
                }
                textelement(_ShortcutDimension1Code) { }
                textelement(_ShortcutDimension2Code) { }
                trigger OnAfterInitRecord()
                begin
                    Rec.Copy(Default);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    Rec.Validate("Source Code", WanaPort.Map(Database::"Source Code", _SourceCode));
                    Rec.Validate("Document No.", _DocumentNo);
                    if (Default."Document No." <> '') and
                        ((Rec."Source Code" <> Default."Source Code") or (Rec."Document No." <> Default."Document No.")) then
                        AdjustVAT();
                    Default."Source Code" := Rec."Source Code";
                    Default."Document No." := Rec."Document No.";
                    Rec."Incoming Document Entry No." := GetIncomingDocumentEntry(Rec);
                    Default."Incoming Document Entry No." := Rec."Incoming Document Entry No.";
                    case true of
                        _CustVendNo <> '':
                            begin
                                if _SourceCode <> 'VE' then
                                    Default.Validate("Document Type", Rec."Document type"::Payment)
                                else
                                    if _D_C = 'D' then
                                        Default.Validate("Document Type", Rec."Document type"::Invoice)
                                    else
                                        Default.Validate("Document Type", Rec."Document type"::"Credit Memo");
                                Rec.Validate("Document Type", Default."Document Type");
                                Rec.Validate("Account Type", Rec."Account type"::Customer);
                                // if Customer.Get(WanaPort.Map(Database::Customer, _CustVendNo)) then
                                //     Rec.Validate("Account No.", Customer."No.")
                                // else
                                //     Customer.Init();
                                Rec."Account No." := _CustVendNo; // TODO
                                Rec.Validate("Due Date", WanaPort.ToDate(_DueDate));
                                Rec.Validate("Applies-to ID", _DocumentNo);
                                if _D_C = 'D' then
                                    Rec.Validate(Amount, WanaPort.ToDecimal(_Amount))
                                else
                                    Rec.Validate(Amount, -WanaPort.ToDecimal(_Amount));
                            end;
                        _AccountNo[1] = '4':
                            begin
                                VATAmount := WanaPort.ToDecimal(_Amount);
                                currXMLport.Skip();
                            end;
                        _AccountNo[1] = '5':
                            begin
                                Rec.Validate("Account Type", Rec."Account type"::"Bank Account");
                                Rec.Validate("Account No.", WanaPort.Map(Database::"Bank Account", _AccountNo));
                                if _D_C = 'D' then
                                    Rec.Validate(Amount, WanaPort.ToDecimal(_Amount))
                                else
                                    Rec.Validate(Amount, -WanaPort.ToDecimal(_Amount));
                            end;
                        else begin
                            Rec.Validate("Account No.", WanaPort.Map(Database::"G/L Account", _AccountNo));
                            Rec.Validate("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
                            if _D_C = 'D' then
                                Rec.Validate(Amount, WanaPort.ToDecimal(_Amount) * (1 + Rec."VAT %" / 100))
                            else
                                Rec.Validate(Amount, -WanaPort.ToDecimal(_Amount) * (1 + Rec."VAT %" / 100));
                            SumVATAmount -= Rec."VAT Amount";
                            if Abs(Rec."VAT Amount") > Abs(MaxVATGenJournalLine."VAT Amount") then
                                MaxVATGenJournalLine := Rec;
                        end;
                    end;
                    Rec.Validate(Description, _Description);
                    Rec.Insert(true);
                    Rec.Validate("Shortcut Dimension 1 Code", _ShortcutDimension1Code);
                    Rec.Validate("Shortcut Dimension 2 Code", _ShortcutDimension2Code);
                    OnAfterInsert(Rec);
                    Rec.Modify(true);
                end;
            }
        }
    }
    var
        WanaPort: Record WanaPort;
        Default: Record "Gen. Journal Line";
        Customer: Record "Customer";
        VATAmount: Decimal;
        SumVATAmount: Decimal;
        MaxVATGenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";

    trigger OnPreXmlPort()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        WanaPort.Get(ObjectType::XmlPort, Xmlport::_ImportGentel);
        Default."Journal Template Name" := Rec.GetFilter("Journal Template Name");
        Default."Journal Batch Name" := Rec.GetFilter("Journal Batch Name");
        GenJournalTemplate.Get(Default."Journal Template Name");
        Default.Validate("Source Code", GenJournalTemplate."Source Code");
        GLSetup.Get();
    end;

    trigger OnPostXmlPort()
    begin
        AdjustVAT();
    end;

    local procedure AdjustVAT();
    begin
        if (VATAmount <> SumVATAmount) and (MaxVATGenJournalLine."Line No." <> 0) and (Abs(VATAmount - SumVATAmount) <= GLSetup."Max. VAT Difference Allowed") then begin
            MaxVATGenJournalLine.Validate(Amount, MaxVATGenJournalLine.Amount + SumVATAmount - VATAmount);
            MaxVATGenJournalLine.Modify(false);
        end;
        VATAmount := 0;
        SumVATAmount := 0;
        Clear(MaxVATGenJournalLine);
    end;

    local procedure GetIncomingDocumentEntry(pRec: Record "Gen. Journal Line"): Integer
    var
        IncomingDocument: Record "Incoming Document";
    begin
        pRec.TestField("Document No.");
        IncomingDocument.SetCurrentKey("Document No.");
        IncomingDocument.SetRange("Document No.", prec."Document No.");
        if IncomingDocument.FindFirst() then begin
            IncomingDocument.TestField(Posted, false);
            exit(IncomingDocument."Entry No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsert(var pRec: Record "Gen. Journal Line")
    begin
    end;
}
#endif
