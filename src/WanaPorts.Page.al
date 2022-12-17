page 87090 "wanaPorts"
{

    ApplicationArea = All;
    Caption = 'WanaPorts';
    CardPageID = "WanaPort Card";
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "WanaPort";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control8149000)
            {
                Editable = false;
                ShowCaption = false;
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("WanaPortMgt.JobQueueSchedule(Rec)"; WanaPortMgt.JobQueueSchedule(Rec))
                {
                    ApplicationArea = All;
                    Caption = 'Schedule';
                }
                field("Import Path"; Rec."Import Path")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("File Name Filter"; Rec."File Name Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ToImport; ToImport)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Files to Import';
                    //??DrillDownPageID = "wan WanaPort File List";

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Import Path", Rec."File Name Filter");
                    end;
                }
                field("Archive Path"; Rec."Archive Path")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Archived Files';
                    //??DrillDownPageID = "WanaPort File List";

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Archive Path", Rec."File Name Filter");
                    end;
                }
                field("Export Path"; Rec."Export Path")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("File Name Mask"; Rec."File Name Mask")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last File No. Used"; Rec."Last File No. Used")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Exported; Exported)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Exported files';

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Export Path", StrSubstNo(Rec."File Name Mask", '*', '*'));
                    end;
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
                    Caption = 'Constants';
                    Image = VariableList;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "WanaPort Field Constant";
                    RunPageLink = "Object Type" = FIELD("Object Type"), "Object ID" = FIELD("Object ID");
                }
                action(ValueMap)
                {
                    ApplicationArea = All;
                    Caption = 'Value Map';
                    Image = Translate;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "WanaPort Map";
                    RunPageLink = "Object Type" = Field("Object Type"), "Object ID" = Field("Object ID");
                }
                action(RunPage)
                {
                    ApplicationArea = All;
                    Caption = 'Run Page';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Rec.TestField("Page ID");
                        Page.Run(Rec."Page ID");
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
                    RunObject = Page "WanaPort Log";
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
                Caption = 'F&unctions';
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
        ToImport := WanaPortMgt.FileCount(Rec."Import Path", Rec."File Name Filter");
        Archived := WanaPortMgt.FileCount(Rec."Archive Path", Rec."File Name Filter");
        Exported := WanaPortMgt.FileCount(Rec."Export Path", StrSubstNo(Rec."File Name Mask", '*', '*'));
    end;

    var
        WanaPortMgt: Codeunit "WanaPort Management";
        ToImport: Integer;
        Archived: Integer;
        Exported: Integer;
}
