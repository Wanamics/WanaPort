table 87091 "WanaPort Constant"
{

    Caption = 'WanaPort Constant';
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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type"));
        }
        field(3; TableNo; Integer)
        {
            BlankZero = true;
            Caption = 'TableNo';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(4; FieldNo; Integer)
        {
            BlankZero = true;
            Caption = 'FieldNo';
            TableRelation = Field."No." where(TableNo = field(TableNo));

            trigger OnLookup()
            var
                lField: Record "Field";
            begin
                lField.SetRange(TableNo, TableNo);
                if Action::LookupOK = Page.RunModal(Page::"Fields Lookup", lField) then
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

            trigger OnLookup()
            var
                TableRelation: Codeunit TableRelation;
                lCode: Code[20];
            begin
                lCode := Constant;
                if TableRelation.LookupRelation(TableNo, FieldNo, lCode) then
                    Constant := lCode;
            end;

            trigger OnValidate()
            begin
                //TODO
            end;
        }
        field(100; "Field Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" where(TableNo = field(TableNo), "No." = field(FieldNo)));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Field Type Name"; Text[30])
        {
            CalcFormula = Lookup(Field."Type Name" where(TableNo = field(TableNo), "No." = field(FieldNo)));
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
}