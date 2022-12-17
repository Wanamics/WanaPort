table 87096 "WanaPort Value Map"
{
    DataClassification = ToBeClassified;
    Caption = 'WanaPort Value Map';

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
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = FIELD("Object Type"));
        }
        field(3; "Table No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Table No.';
            BlankZero = true;
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
            /*
            TableRelation = //TODO 
                if ("Table No." = Const(Database::Vendor)) Vendor
            else
            if ("Table No." = Const(Database::Customer)) customer;
            */
            trigger OnLookup()
            var
                TableRelation: Codeunit TableRelation;
            begin
                if TableRelation.LookupRelation(Rec."Table No.", 1, "Target Code") then;
            end;

            trigger OnValidate()
            begin
                //TODO
            end;
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