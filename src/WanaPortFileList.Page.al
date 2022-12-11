page 87093 "wanaPort File List"
{
    Caption = 'Files';
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    //SourceTable = File;

    layout
    {
        area(content)
        {
            /*??
            repeater(Control8149000)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                    Caption = 'Size';
                }
                field(Date; Date)
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }
                field(Time; Time)
                {
                    ApplicationArea = All;
                    Caption = 'Time';
                }
            }
            ??*/
        }
    }

    actions
    {
        area(processing)
        {
            /*
            action(Afficher)
            {
                ApplicationArea = All;
                Caption = 'Show';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    lServerFile: Text;
                    lLocalFile: Text;
                    lFileMgt: Codeunit "File Management";
                begin
                    //??lServerFile := Path + '/' + Name;
                    lLocalFile := lFileMgt.DownloadTempFile(lServerFile);
                    HyperLink(lLocalFile);
                end;
            }
            */
        }
    }
}

