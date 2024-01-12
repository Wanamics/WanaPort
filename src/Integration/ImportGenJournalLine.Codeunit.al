codeunit 87095 "WanaPort GenJournalLine"
{
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
}
