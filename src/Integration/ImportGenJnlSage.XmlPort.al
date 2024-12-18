namespace Wanamics.WanaPort;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Customer;
using Microsoft.Bank.BankAccount;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
xmlport 87091 "WanaPort Import Sage"
{
    Caption = 'Import Sage';
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
                fieldelement(_LineNo; GenJournalLine."Line No.")
                {
                }
                fieldelement(_PostingDate; GenJournalLine."Posting Date")
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
                textelement(_ShortcutDimension1Code) { MinOccurs = Zero; }
                textelement(_ShortcutDimension2Code) { MinOccurs = Zero; }
                trigger OnAfterInitRecord()
                begin
                    GenJournalLine.Copy(Default);
                end;

                trigger OnBeforeInsertRecord()
                begin
                    GenJournalLine.Validate("Source Code", WanaPort.Map(Database::"Source Code", _SourceCode));
                    GenJournalLine.Validate("Document No.", _DocumentNo);
                    if (Default."Document No." <> '') and
                        ((GenJournalLine."Source Code" <> Default."Source Code") or (GenJournalLine."Document No." <> Default."Document No.")) then
                        AdjustVAT();
                    Default."Source Code" := GenJournalLine."Source Code";
                    Default."Document No." := GenJournalLine."Document No.";
                    // GenJournalLine."Incoming Document Entry No." := GetIncomingDocumentEntry(GenJournalLine);
                    // Default."Incoming Document Entry No." := GenJournalLine."Incoming Document Entry No.";
                    case true of
                        _CustVendNo <> '':
                            begin
                                if _SourceCode <> 'VE' then
                                    Default.Validate("Document Type", GenJournalLine."Document type"::Payment)
                                else
                                    if _D_C = 'D' then
                                        Default.Validate("Document Type", GenJournalLine."Document type"::Invoice)
                                    else
                                        Default.Validate("Document Type", GenJournalLine."Document type"::"Credit Memo");
                                GenJournalLine.Validate("Document Type", Default."Document Type");
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account type"::Customer);
                                if Customer.Get(WanaPort.Map(Database::Customer, _CustVendNo)) then
                                    GenJournalLine.Validate("Account No.", Customer."No.")
                                else
                                    Customer.Init();
                                Evaluate(GenJournalLine."Due Date", _DueDate);
                                GenJournalLine.Validate("Due Date");
                                if _D_C = 'D' then
                                    GenJournalLine.Validate(Amount, WanaPort.ToDecimal(_Amount))
                                else
                                    GenJournalLine.Validate(Amount, -WanaPort.ToDecimal(_Amount));
                            end;
                        _AccountNo[1] = '4':
                            begin
                                VATAmount := WanaPort.ToDecimal(_Amount);
                                currXMLport.Skip();
                            end;
                        _AccountNo[1] = '5':
                            begin
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account type"::"Bank Account");
                                GenJournalLine.Validate("Account No.", WanaPort.Map(Database::"Bank Account", _AccountNo));
                                if _D_C = 'D' then
                                    GenJournalLine.Validate(Amount, WanaPort.ToDecimal(_Amount))
                                else
                                    GenJournalLine.Validate(Amount, -WanaPort.ToDecimal(_Amount));
                            end;
                        else begin
                            GenJournalLine.Validate("Account No.", WanaPort.Map(Database::"G/L Account", _AccountNo));
                            GenJournalLine.Validate("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
                            if _D_C = 'D' then
                                GenJournalLine.Validate(Amount, WanaPort.ToDecimal(_Amount) * (1 + GenJournalLine."VAT %" / 100))
                            else
                                GenJournalLine.Validate(Amount, -WanaPort.ToDecimal(_Amount) * (1 + GenJournalLine."VAT %" / 100));
                            SumVATAmount -= GenJournalLine."VAT Amount";
                        end;
                    end;
                    GenJournalLine.Validate(Description, _Description);
                    OnBeforeInsert(GenJournalLine);
                    Default."Incoming Document Entry No." := GenJournalLine."Incoming Document Entry No.";
                    GenJournalLine.Insert(true);
                    if _ShortcutDimension1Code <> '' then
                        GenJournalLine.Validate("Shortcut Dimension 1 Code", _ShortcutDimension1Code);
                    if _ShortcutDimension2Code <> '' then
                        GenJournalLine.Validate("Shortcut Dimension 2 Code", _ShortcutDimension2Code);
                    GenJournalLine.Modify(true);
                    if (GenJournalLine."Gen. Posting Type" <> GenJournalLine."Gen. Posting Type"::" ") and
                       (Abs(GenJournalLine."VAT Amount") > Abs(MaxVATRec."VAT Amount")) then
                        MaxVATRec := GenJournalLine;
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    // GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // WanaPort.Get(GenJournalBatch."WanaPort Object Type", GenJournalBatch."WanaPort Object ID");
        // GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        WanaPort.Get(ObjectType::XmlPort, Xmlport::"WanaPort Import Sage");
        Default."Journal Template Name" := GenJournalLine.GetFilter("Journal Template Name");
        Default."Journal Batch Name" := GenJournalLine.GetFilter("Journal Batch Name");
        GenJournalTemplate.Get(Default."Journal Template Name");
        Default.Validate("Source Code", GenJournalTemplate."Source Code");
        GLSetup.Get();
    end;

    trigger OnPostXmlPort()
    begin
        AdjustVAT();
    end;

    var
        WanaPort: Record WanaPort;
        Default: Record "Gen. Journal Line";
        Customer: Record "Customer";
        VATAmount: Decimal;
        SumVATAmount: Decimal;
        MaxVATRec: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";

    local procedure AdjustVAT();
    begin
        if (VATAmount <> SumVATAmount) and (MaxVATRec."Line No." <> 0) and (Abs(VATAmount - SumVATAmount) <= GLSetup."Max. VAT Difference Allowed") then begin
            MaxVATRec.Validate(Amount, MaxVATRec.Amount + SumVATAmount - VATAmount);
            MaxVATRec.Modify(false);
        end;
        VATAmount := 0;
        SumVATAmount := 0;
        Clear(MaxVATRec);
    end;

    // local procedure GetIncomingDocumentEntry(pRec: Record "Gen. Journal Line"): Integer
    // var
    //     IncomingDocument: Record "Incoming Document";
    // begin
    //     pRec.TestField("Document No.");
    //     IncomingDocument.SetCurrentKey("Document No.");
    //     IncomingDocument.SetRange("Document No.", pRec."Document No.");
    //     if IncomingDocument.FindFirst() then begin
    //         IncomingDocument.TestField(Posted, false);
    //         exit(IncomingDocument."Entry No.");
    //     end;
    // end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var pRec: Record "Gen. Journal Line");
    begin
    end;
}
