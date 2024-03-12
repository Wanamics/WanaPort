pageextension 87099 "WanaPort FA G/L Journal" extends "Fixed Asset G/L Journal"
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
