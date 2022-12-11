table 87092 "wanaPort Log"
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
            OptionCaption = ',,,Report,Dataport,Codeunit,XMLport';
            OptionMembers = TableData,"Table",Form,"Report",Dataport,"Codeunit","XMLport",MenuSuite;
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
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = FIELD("Object Type"),
                                                                           "Object ID" = FIELD("Object ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(108; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
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
        lWanaPort: Record "wanaPort";
        lPurchaseHeader: Record "Purchase Header";
    begin
        TestField("Entry Type", "Entry Type"::Error);
        TestField(Position);
        lWanaPort.Get("Object Type", "Object ID");
        case "Table ID" of
            DATABASE::"Purchase Header":
                begin
                    lPurchaseHeader.SetPosition(Position);
                    lPurchaseHeader.SetRecFilter;
                    PAGE.Run(lWanaPort."Page ID", lPurchaseHeader);
                end;
            else
                lWanaPort.TestField("Page ID");
                PAGE.Run(lWanaPort."Page ID");
        end;
    end;

    procedure PositionCaption(): Text
    var
        lRecordRef: RecordRef;
    begin
        if ("Table ID" = 0) or (Position = '') then
            exit('');
        lRecordRef.Open("Table ID");
        lRecordRef.SetPosition(Position);
        exit(lRecordRef.GetPosition(true));
    end;
}

