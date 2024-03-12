tableextension 87090 "WanaPort Gen. Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(87090; "WanaPort Object Type"; Option)
        {
            Caption = 'WanaPort Object Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,,,Report,,Codeunit,XMLport';
            OptionMembers = " ",,,"Report",,"Codeunit","XMLport";
            trigger OnValidate()
            begin
                "WanaPort Object ID" := 0;
            end;
        }
        field(87091; "WanaPort Object ID"; Integer)
        {
            Caption = 'WanaPort Object ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("WanaPort Object Type"));
            BlankZero = true;
        }
    }
}
