namespace Wanamics.Wanaport;

using System.Utilities;
using System.Reflection;
table 87090 WanaPort
{
    Caption = 'WanaPort';
    DataCaptionFields = "Object Caption";
    LookupPageID = "WanaPorts";

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
                CheckPath(FieldCaption("Import Path"), "Import Path");
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
                CheckPath(FieldCaption("Archive Path"), "Archive Path");
            end;
        }
        field(7; "Archive File Name Pattern"; Text[250])
        {
            Caption = 'Archive File Name Pattern';
        }
        field(8; "Export Path"; Text[250])
        {
            Caption = 'Export Path';

            trigger OnValidate()
            begin
                CheckPath(FieldCaption("Export Path"), "Export Path");
            end;
        }
        field(9; "Export File Name Pattern"; Text[250])
        {
            Caption = 'Export File Name Pattern';
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
        field(20; "Page ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));

            trigger OnValidate()
            begin
                CalcFields("Page Caption");
            end;
        }
        field(21; "Processing Path"; Text[250])
        {
            Caption = 'Processing Path';

            trigger OnValidate()
            begin
                CheckPath(FieldCaption("Processing Path"), "Processing Path");
            end;
        }
        field(102; "Object Caption"; Text[250])
        {
            Caption = 'Object Caption';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula =
                lookup(AllObjWithCaption."Object Caption"
                where("Object Type" = field("Object Type"), "Object ID" = field("Object ID")));
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

    trigger OnInsert()
    begin
        "Last File No. Used" := '';
        "Last Import Entry No." := 0;
        "Last Export Entry No." := 0;
        "Last Import DateTime" := 0DT;
        "Last Export DateTime" := 0DT;
    end;

    trigger OnDelete()
    var
        WanaPortFieldConstant: Record "WanaPort Field Constant";
        WanaPortFieldValueMap: Record "WanaPort Field Value Map";
        WanaPortFieldValueMapTo: Record "WanaPort Field Value Map-to";
    begin
        WanaPortFieldConstant.SetRange("Object Type", "Object Type");
        WanaPortFieldConstant.SetRange("Object ID", "Object ID");
        WanaPortFieldConstant.DeleteAll(true);
        WanaPortFieldValueMap.SetRange("Object Type", "Object Type");
        WanaPortFieldValueMap.SetRange("Object ID", "Object ID");
        WanaPortFieldValueMap.DeleteAll(true);
        WanaPortFieldValueMapTo.SetRange("Object Type", "Object Type");
        WanaPortFieldValueMapTo.SetRange("Object ID", "Object ID");
        WanaPortFieldValueMapTo.DeleteAll(true);
    end;

    var
        StartDateTime: DateTime;
        TypeHelper: Codeunit "Type Helper";

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
    var
        WanaPortManagement: Codeunit "WanaPort Management";
    begin
        WanaPortManagement.Import(Rec);
    end;

    procedure Export()
    var
        WanaPortManagement: Codeunit "WanaPort Management";
    begin
        WanaPortManagement.Export(Rec);
    end;

    procedure Export(var pTempBlob: Codeunit "Temp Blob"): Boolean
    var
        WanaPortManagement: Codeunit "WanaPort Management";
    begin
        exit(WanaPortManagement.ExportFrom(Rec, pTempBlob));
    end;

    local procedure CheckPath(pFieldCaotion: Text; pFieldValue: Text)
    var
        WanaPortManagement: Codeunit "WanaPort Management";
        ServerPathCantBeCheckedMsg: Label '%1 network path can''t be checked.';
        ConfirmMsg: Label 'Do you want to continue?';
    begin
        if pFieldValue = '' then
            exit;
        if WanaPortManagement.ServerDirectoryExists(pFieldValue) then
            exit;
        if not Confirm(ServerPathCantBeCheckedMsg + '\' + ConfirmMsg, false, pFieldValue) then
            Error('');
    end;

    procedure Map(pTableID: Integer; pFrom: Text): Text
    var
        WanaPortFieldValueMap: Record "WanaPort Field Value Map";
    begin
        if WanaPortFieldValueMap.Get(Rec."Object Type", Rec."Object ID", pTableID, pFrom) then
            exit(WanaPortFieldValueMap."Target Code")
        else
            exit(CopyStr(pFrom, 1, MaxStrLen(WanaPortFieldValueMap."Target Code")));
    end;

    procedure MapTo(pTableID: Integer; pFrom: Text): Text
    var
        FieldValueMapTo: Record "WanaPort Field Value Map-to";
    begin
        if FieldValueMapTo.Get(Rec."Object Type", Rec."Object ID", pTableID, pFrom) then
            exit(FieldValueMapTo."To Code")
        else
            exit(pFrom);
    end;

    procedure ToDate(pText: Text): Date
    begin
        exit(ToDate(pText, 'dd/MM/yyyy'));
    end;

    procedure ToDate(pText: Text; pDateFormat: Text) ReturnValue: Date
    var
        v: Variant;
    begin
        v := ReturnValue;
        if TypeHelper.Evaluate(v, pText, pDateFormat, '') then
            exit(v);
    end;

    procedure ToDecimal(pText: Text): Decimal
    begin
        exit(ToDecimal(pText, 'en-US'));
    end;

    procedure ToDecimal(pText: Text; pCulture: Text) ReturnValue: Decimal
    var
        v: Variant;
    begin
        v := ReturnValue;
        if TypeHelper.Evaluate(v, pText, 'G', pCulture) then
            exit(v);
    end;

    procedure GetFieldConstant(pTableId: Integer; pFieldId: Integer): Text
    var
        FieldConstant: Record "WanaPort Field Constant";
    begin
        if FieldConstant.Get(Rec."Object Type", Rec."Object ID", pTableId, pFieldId) then
            exit(FieldConstant.Constant);
    end;
}