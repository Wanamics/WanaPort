namespace Wanamics.Wanaport;

using Microsoft.Projects.Project.Journal;
using System.IO;
using System.Utilities;
pageextension 87092 "WanaPort Job Journal" extends "Job Journal"
{
    actions
    {
        addlast(processing)
        {
            action(WanaImPort)
            {
                ApplicationArea = All;
                Caption = 'Import WanaPort';
                Visible = WanaPortVisible;
                Image = Import;

                trigger OnAction()
                var
                    iStream: InStream;
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    FileFilterTxt: Label 'Text Files(*.txt;*.csv)|*.txt;*.csv';
                    FileFilterExtensionTxt: Label 'txt, csv', Locked = true;
                    JournalMustBeEmptyErr: Label 'Journal must be empty';
                begin
                    if Page.RunModal(0, WanaPort) = Action::LookupOK then
                        WanaPort.Find('=')
                    else
                        exit;

                    Rec.SetRange(Quantity, 0);
                    Rec.DeleteAll(true);
                    Rec.SetRange(Quantity);
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
        addlast(Category_Process)
        {
            actionref(WanaImPort_Promoted; WanaImPort)
            {
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
