table 87090 WanaPort
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
            OptionCaption = ',,,Report,,Codeunit,XMLport';
            OptionMembers = ,,,"Report",,"Codeunit","XMLport",;
        }
        field(2; "Object ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Object ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type"));

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
                if Rec."Import Path" <> '' then
                    if not WanaPortManagement.ServerDirectoryExists("Import Path") then
                        FieldError("Import Path", ServerPathNotExistsErr);
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
                if "Archive Path" <> '' then
                    if not WanaPortManagement.ServerDirectoryExists("Archive Path") then
                        FieldError("Archive Path", ServerPathNotExistsErr);
            end;
        }
        field(7; "Page ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));

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
                if "Export Path" <> '' then
                    if not WanaPortManagement.ServerDirectoryExists("Export Path") then
                        FieldError("Export Path", ServerPathNotExistsErr);
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
        field(17; "Archive File Name Mask"; Text[250])
        {
            Caption = 'Archive File Name Mask';
        }
        field(18; "WanaPort File Name"; Text[250])
        {
            Caption = 'WanaPort File Name';
            FieldClass = FlowFilter;
        }
        field(102; "Object Caption"; Text[250])
        {
            CalcFormula =
                lookup(AllObjWithCaption."Object Caption"
                where("Object Type" = field("Object Type"), "Object ID" = field("Object ID")));
            Caption = 'Object Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; "Page Caption"; Text[250])
        {
            CalcFormula =
                lookup(AllObjWithCaption."Object Caption"
                where("Object Type" = const(Page), "Object ID" = field("Page ID")));
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

    trigger OnDelete()
    var
        WanaPortFieldValue: Record "WanaPort Field Constant";
    begin
        WanaPortFieldValue.SetRange("Object Type", "Object Type");
        WanaPortFieldValue.SetRange("Object ID", "Object ID");
        WanaPortFieldValue.DeleteAll;
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
        //FileManagement: Codeunit "File Management";
        WanaPortManagement: Codeunit "WanaPort Management";
        ServerPathNotExistsErr: Label 'does not exists on server';
        StartDateTime: DateTime;

    procedure LogError(pMessage: Text; pTableID: Integer; pPosition: Text)
    begin
        Log(pMessage, 1, pTableID, pPosition);
    end;

    procedure LogProcess()
    begin
        Log("WanaPort File Name", 0, 0, '');
    end;

    procedure LogBegin()
    var
        ltBegin: Label 'Begin...';
    begin
        Log(ltBegin, 0, 0, '');
        StartDateTime := CurrentDateTime;
    end;

    procedure LogEnd()
    var
        ltDone: Label 'Done in %1';
    begin
        Log(StrSubstNo(ltDone, CurrentDateTime - StartDateTime), 0, 0, '');
    end;

    local procedure Log(pMessage: Text; pEntryType: Integer; pTableID: Integer; pPosition: Text)
    var
        WanaPortLog: Record "WanaPort Log";
    begin
        WanaPortLog."Entry No." := 0; // AutoIncrement
        WanaPortLog."Object Type" := "Object Type";
        WanaPortLog."Object ID" := "Object ID";
        WanaPortLog.DateTime := CurrentDateTime;
        WanaPortLog.Message := CopyStr(pMessage, 1, MaxStrLen(WanaPortLog.Message));
        WanaPortLog."Entry Type" := pEntryType;
        WanaPortLog.Position := pPosition;
        WanaPortLog."Table ID" := pTableID;
        WanaPortLog."WanaPort File Name" := "WanaPort File Name";
        WanaPortLog.Insert;
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

    procedure Import()
    begin
        WanaPortManagement.Import(Rec);
    end;

    procedure Export()
    begin
        WanaPortManagement.Export(Rec);
    end;
}