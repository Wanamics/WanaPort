#if FALSE
pageextension 87096 "wanaPort Pmt Rec. Journals" extends "Pmt. Reconciliation Journals"
{
    actions
    {
        addafter(ImportBankTransactionsToNew)
        {
            action(WanaPort)
            {
                ApplicationArea = All;
                Caption = 'Import WanaPort';
                Visible = WanaPortVisible;
                Image = Import;

                trigger OnAction()
                begin
                    if Page.RunModal(0, WanaPort) = Action::LookupOK then
                        WanaPort.Find('=')
                    else
                        exit;

                    Xmlport.Run(WanaPort."Object ID");
                    CurrPage.Update();
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(WanaPort_Promoted; WanaPort) { }
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
#endif