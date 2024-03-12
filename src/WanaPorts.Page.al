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
            repeater(Lines)
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
                field("Page Caption"; Rec."Page Caption")
                {
                    ToolTip = 'Specifies the value of the Page Caption field.';
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
                field(ToImport; WanaPortMgt.FileCount(Rec."Import Path", Rec."File Name Filter"))
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Files to Import';
                    Visible = IsOnPrem;

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
                field(Archived; WanaPortMgt.FileCount(Rec."Archive Path", WanaPortMgt.ArchivedFileNameFilter(Rec)))
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Archived Files';
                    Visible = IsOnPrem;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Archive Path", WanaPortMgt.ArchivedFileNameFilter(Rec));
                    end;
                }
                field("Export Path"; Rec."Export Path")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("File Name Mask"; Rec."Export File Name Pattern")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last File No. Used"; Rec."Last File No. Used")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Exported; WanaPortMgt.FileCount(Rec."Export Path", StrSubstNo(Rec."Export File Name Pattern", '*', '*')))
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Exported files';
                    Visible = IsOnPrem;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Export Path", StrSubstNo(Rec."Export File Name Pattern", '*', '*'));
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Constants)
            {
                ApplicationArea = All;
                Caption = 'Constants';
                Image = VariableList;
                RunObject = Page "WanaPort Field Constants";
                RunPageLink = "Object Type" = FIELD("Object Type"), "Object ID" = FIELD("Object ID");
            }
            action(ValueMapImport)
            {
                ApplicationArea = All;
                Caption = 'Value Map Import';
                Image = Translate;
                RunObject = Page "WanaPort Field Value Map";
                RunPageLink = "Object Type" = Field("Object Type"), "Object ID" = Field("Object ID");
            }
            action(ValueMapExport)
            {
                ApplicationArea = All;
                Caption = 'Value Map Export';
                Image = Translate;
                RunObject = Page "WanaPort Field Value Map-to";
                RunPageLink = "Object Type" = Field("Object Type"), "Object ID" = Field("Object ID");
            }
            action(RunPage)
            {
                ApplicationArea = All;
                Caption = 'Run Page';
                Image = Start;

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
                RunPageLink = "Object Type" = field("Object Type"),
                                  "Object ID" = field("Object ID");
                RunPageView = sorting("Object Type", "Object ID");
            }
        }
        area(processing)
        {
            group("Fonction&s")
            {
                Caption = 'F&unctions';
                action(Import)
                {
                    ApplicationArea = All;
                    Caption = 'Import';
                    Image = Import;

                    trigger OnAction()
                    begin
                        WanaPortMgt.Import(Rec);
                    end;
                }
                action(Export)
                {
                    ApplicationArea = All;
                    Caption = 'Export';
                    Image = Export;

                    trigger OnAction()
                    begin
                        WanaPortMgt.Export(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(RunPageRef; RunPage) { }
            actionref(ExportRef; Export) { }
            actionref(ImportRef; Import) { }
        }
    }

    trigger OnOpenPage()
    begin
#if ONPREM
        IsOnPrem := true;
#else
        IsOnPrem := false;
#endif
    end;

    var
        WanaPortMgt: Codeunit "WanaPort Management";
        IsOnPrem: Boolean;
}