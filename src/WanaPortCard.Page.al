page 87092 "wanaPort Card"
{
    Caption = 'WanaPort Card';
    DataCaptionFields = "Object Caption";
    PageType = Card;
    SourceTable = "wanaPort";

    layout
    {
        area(content)
        {
            group("Général")
            {
                Caption = 'General';
                field("Object Type"; rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; rec."Object ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Object Caption"; rec."Object Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("Page ID"; rec."Page ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Page Caption"; rec."Page Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("Field Separator"; rec."Field Separator")
                {
                    ApplicationArea = All;
                }
                field("Text Delimiter"; rec."Text Delimiter")
                {
                    ApplicationArea = All;
                }
            }
            group(Control800140091)
            {
                Caption = 'Import';
                field("Import Path"; rec."Import Path")
                {
                    ApplicationArea = All;
                }
                field("File Name Filter"; rec."File Name Filter")
                {
                    ApplicationArea = All;
                }
                field(ToImport; ToImport)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Files to Import';
                    //??DrillDownPageID = "wan WanaPort File List";
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(rec."Import Path", rec."File Name Filter");
                    end;
                }
                field("Archive Path"; rec."Archive Path")
                {
                    ApplicationArea = All;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Archived Files';
                    //??DrillDownPageID = "wan WanaPort File List";
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(rec."Archive Path", rec."File Name Filter");
                    end;
                }
                field("Last Import Entry No."; rec."Last Import Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Import DateTime"; rec."Last Import DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Control1900383701)
            {
                Caption = 'Export';
                field("Export Path"; rec."Export Path")
                {
                    ApplicationArea = All;
                }
                field(Exported; Exported)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Exported Files';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(rec."Export Path", StrSubstNo(rec."File Name Mask", '*', '*'));
                    end;
                }
                field("File Name Mask"; rec."File Name Mask")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 Entry No., %2 : TimeStamp (yyyymmddhhmmss)';
                }
                field("Last File No. Used"; rec."Last File No. Used")
                {
                    ApplicationArea = All;
                }
                field("Last Export Entry No."; rec."Last Export Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Export DateTime"; rec."Last Export DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(WanaPort)
            {
                Caption = 'WanaPort';
                action(Valeurs)
                {
                    ApplicationArea = All;
                    Caption = 'Values';
                    Image = ValueLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "wanaPort Field Value";
                    RunPageLink = "Object Type" = FIELD("Object Type"),
                                  "Object ID" = FIELD("Object ID");
                    ShortCutKey = 'Shift+Ctrl+N';
                }
                action(Formulaire)
                {
                    ApplicationArea = All;
                    Caption = 'Run Form';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        rec.TestField("Page ID");
                        PAGE.Run(rec."Page ID");
                    end;
                }
                action(Planification)
                {
                    ApplicationArea = All;
                    Caption = 'Scheduler';
                    Image = MachineCenterLoad;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        WanaPortMgt.ShowJobQueue(Rec);
                    end;
                }
                action(Journal)
                {
                    ApplicationArea = All;
                    Caption = 'Log';
                    Image = Log;
                    RunObject = Page "wanaPort Log";
                    RunPageLink = "Object Type" = FIELD("Object Type"),
                                  "Object ID" = FIELD("Object ID");
                    RunPageView = SORTING("Object Type", "Object ID");
                }
            }
        }
        area(processing)
        {
            group("Fonction&s")
            {
                Caption = 'Functions';
                action(Importer)
                {
                    ApplicationArea = All;
                    Caption = 'Import';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        WanaPortMgt.Import(Rec);
                    end;
                }
                action(Exporter)
                {
                    ApplicationArea = All;
                    Caption = 'Export';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        WanaPortMgt.Export(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ToImport := WanaPortMgt.FileCount(rec."Import Path", rec."File Name Filter");
        Archived := WanaPortMgt.FileCount(rec."Archive Path", rec."File Name Filter");
        Exported := WanaPortMgt.FileCount(rec."Export Path", StrSubstNo(rec."File Name Mask", '*', '*'));
    end;

    var
        WanaPortMgt: Codeunit "wanaPort Management";
        ToImport: Integer;
        Archived: Integer;
        Exported: Integer;
}

