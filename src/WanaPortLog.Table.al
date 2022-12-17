table 87092 "WanaPort Log"
{
    Caption = 'WanaPort Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            BlankZero = true;
            Caption = 'Entry No.';
        }
        field(2; "Object Type"; Option)
        {
            BlankZero = true;
            Caption = 'Object Type';
            NotBlank = true;
            OptionCaption = ',,,Report,,Codeunit,XMLport';
            OptionMembers = ,,,Report,,Codeunit,XMLport,;
        }
        field(3; "Object ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Object ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = FIELD("Object Type"));
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = Log,Error;
        }
        field(5; DateTime; DateTime)
        {
            Caption = 'Time Stamp';
        }
        field(6; Message; Text[250])
        {
            Caption = 'Message';
        }
        field(7; Position; Text[250])
        {
        }
        field(8; "Table ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Table ID';
        }
        field(18; "WanaPort File Name"; Text[250])
        {
            Caption = 'WanaPort File Name';
        }
        field(103; "Object Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = field("Object Type"), "Object ID" = field("Object ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(108; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Editable = true;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }

    procedure Show()
    var
        WanaPort: Record "WanaPort";
        PurchaseHeader: Record "Purchase Header";
    begin
        TestField("Entry Type", "Entry Type"::Error);
        TestField(Position);
        WanaPort.Get("Object Type", "Object ID");
        case "Table ID" of
            DATABASE::"Purchase Header":
                begin
                    PurchaseHeader.SetPosition(Position);
                    PurchaseHeader.SetRecFilter;
                    PAGE.Run(WanaPort."Page ID", PurchaseHeader);
                end;
            else
                WanaPort.TestField("Page ID");
                PAGE.Run(WanaPort."Page ID");
        end;
    end;

    procedure PositionCaption(): Text
    var
        RecordRef: RecordRef;
    begin
        if ("Table ID" = 0) or (Position = '') then
            exit('');
        RecordRef.Open("Table ID");
        RecordRef.SetPosition(Position);
        exit(RecordRef.GetPosition(true));
    end;
}

