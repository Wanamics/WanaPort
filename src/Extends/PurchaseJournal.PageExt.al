pageextension 87094 "WanaPort Purchase Journal" extends "Purchase Journal"
{
    actions
    {
        addlast(processing)
        {
            action(WanaPort)
            {
                ApplicationArea = All;
                Caption = 'Import WanaPort';
                Visible = WanaPortVisible;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    iStream: InStream;
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileFilterTxt: Label 'Text Files(*.txt;*.csv)|*.txt;*.csv';
                    FileFilterExtensionTxt: Label 'txt, csv', Locked = true;
                    JournalMustBeEmptyErr: Label 'Journal must be empty.';
                begin
                    if Page.RunModal(0, WanaPort) = Action::LookupOK then
                        WanaPort.Find('=')
                    else
                        exit;

                    Rec.SetRange(Amount, 0);
                    Rec.DeleteAll(true);
                    Rec.SetRange(Amount);
                    if not Rec.IsEmpty then
                        Error(JournalMustBeEmptyErr);

                    if FileManagement.BLOBImportWithFilter(TempBlob, '', '', FileFilterTxt, FileFilterExtensionTxt) <> '' then begin
                        TempBlob.CreateInStream(iStream);
                        Rec.SetRange("Journal Template Name", Rec."Journal Template Name");
                        Rec.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                        Xmlport.Import(WanaPort."Object ID", iStream, Rec);
                        CurrPage.Update();
                    end;
                end;
            }
        }
        addlast("F&unctions")
        {
            action(wanaPortExcelExport)
            {
                ApplicationArea = All;
                Caption = 'Excel Export';
                Image = ExportToExcel;
                trigger OnAction()
                var
                    GenJournalLineExcel: codeunit "wanaPort Gen. Journal Excel";
                begin
                    GenJournalLineExcel.Export(Rec);
                end;
            }
            action(wanaPortExcelImport)
            {
                ApplicationArea = All;
                Caption = 'Excel Import';
                Image = ImportExcel;
                trigger OnAction()
                var
                    GenJournalLineExcel: codeunit "wanaPort Gen. Journal Excel";
                begin
                    GenJournalLineExcel.Import(Rec);
                end;
            }
        }
    }
    var
        WanaPort: Record WanaPort;
        WanaPortVisible: Boolean;

    trigger OnOpenPage()
    var
        PageID: Integer;
    begin
        Evaluate(PageID, CurrPage.ObjectId(false).Substring(6));
        WanaPort.SetRange("Page ID", PageID);
        WanaPortVisible := not WanaPort.IsEmpty;
    end;
}
