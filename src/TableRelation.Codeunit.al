Codeunit 87099 TableRelation
{

    procedure LookupRelation(pTableID: Integer; pFieldID: Integer; var pCode: Code[20]): Boolean
    var
        lField: Record "Field";
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
        lSelect: Integer;
        lCommaString: Text;
        lRelationRecordRef: RecordRef;
    begin
        if (pTableID = 0) or (pFieldID = 0) then
            exit(false);

        lRecordRef.Open(pTableID);
        lFieldRef := lRecordRef.Field(pFieldID);
        Evaluate(lField.Type, Format(lFieldRef.Type));
        case lField.Type of
            lField.Type::Option:
                begin
                    lCommaString := lFieldRef.OptionCaption;
                    if Evaluate(lSelect, pCode) then
                        lSelect := lSelect + 1;
                    lSelect := StrMenu(lCommaString, lSelect);
                    if lSelect <> 0 then
                        pCode := Format(lSelect - 1);
                end;
            lField.Type::Code:
                begin
                    /*
                    if lFieldRef.Relation <> 0 then
                        lRelationRecordRef.Open(lFieldRef.Relation)
                    else
                        lRelationRecordRef.Open(pTableID);
                    if not LookupRecordRef(lRelationRecordRef) then
                        exit(false)
                    else
                        pCode := lPrimaryKey(lRelationRecordRef);
                    */
                    if lFieldRef.Relation <> 0 then begin
                        lRelationRecordRef.Open(lFieldRef.Relation);
                        if not LookupRecordRef(lRelationRecordRef) then
                            exit;
                    end else begin
                        lRelationRecordRef.Open(pTableID);
                        if not Select(lRelationRecordRef) then
                            exit;
                    end;
                    pCode := lPrimaryKey(lRelationRecordRef);
                end;
            else
                exit(false); // Avoid lFieldRef.RELATION system error
        end;
        exit(true);
    end;

    procedure LookupRecordRef(var pRecordRef: RecordRef): Boolean
    var
        lTableID: Integer;
        l3: Record "Payment Terms";
        l4: Record Currency;
        l6: Record "Customer Price Group";
        l8: Record Language;
        l9: Record "Country/Region";
        l10: Record "Shipment Method";
        l13: Record "Salesperson/Purchaser";
        l14: Record Location;
        l15: Record "G/L Account";
        l92: Record "Customer Posting Group";
        l93: Record "Vendor Posting Group";
        l94: Record "Inventory Posting Group";
        l152: Record "Resource Group";
        l200: Record "Work Type";
        l204: Record "Unit of Measure";
        l208: Record "Job Posting Group";
        l230: Record "Source Code";
        l231: Record "Reason Code";
        l250: Record "Gen. Business Posting Group";
        l251: Record "Gen. Product Posting Group";
        l252: Record "General Posting Setup";
        l258: Record "Transaction Type";
        l259: Record "Transport Method";
        l286: Record Territory;
        l289: Record "Payment Method";
        l291: Record "Shipping Agent";
        l292: Record "Reminder Terms";
        l308: Record "No. Series";
        l323: Record "VAT Business Posting Group";
        l324: Record "VAT Product Posting Group";
        l325: Record "VAT Posting Setup";
        l340: Record "Customer Discount Group";
        l341: Record "Item Discount Group";
        l348: Record Dimension;
        l1006: Record "Job WIP Method";
        l5053: Record "Business Relation";
        l5057: Record "Industry Group";
        l5066: Record "Job Responsibility";
        l5068: Record Salutation;
        l5070: Record "Organizational Level";
        l5202: Record Qualification;
        l5204: Record Relative;
        l5206: Record "Cause of Absence";
        l5209: Record Union;
        l5210: Record "Cause of Inactivity";
        l5211: Record "Employment Contract";
        l5212: Record "Employee Statistics Group";
        l5213: Record "Misc. Article";
        l5215: Record Confidential;
        l5217: Record "Grounds for Termination";
        l5607: Record "FA Class";
        l5609: Record "FA Location";
        l5714: Record "Responsibility Center";
        l5720: Record Manufacturer;
        l5721: Record Purchasing;
        l5722: Record "Item Category";
        l8618: Record "Config. Template Header";
    begin
        lTableID := pRecordRef.Number;
        Clear(pRecordRef);
        case lTableID of
            0:
                ;
            Database::"Payment Terms":
                if Page.RunModal(0, l3) = Action::LookupOK then
                    pRecordRef.GetTable(l3);
            Database::Currency:
                if Page.RunModal(0, l4) = Action::LookupOK then
                    pRecordRef.GetTable(l4);
            Database::"Customer Price Group":
                if Page.RunModal(0, l6) = Action::LookupOK then
                    pRecordRef.GetTable(l6);
            Database::Language:
                if Page.RunModal(0, l8) = Action::LookupOK then
                    pRecordRef.GetTable(l8);
            Database::"Country/Region":
                if Page.RunModal(0, l9) = Action::LookupOK then
                    pRecordRef.GetTable(l9);
            Database::"Shipment Method":
                if Page.RunModal(0, l10) = Action::LookupOK then
                    pRecordRef.GetTable(l10);
            Database::"Salesperson/Purchaser":
                if Page.RunModal(0, l13) = Action::LookupOK then
                    pRecordRef.GetTable(l13);
            Database::Location:
                if Page.RunModal(0, l14) = Action::LookupOK then
                    pRecordRef.GetTable(l14);
            Database::"G/L Account":
                if Page.RunModal(0, l15) = Action::LookupOK then
                    pRecordRef.GetTable(l15);
            Database::"Customer Posting Group":
                if Page.RunModal(0, l92) = Action::LookupOK then
                    pRecordRef.GetTable(l92);
            Database::"Vendor Posting Group":
                if Page.RunModal(0, l93) = Action::LookupOK then
                    pRecordRef.GetTable(l93);
            Database::"Inventory Posting Group":
                if Page.RunModal(0, l94) = Action::LookupOK then
                    pRecordRef.GetTable(l94);
            Database::"Resource Group":
                if Page.RunModal(0, l152) = Action::LookupOK then
                    pRecordRef.GetTable(l152);
            Database::"Work Type":
                if Page.RunModal(0, l200) = Action::LookupOK then
                    pRecordRef.GetTable(l200);
            Database::"Unit of Measure":
                if Page.RunModal(0, l204) = Action::LookupOK then
                    pRecordRef.GetTable(l204);
            Database::"Job Posting Group":
                if Page.RunModal(0, l208) = Action::LookupOK then
                    pRecordRef.GetTable(l208);
            Database::"Source Code":
                if Page.RunModal(0, l230) = Action::LookupOK then
                    pRecordRef.GetTable(l230);
            Database::"Reason Code":
                if Page.RunModal(0, l231) = Action::LookupOK then
                    pRecordRef.GetTable(l231);
            Database::"Gen. Business Posting Group":
                if Page.RunModal(0, l250) = Action::LookupOK then
                    pRecordRef.GetTable(l250);
            Database::"Gen. Product Posting Group":
                if Page.RunModal(0, l251) = Action::LookupOK then
                    pRecordRef.GetTable(l251);
            Database::"General Posting Setup":
                if Page.RunModal(0, l252) = Action::LookupOK then
                    pRecordRef.GetTable(l252);
            Database::"Transaction Type":
                if Page.RunModal(0, l258) = Action::LookupOK then
                    pRecordRef.GetTable(l258);
            Database::"Transport Method":
                if Page.RunModal(0, l259) = Action::LookupOK then
                    pRecordRef.GetTable(l259);
            Database::Territory:
                if Page.RunModal(0, l286) = Action::LookupOK then
                    pRecordRef.GetTable(l286);
            Database::"Payment Method":
                if Page.RunModal(0, l289) = Action::LookupOK then
                    pRecordRef.GetTable(l289);
            Database::"Shipping Agent":
                if Page.RunModal(0, l291) = Action::LookupOK then
                    pRecordRef.GetTable(l291);
            Database::"Reminder Terms":
                if Page.RunModal(0, l292) = Action::LookupOK then
                    pRecordRef.GetTable(l292);
            Database::"No. Series":
                if Page.RunModal(0, l308) = Action::LookupOK then
                    pRecordRef.GetTable(l308);
            Database::"Customer Discount Group":
                if Page.RunModal(0, l340) = Action::LookupOK then
                    pRecordRef.GetTable(l340);
            Database::"Item Discount Group":
                if Page.RunModal(0, l341) = Action::LookupOK then
                    pRecordRef.GetTable(l341);
            Database::Dimension:
                if Page.RunModal(0, l348) = Action::LookupOK then
                    pRecordRef.GetTable(l348);
            Database::"Job WIP Method":
                if Page.RunModal(0, l1006) = Action::LookupOK then
                    pRecordRef.GetTable(l1006);
            Database::"VAT Business Posting Group":
                if Page.RunModal(0, l323) = Action::LookupOK then
                    pRecordRef.GetTable(l323);
            Database::"VAT Product Posting Group":
                if Page.RunModal(0, l324) = Action::LookupOK then
                    pRecordRef.GetTable(l324);
            Database::"VAT Posting Setup":
                if Page.RunModal(0, l325) = Action::LookupOK then
                    pRecordRef.GetTable(l325);
            Database::"Business Relation":
                if Page.RunModal(0, l5053) = Action::LookupOK then
                    pRecordRef.GetTable(l5053);
            Database::"Industry Group":
                if Page.RunModal(0, l5057) = Action::LookupOK then
                    pRecordRef.GetTable(l5057);
            Database::"Job Responsibility":
                if Page.RunModal(0, l5066) = Action::LookupOK then
                    pRecordRef.GetTable(l5066);
            Database::Salutation:
                if Page.RunModal(0, l5068) = Action::LookupOK then
                    pRecordRef.GetTable(l5068);
            Database::"Organizational Level":
                if Page.RunModal(0, l5070) = Action::LookupOK then
                    pRecordRef.GetTable(l5070);
            Database::Qualification:
                if Page.RunModal(0, l5202) = Action::LookupOK then
                    pRecordRef.GetTable(l5202);
            Database::Relative:
                if Page.RunModal(0, l5204) = Action::LookupOK then
                    pRecordRef.GetTable(l5204);
            Database::"Cause of Absence":
                if Page.RunModal(0, l5206) = Action::LookupOK then
                    pRecordRef.GetTable(l5206);
            Database::Union:
                if Page.RunModal(0, l5209) = Action::LookupOK then
                    pRecordRef.GetTable(l5209);
            Database::"Cause of Inactivity":
                if Page.RunModal(0, l5210) = Action::LookupOK then
                    pRecordRef.GetTable(l5210);
            Database::"Employment Contract":
                if Page.RunModal(0, l5211) = Action::LookupOK then
                    pRecordRef.GetTable(l5211);
            Database::"Employee Statistics Group":
                if Page.RunModal(0, l5212) = Action::LookupOK then
                    pRecordRef.GetTable(l5212);
            Database::"Misc. Article":
                if Page.RunModal(0, l5213) = Action::LookupOK then
                    pRecordRef.GetTable(l5213);
            Database::Confidential:
                if Page.RunModal(0, l5215) = Action::LookupOK then
                    pRecordRef.GetTable(l5215);
            Database::"Grounds for Termination":
                if Page.RunModal(0, l5217) = Action::LookupOK then
                    pRecordRef.GetTable(l5217);
            Database::"FA Class":
                if Page.RunModal(0, l5607) = Action::LookupOK then
                    pRecordRef.GetTable(l5607);
            Database::"FA Location":
                if Page.RunModal(0, l5609) = Action::LookupOK then
                    pRecordRef.GetTable(l5609);
            Database::"Responsibility Center":
                if Page.RunModal(0, l5714) = Action::LookupOK then
                    pRecordRef.GetTable(l5714);
            Database::Manufacturer:
                if Page.RunModal(0, l5720) = Action::LookupOK then
                    pRecordRef.GetTable(l5720);
            Database::Purchasing:
                if Page.RunModal(0, l5721) = Action::LookupOK then
                    pRecordRef.GetTable(l5721);
            Database::"Item Category":
                if Page.RunModal(0, l5722) = Action::LookupOK then
                    pRecordRef.GetTable(l5722);
            Database::"Config. Template Header":
                if Page.RunModal(0, l8618) = Action::LookupOK then
                    pRecordRef.GetTable(l8618);
            else
                exit(false); // Avoid lFieldRef.RELATION system error
        end;
        exit(pRecordRef.Number <> 0);
    end;

    local procedure lPrimaryKey(var pRecordRef: RecordRef): Code[20]
    var
        lKeyRef: KeyRef;
        lFieldRef: FieldRef;
        ltKeyCount: label 'Lokkup can''t be use on table %1 because primary key is not an unique field.';
    begin
        lKeyRef := pRecordRef.KeyIndex(1);
        if lKeyRef.FieldCount <> 1 then
            Error(ltKeyCount, pRecordRef.Number);
        lFieldRef := lKeyRef.FieldIndex(1);
        exit(Format(lFieldRef.Value));
    end;

    procedure Select(var pRecordRef: RecordRef) ReturnValue: Boolean
    var
        lGLAccount: Record "G/L Account";
        lCustomer: Record Customer;
        lVendor: Record Vendor;
        lItem: Record Item;
        lResource: Record Resource;
        lJob: Record Job;
        lContact: Record Contact;
        lEmployee: Record Employee;
        lFixedAsset: Record "Fixed Asset";
    begin
        ReturnValue := true;
        case pRecordRef.Number of
            Database::"G/L Account": // 15
                if Page.RunModal(0, lGLAccount) = Action::LookupOK then
                    pRecordRef.GetTable(lGLAccount)
                else
                    exit(false);
            Database::Customer: // 18
                if Page.RunModal(0, lCustomer) = Action::LookupOK then
                    pRecordRef.GetTable(lCustomer)
                else
                    exit(false);
            Database::Vendor: // 23
                if Page.RunModal(0, lVendor) = Action::LookupOK then
                    pRecordRef.GetTable(lVendor)
                else
                    exit(false);
            Database::Item: // 27
                if Page.RunModal(0, lItem) = Action::LookupOK then
                    pRecordRef.GetTable(lItem)
                else
                    exit(false);
            Database::Resource: // 156
                if Page.RunModal(0, lResource) = Action::LookupOK then
                    pRecordRef.GetTable(lResource)
                else
                    exit(false);
            Database::Job: // 167
                if Page.RunModal(0, lJob) = Action::LookupOK then
                    pRecordRef.GetTable(lJob)
                else
                    exit(false);
            Database::Contact: // 5050
                if Page.RunModal(0, lContact) = Action::LookupOK then
                    pRecordRef.GetTable(lContact)
                else
                    exit(false);
            Database::Employee: // 5200
                if Page.RunModal(0, lEmployee) = Action::LookupOK then
                    pRecordRef.GetTable(lEmployee)
                else
                    exit(false);
            Database::"Fixed Asset": // 5600
                if Page.RunModal(0, lFixedAsset) = Action::LookupOK then
                    pRecordRef.GetTable(lFixedAsset)
                else
                    exit(false);
        end;
    end;

    procedure LookUpDefaultValue(pTableID: Integer; pFieldID: Integer; var pValue: Text)
    var
        lRecordRef: RecordRef;
        lFieldRef: FieldRef;
        lCode: Code[20];
        lInteger: Integer;
    begin
        if pFieldID <> 0 then begin
            lRecordRef.Open(pTableID, true);
            lFieldRef := lRecordRef.Field(pFieldID);
            if lFieldRef.Relation <> 0 then begin
                lCode := pValue;
                if LookupRelation(pTableID, pFieldID, lCode) then
                    pValue := lCode;
            end else
                if Format(lFieldRef.Type) = 'Option' then begin
                    if pValue <> '' then
                        Evaluate(lInteger, pValue);
                    lInteger := StrMenu(Format(lFieldRef.OptionCaption), lInteger + 1);
                    if lInteger <> 0 then
                        pValue := Format(lInteger - 1);
                end else
                    if Format(lFieldRef.Type) = 'Boolean' then begin
                        if pValue <> '' then
                            Evaluate(lInteger, pValue);
                        lInteger := StrMenu(Format(false) + ',' + Format(true), lInteger + 1);
                        if lInteger <> 0 then
                            pValue := Format(lInteger - 1);
                    end;
        end;
    end;
}
