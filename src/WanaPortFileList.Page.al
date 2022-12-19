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
            action(Afficher)
            {
                ApplicationArea = All;
                Caption = 'Show';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LocalFile: Text;
                    lFileMgt: Codeunit "File Management";
                begin
                    LocalFile := lFileMgt.DownloadTempFile(Rec.Path + '/' + Rec.Name);
                    HyperLink(LocalFile);
                end;
            }
        }
    }
#else
    layout
    {
    }
    actions
    {

    }

#endif
}

