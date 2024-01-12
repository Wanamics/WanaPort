table 87097 "WanaPort Field Value Map-to"
{
    DataClassification = ToBeClassified;
    Caption = 'Field Value Map-to';

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
        field(4; "From Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'From Code';
            trigger OnLookup()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := Rec."From Code";
                if Relation.Lookup(Rec."Table No.", 0, Code20) then
                    Rec."From Code" := Code20;
            end;

            trigger OnValidate()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := CopyStr("From Code", 1, MaxStrLen(Code20));
                Relation.Validate("Table No.", 0, Code20);
            end;
        }
        field(5; "To Code"; code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'To Code';
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
        key(PK; "Object Type", "Object ID", "Table No.", "From Code")
        {
            Clustered = true;
        }
    }
}