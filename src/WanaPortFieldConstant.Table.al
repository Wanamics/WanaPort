namespace Wanamics.Wanaport;

using System.Reflection;
table 87091 "WanaPort Field Constant"
{

    Caption = 'Field Constant';

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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type"));
        }
        field(3; "Table No."; Integer)
        {
            BlankZero = true;
            NotBlank = true;
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(4; "Field No."; Integer)
        {
            BlankZero = true;
            NotBlank = true;
            Caption = 'Field No.';
            TableRelation = Field."No." where(TableNo = field("Table No."));

            trigger OnLookup()
            var
                lField: Record "Field";
            begin
                lField.SetRange(TableNo, "Table No.");
                if Action::LookupOK = Page.RunModal(Page::"Fields Lookup", lField) then
                    "Field No." := lField."No.";
                CalcFields("Field Caption", "Field Type Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Caption", "Field Type Name");
            end;
        }
        field(12; Constant; Text[100])
        {
            Caption = 'Constant';

            trigger OnLookup()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := CopyStr(Constant, 1, MaxStrLen(Code20));
                if Relation.Lookup("Table No.", "Field No.", Code20) then
                    Constant := Code20;
            end;

            trigger OnValidate()
            var
                Relation: Codeunit "WanaPort Relation";
                Code20: Code[20];
            begin
                Code20 := CopyStr(Constant, 1, MaxStrLen(Code20));
                Relation.Validate("Table No.", "Field No.", Code20);
            end;
        }
        field(100; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const("Object Type"::Table), "Object ID" = field("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Field Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Field Type Name"; Text[30])
        {
            CalcFormula = Lookup(Field."Type Name" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Field Type';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Object Type", "Object ID", "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }
}