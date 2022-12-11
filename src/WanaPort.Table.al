table 87090 "wanaPort"
{
    Caption = 'WanaPort';
    DataCaptionFields = "Object Caption";
    LookupPageID = "wanaPorts";

    fields
    {
        field(1; "Object Type"; Option)
        {
            BlankZero = true;
            Caption = 'Object Type';
            NotBlank = true;
            OptionCaption = ',,,Report,Dataport,Codeunit,XMLport';
            OptionMembers = TableData,"Table",Form,"Report",Dataport,"Codeunit","XMLport",MenuSuite;
        }
        field(2; "Object ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Object ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = FIELD("Object Type"));

            trigger OnValidate()
            begin
                CalcFields("Object Caption");
            end;
        }
        field(4; "Import Path"; Text[250])
        {
            Caption = 'Import Path';

            trigger OnValidate()
            begin
                /*??
                if "Import Path" <> '' then
                    if not FileManagement.ServerDirectoryExists("Import Path") then
                        FieldError("Import Path", tServerPathNotExists);
                ??*/
            end;
        }
        field(5; "File Name Filter"; Text[250])
        {
            Caption = 'File Name Filter';
        }
        field(6; "Archive Path"; Text[250])
        {
            Caption = 'Archive Path';

            trigger OnValidate()
            begin
                /*??
                if "Archive Path" <> '' then
                    if not FileManagement.ServerDirectoryExists("Archive Path") then
                        FieldError("Archive Path", tServerPathNotExists);
                ??*/
            end;
        }
        field(7; "Page ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Page));

            trigger OnValidate()
            begin
                CalcFields("Page Caption");
            end;
        }
        field(8; "Export Path"; Text[250])
        {
            Caption = 'Export Path';

            trigger OnLookup()
            begin
                /*??
                if "Export Path" <> '' then
                    if not FileManagement.ServerDirectoryExists("Export Path") then
                        FieldError("Export Path", tServerPathNotExists);
                ??*/
            end;
        }
        field(9; "File Name Mask"; Text[250])
        {
            Caption = 'File Name Mask';
        }
        field(10; "Last File No. Used"; Code[20])
        {
            Caption = 'Last No. Used';
        }
        field(11; "Last Import Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Last Import Entry No.';
        }
        field(12; "Last Export Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Last Export Entry No.';
        }
        field(13; "Last Import DateTime"; DateTime)
        {
            Caption = 'Last Import DateTime';
        }
        field(14; "Last Export DateTime"; DateTime)
        {
            Caption = 'Last Export DateTime';
        }
        field(15; "Field Separator"; Option)
        {
            Caption = 'Field Separator';
            OptionCaption = 'Tab,Comma,SemiColon';
            OptionMembers = Tab,Comma,SemiColon;
        }
        field(16; "Text Delimiter"; Option)
        {
            Caption = 'Text Delimiter';
            OptionCaption = 'None,"';
            OptionMembers = "None",Quote;
        }
        field(18; "WanaPort File Name"; Text[250])
        {
            Caption = 'WanaPort File Name';
            FieldClass = FlowFilter;
        }
        field(102; "Object Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = FIELD("Object Type"),
                                                                           "Object ID" = FIELD("Object ID")));
            Caption = 'Object Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; "Page Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Page Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Object Type", "Object ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lWanaPortFieldValue: Record "wanaPort Field Value";
    begin
        lWanaPortFieldValue.SetRange("Object Type", "Object Type");
        lWanaPortFieldValue.SetRange("Object ID", "Object ID");
        lWanaPortFieldValue.DeleteAll;
    end;

    trigger OnInsert()
    begin
        "Last File No. Used" := '';
        "Last Import Entry No." := 0;
        "Last Export Entry No." := 0;
        "Last Import DateTime" := 0DT;
        "Last Export DateTime" := 0DT;
    end;

    var
        FileManagement: Codeunit "File Management";
        tServerPathNotExists: Label 'does not exists on server';
        StartDateTime: DateTime;

    procedure LogError(pMessage: Text; pTableID: Integer; pPosition: Text)
    begin
        lLog(pMessage, 1, pTableID, pPosition);
    end;


    procedure LogProcess()
    begin
        lLog("WanaPort File Name", 0, 0, '');
    end;


    procedure LogBegin()
    var
        ltBegin: Label 'Begin...';
    begin
        lLog(ltBegin, 0, 0, '');
        StartDateTime := CurrentDateTime;
    end;


    procedure LogEnd()
    var
        ltDone: Label 'Done in %1';
    begin
        lLog(StrSubstNo(ltDone, CurrentDateTime - StartDateTime), 0, 0, '');
    end;

    local procedure lLog(pMessage: Text; pEntryType: Integer; pTableID: Integer; pPosition: Text)
    var
        lWanaPortLog: Record "wanaPort Log";
    begin
        lWanaPortLog."Entry No." := 0; // AutoIncrement
        lWanaPortLog."Object Type" := "Object Type";
        lWanaPortLog."Object ID" := "Object ID";
        lWanaPortLog.DateTime := CurrentDateTime;
        lWanaPortLog.Message := CopyStr(pMessage, 1, MaxStrLen(lWanaPortLog.Message));
        lWanaPortLog."Entry Type" := pEntryType;
        lWanaPortLog.Position := pPosition;
        lWanaPortLog."Table ID" := pTableID;
        lWanaPortLog."WanaPort File Name" := "WanaPort File Name";
        lWanaPortLog.Insert;
    end;

    procedure GetSeparator(): Text[1];
    var
        Tab: Text[1];
    begin
        Tab[1] := 9;
        case Rec."Field Separator" of
            Rec."Field Separator"::Tab:
                Exit(Tab);
            Rec."Field Separator"::Comma:
                exit(',');
            Rec."Field Separator"::SemiColon:
                Exit(';');
        end
    end;
}

