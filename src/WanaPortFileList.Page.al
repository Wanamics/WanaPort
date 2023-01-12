page 87093 "WanaPort File List"
{
    Caption = 'Files';
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
#if ONPREM
    SourceTable = File;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field(Size; Rec.Size)
                {
                    ApplicationArea = All;
                    Caption = 'Size';
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }
                field(Time; Rec.Time)
                {
                    ApplicationArea = All;
                    Caption = 'Time';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Show)
            {
                ApplicationArea = All;
                Caption = 'Show';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LocalFile: Text;
                    FileManagement: Codeunit "File Management";
                begin
                    LocalFile := FileManagement.DownloadTempFile(Rec.Path + '/' + Rec.Name);
                    HyperLink(LocalFile);
                end;
            }
        }
    }
#endif
}

