#if FALSE
query 87090 "wan applyToCustLedgEntries"
{
    APIGroup = 'WanaPort';
    APIPublisher = 'wanamics';
    APIVersion = 'v1.0';
    EntityName = 'applyToCustLedgerEntry';
    EntitySetName = 'applyToCustLedgerEntries';
    QueryType = API;

    elements
    {
        dataitem(detailedCustLedgEntry; "Detailed Cust. Ledg. Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Application), "Initial Document Type" = filter(Invoice | "Credit Memo"); //, "Applied Cust. Ledger Entry No." <> field(Cust. Ledger Entry No. ) //=filter('<>0');

            column(entryNo; "Entry No.")
            {
                Caption = 'entryNo', Locked = true;
            }
            column(customerNo; "Customer No.")
            {
                Caption = 'customerNo', Locked = true;
            }
            column(custLedgerEntryNo; "Cust. Ledger Entry No.")
            {
                Caption = 'custLedgerEntryNo', Locked = true;
            }
            column(appliedCustLedgerEntryNo; "Applied Cust. Ledger Entry No.")
            {
                Caption = 'appliedCustLedgerEntryNo', Locked = true;
            }
            column(amount; Amount)
            {
                Caption = 'appliedAmount', Locked = true;
            }
            dataitem(custLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Entry No." = detailedCustLedgEntry."Cust. Ledger Entry No.";
                column(postingDate; "Posting Date")
                {
                    Caption = 'postingDate', Locked = true;
                }
                column(documentType; "Document Type")
                {
                    Caption = 'documentType', Locked = true;
                }
                column(documentNo; "Document No.")
                {
                    Caption = 'documentNo', Locked = true;
                }
                column(externalDocumentNo; "External Document No.")
                {
                    Caption = 'externalDocumentNo', Locked = true;
                }
                column(open; Open)
                {
                    Caption = 'open', Locked = true;
                }
                column(remainingAmount; "Remaining Amount")
                {
                    Caption = 'remainingAmount', Locked = true;
                }
                column(closedAtDate; "Closed at Date")
                {
                    Caption = 'closedAtDate', Locked = true;
                }
            }
        }
    }
}
#endif
