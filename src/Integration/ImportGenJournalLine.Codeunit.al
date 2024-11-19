namespace Wanamics.Wanaport;

using Microsoft.Finance.GeneralLedger.Journal;
codeunit 87095 "WanaPort GenJournalLine"
{
    TableNo = "Gen. Journal Line";
    trigger OnRun()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if Rec."Journal Batch Name" = '' then
            Rec."Journal Batch Name" := Rec.GetFilter("Journal Batch Name");
        GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        case GenJournalBatch."WanaPort Object Type" of
            GenJournalBatch."WanaPort Object Type"::Report:
                Report.RunModal(GenJournalBatch."WanaPort Object ID", true, false, Rec);
            GenJournalBatch."WanaPort Object Type"::Codeunit:
                Codeunit.Run(GenJournalBatch."WanaPort Object ID", Rec);
            GenJournalBatch."WanaPort Object Type"::XMLport:
                begin
                    Rec.SetRange("Journal Template Name", Rec."Journal Template Name");
                    Rec.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    Xmlport.Run(GenJournalBatch."WanaPort Object ID", false, true, Rec);
                end;
        end;
    end;

#if FALSE
    procedure Import(pWanaPort: Record WanaPort; var pGenJournalLine: Record "Gen. Journal Line")
    var
        iStream: InStream;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileFilterTxt: Label 'Text Files(*.txt;*.csv)|*.txt;*.csv';
        FileFilterExtensionTxt: Label 'txt, csv', Locked = true;
        JournalMustBeEmptyErr: Label 'Journal must be empty.';
    begin
        if Page.RunModal(0, pWanaPort) = Action::LookupOK then
            pWanaPort.Find('=')
        else
            exit;

        pGenJournalLine.SetRange(Amount, 0);
        pGenJournalLine.DeleteAll(true);
        pGenJournalLine.SetRange(Amount);
        if not pGenJournalLine.IsEmpty then
            Error(JournalMustBeEmptyErr);

        if FileManagement.BLOBImportWithFilter(TempBlob, '', '', FileFilterTxt, FileFilterExtensionTxt) <> '' then begin
            TempBlob.CreateInStream(iStream);
            pGenJournalLine.SetRange("Journal Template Name", pGenJournalLine."Journal Template Name");
            pGenJournalLine.SetRange("Journal Batch Name", pGenJournalLine."Journal Batch Name");
            Xmlport.Import(pWanaPort."Object ID", iStream, pGenJournalLine);
        end;
    end;
#endif
}
