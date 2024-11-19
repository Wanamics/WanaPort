namespace Wanamics.Wanaport;

using System.Reflection;
table 87096 "WanaPort Field Value Map"
{
    DataClassification = ToBeClassified;
    Caption = 'Field Value Map';

    fields
    {
        field(1; "Object Type"; Option)
        {
            BlankZero = true;
            Caption = 'Object Type';
            NotBlank = true;
            OptionCaption = ',,,Report,,Codeunit,XMLport';
            OptionMembers = ,,,Report,,Codeunit,XMLport;
        }
        field(2; "Object ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Object ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type"));
        }
        field(3; "Table No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Table No.';
            BlankZero = true;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(4; "Source No."; code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source No.';
        }
        field(5; "Target Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Target No.';
            trigger OnLookup()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := Rec."Target Code";
                if Relation.Lookup(Rec."Table No.", 0, Code20) then
                    Rec."Target Code" := Code20;
            end;

            trigger OnValidate()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := CopyStr("Target Code", 1, MaxStrLen(Code20));
                Relation.Validate("Table No.", 0, Code20);
            end;
        }
        field(103; "Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Object Type", "Object ID", "Table No.", "Source No.")
        {
            Clustered = true;
        }
    }
}