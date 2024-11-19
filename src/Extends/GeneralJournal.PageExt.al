namespace Wanamics.Wanaport;

using Microsoft.Finance.GeneralLedger.Journal;
pageextension 87090 "WanaPort General Journal" extends "General Journal"
{
    actions
    {
        addlast(processing)
        {
            action(WanaPort)
            {
                ApplicationArea = All;
                Caption = 'WanaPort';
                Visible = WanaPortVisible;
                Image = Import;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"WanaPort GenJournalLine", Rec);
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
        addlast(Category_Process)
        {
            actionref(WanImport_Promoted; WanaPort) { }
        }
    }
    var
        WanaPortVisible: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
            WanaPortVisible := GenJournalBatch."WanaPort Object ID" <> 0;
    end;
}
