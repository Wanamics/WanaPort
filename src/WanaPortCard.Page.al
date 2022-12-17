page 87092 "WanaPort Card"
{
    Caption = 'WanaPort Card';
    DataCaptionFields = "Object Caption";
    PageType = Card;
    SourceTable = "WanaPort";

    layout
    {
        area(content)
        {
            group("Général")
            {
                Caption = 'General';
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Page Caption"; Rec."Page Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                }
                field("Field Separator"; Rec."Field Separator")
                {
                    ApplicationArea = All;
                }
                field("Text Delimiter"; Rec."Text Delimiter")
                {
                    ApplicationArea = All;
                }
            }
            group(Import)
            {
                Caption = 'Import';
                field("Import Path"; Rec."Import Path")
                {
                    ApplicationArea = All;
                }
                field("File Name Filter"; Rec."File Name Filter")
                {
                    ApplicationArea = All;
                }
                field(ToImport; ToImport)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Files to Import';
                    DrillDownPageID = "WanaPort File List";
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Import Path", Rec."File Name Filter");
                    end;
                }
                field("Archive Path"; Rec."Archive Path")
                {
                    ApplicationArea = All;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Archived Files';
                    DrillDownPageID = "WanaPort File List";
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        WanaPortMgt.ShowFileList(Rec."Archive Path", Rec."File Name Filter");
                    end;
                }
                field("Last Import Entry No."; Rec."Last Import Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Import DateTime"; Rec."Last Import DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Export)
            {
                Caption = 'Export';
                field("Export Path"; Rec."Export Path")
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
                        WanaPortMgt.ShowFileList(Rec."Export Path", StrSubstNo(Rec."File Name Mask", '*', '*'));
                    end;
                }
                field("File Name Mask"; Rec."File Name Mask")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 Entry No., %2 : TimeStamp (yyyymmddhhmmss)';
                }
                field("Last File No. Used"; Rec."Last File No. Used")
                {
                    ApplicationArea = All;
                }
                field("Last Export Entry No."; Rec."Last Export Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Export DateTime"; Rec."Last Export DateTime")
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
                action(Constants)
                {
                    ApplicationArea = All;
                    Caption = 'Constants';
                    Image = VariableList;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "WanaPort Constant";
                    RunPageLink = "Object Type" = Field("Object Type"), "Object ID" = Field("Object ID");
                }
                action(ValueMap)
                {
                    ApplicationArea = All;
                    Caption = 'Value Map';
                    Image = Translate;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "WanaPort Field Value Map";
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
                action(Scheduler)
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
                    RunPageLink = "Object Type" = Field("Object Type"), "Object ID" = Field("Object ID");
                    RunPageView = Sorting("Object Type", "Object ID");
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

