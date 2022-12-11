table 87091 "wanaPort Field Value"
{

    Caption = 'WanaPort Field Value';
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
            TableRelation = AllObj."Object ID" WHERE("Object Type" = FIELD("Object Type"));

            trigger OnValidate()
            begin
                //??CALCFIELDS("Object Caption");
            end;
        }
        field(3; TableNo; Integer)
        {
            BlankZero = true;
            Caption = 'TableNo';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnValidate()
            var
                Objtransl: Record "Object Translation";
            begin
            end;
        }
        field(4; FieldNo; Integer)
        {
            BlankZero = true;
            Caption = 'FieldNo';
            TableRelation = Field."No." WHERE(TableNo = FIELD(TableNo));

            trigger OnLookup()
            var
                lField: Record "Field";
            begin
                lField.SetRange(TableNo, TableNo);
                if ACTION::LookupOK = PAGE.RunModal(PAGE::"Fields Lookup", lField) then
                    FieldNo := lField."No.";
                CalcFields("Field Caption", "Field Type Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Caption", "Field Type Name");
            end;
        }
        field(12; Constant; Text[30])
        {
            Caption = 'Constant';

            /*
            trigger OnLookup()
            var
                //??lTableRelation: Codeunit Codeunit8001415;
                lCode: Code[20];
            begin
                lCode := Constant;
                if lTableRelation.LookupRelation(TableNo, FieldNo, lCode) then
                    Constant := lCode;
            end;
            */
        }
        field(100; "Field Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD(TableNo),
                                                              "No." = FIELD(FieldNo)));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Field Type Name"; Text[30])
        {
            CalcFormula = Lookup(Field."Type Name" WHERE(TableNo = FIELD(TableNo),
                                                          "No." = FIELD(FieldNo)));
            Caption = 'Type';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Object Type", "Object ID", TableNo, FieldNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

