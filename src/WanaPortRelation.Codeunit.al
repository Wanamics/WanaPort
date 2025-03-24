namespace Wanamics.Wanaport;

using Microsoft.Foundation.PaymentTerms;
using System.Reflection;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Pricing;
using System.Globalization;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Shipping;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Location;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Projects.Project.Job;
using Microsoft.Utilities;
using Microsoft.Foundation.UOM;
using Microsoft.Projects.Resources.Journal;
using Microsoft.Projects.Project.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Intrastat;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Reminder;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Intercompany.Partner;
using Microsoft.Projects.Project.WIP;
using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Setup;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Setup;
using Microsoft.HumanResources.Absence;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Inventory.Item.Catalog;
using System.IO;
codeunit 87099 "WanaPort Relation"
{
    procedure Validate(pTableID: Integer; pFieldID: Integer; var pCode: Code[20]): Boolean
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        RelationRecordRef: RecordRef;
        NotExistsErr: Label 'This value doesn''t exists in "%1"';
        ContinueMsg: Label 'Do you want to continue?';
    begin
        if pTableID = 0 then
            exit(false);
        RecRef.Open(pTableID);
        if pFieldID <> 0 then
            FldRef := RecRef.Field(pFieldID)
        else
            if not GetPrimaryKeyUniqueField(RecRef, FldRef) then
                exit(true);
        if FldRef.Relation = 0 then
            RelationRecordRef.Open(pTableID)
        else
            RelationRecordRef.Open(FldRef.Relation);
        if SetPrimaryKey(RelationRecordRef, pCode) then
            if not RelationRecordRef.Find() then
                // Error(StrSubstNo(NotExistsErr, RelationRecordRef.Caption));
                if not Confirm(NotExistsErr + '\' + ContinueMsg, false, RelationRecordRef.Caption) then
                    Error('');
    end;

    local procedure GetPrimaryKey(var pRecordRef: RecordRef): Code[20]
    var
        FldRef: FieldRef;
    begin
        if GetPrimaryKeyUniqueField(pRecordRef, FldRef) then
            exit(Format(FldRef.Value));
    end;

    local procedure SetPrimaryKey(var pRecordRef: RecordRef; pCode: Code[20]) ReturnValue: Boolean
    var
        FldRef: FieldRef;
    begin
        ReturnValue := GetPrimaryKeyUniqueField(pRecordRef, FldRef);
        if ReturnValue then
            FldRef.Value := pCode;
    end;

    local procedure GetPrimaryKeyUniqueField(var pRecordRef: RecordRef; var pFieldRef: FieldRef) ReturnValue: Boolean
    var
        KRef: KeyRef;
    begin
        KRef := pRecordRef.KeyIndex(1);
        ReturnValue := KRef.FieldCount = 1;
        pFieldRef := KRef.FieldIndex(1);
    end;


    procedure Lookup(pTableID: Integer; pFieldID: Integer; var pCode: Code[20]): Boolean
    var
        Fld: Record "Field";
        RecRef: RecordRef;
        FldRef: FieldRef;
        Select: Integer;
        CommaString: Text;
        RelationRecordRef: RecordRef;
        LookupNotAvailableErr: label 'Lookup not available (table primary key field is not unique).';
    begin
        if pTableID = 0 then
            exit(false);
        RecRef.Open(pTableID);
        if pFieldID = 0 then
            GetPrimaryKeyUniqueField(RecRef, FldRef)
        else
            FldRef := RecRef.Field(pFieldID);
        Evaluate(Fld.Type, Format(FldRef.Type));
        case Fld.Type of
            Fld.Type::Option:
                begin
                    CommaString := FldRef.OptionCaption;
                    if Evaluate(Select, pCode) then
                        Select := Select + 1;
                    Select := StrMenu(CommaString, Select);
                    if Select <> 0 then
                        pCode := Format(Select - 1);
                end;
            Fld.Type::Code:
                begin
                    if FldRef.Relation = 0 then
                        RelationRecordRef.Open(pTableID)
                    else
                        RelationRecordRef.Open(FldRef.Relation);
                    if not SetPrimaryKey(RelationRecordRef, pCode) then
                        Error(StrSubstNo(LookupNotAvailableErr, RelationRecordRef.Caption));
                    if RelationRecordRef.Find() then;
                    if LookupRecordRef(RelationRecordRef) then
                        pCode := GetPrimaryKey(RelationRecordRef);
                end;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure LookupRecordRef(var pRecordRef: RecordRef): Boolean
    var
        IsHandled: Boolean;
        Rec3: Record "Payment Terms";
        Rec4: Record Currency;
        Rec6: Record "Customer Price Group";
        Rec8: Record Language;
        Rec9: Record "Country/Region";
        Rec10: Record "Shipment Method";
        Rec13: Record "Salesperson/Purchaser";
        Rec14: Record Location;
        Rec15: Record "G/L Account";
        Rec18: Record Customer;
        Rec23: Record Vendor;
        Rec27: Record Item;
        Rec80: Record "Gen. Journal Template";
        Rec82: Record "Item Journal Template";
        Rec92: Record "Customer Posting Group";
        Rec93: Record "Vendor Posting Group";
        Rec94: Record "Inventory Posting Group";
        Rec152: Record "Resource Group";
        Rec156: Record Resource;
        Rec167: Record Job;
        Rec200: Record "Work Type";
        Rec204: Record "Unit of Measure";
        Rec206: Record "Res. Journal Template";
        Rec208: Record "Job Posting Group";
        Rec209: Record "Job Journal Template";
        Rec230: Record "Source Code";
        Rec231: Record "Reason Code";
        Rec250: Record "Gen. Business Posting Group";
        Rec251: Record "Gen. Product Posting Group";
        Rec252: Record "General Posting Setup";
        Rec258: Record "Transaction Type";
        Rec259: Record "Transport Method";
        Rec270: Record "Bank Account";
        Rec286: Record Territory;
        Rec289: Record "Payment Method";
        Rec291: Record "Shipping Agent";
        Rec292: Record "Reminder Terms";
        Rec308: Record "No. Series";
        Rec323: Record "VAT Business Posting Group";
        Rec324: Record "VAT Product Posting Group";
        Rec325: Record "VAT Posting Setup";
        Rec340: Record "Customer Discount Group";
        Rec341: Record "Item Discount Group";
        Rec348: Record Dimension;
        Rec413: Record "IC Partner";
        Rec1006: Record "Job WIP Method";
        Rec5050: Record Contact;
        Rec5053: Record "Business Relation";
        Rec5057: Record "Industry Group";
        Rec5066: Record "Job Responsibility";
        Rec5068: Record Salutation;
        Rec5070: Record "Organizational Level";
        Rec5200: Record Employee;
        Rec5202: Record Qualification;
        Rec5204: Record Relative;
        Rec5206: Record "Cause of Absence";
        Rec5209: Record Union;
        Rec5210: Record "Cause of Inactivity";
        Rec5211: Record "Employment Contract";
        Rec5212: Record "Employee Statistics Group";
        Rec5213: Record "Misc. Article";
        Rec5215: Record Confidential;
        Rec5217: Record "Grounds for Termination";
        Rec5600: Record "Fixed Asset";
        Rec5607: Record "FA Class";
        Rec5609: Record "FA Location";
        Rec5714: Record "Responsibility Center";
        Rec5720: Record Manufacturer;
        Rec5721: Record Purchasing;
        Rec5722: Record "Item Category";
        Rec8618: Record "Config. Template Header";
    begin
        case pRecordRef.Number of
            0:
                exit(false);
            Database::"Payment Terms":
                begin
                    pRecordRef.SetTable(Rec3);
                    if Page.RunModal(0, Rec3) = Action::LookupOK then
                        pRecordRef.GetTable(Rec3);
                end;
            Database::Currency:
                begin
                    pRecordRef.SetTable(Rec4);
                    if Page.RunModal(0, Rec4) = Action::LookupOK then
                        pRecordRef.GetTable(Rec4);
                end;
            Database::"Customer Price Group":
                begin
                    pRecordRef.SetTable(Rec6);
                    if Page.RunModal(0, Rec6) = Action::LookupOK then
                        pRecordRef.GetTable(Rec6);
                end;
            Database::Language:
                begin
                    pRecordRef.SetTable(Rec8);
                    if Page.RunModal(0, Rec8) = Action::LookupOK then
                        pRecordRef.GetTable(Rec8);
                end;
            Database::"Country/Region":
                begin
                    pRecordRef.SetTable(Rec9);
                    if Page.RunModal(0, Rec9) = Action::LookupOK then
                        pRecordRef.GetTable(Rec9);
                end;
            Database::"Shipment Method":
                begin
                    pRecordRef.SetTable(Rec10);
                    if Page.RunModal(0, Rec10) = Action::LookupOK then
                        pRecordRef.GetTable(Rec10);
                end;
            Database::"Salesperson/Purchaser":
                begin
                    pRecordRef.SetTable(Rec13);
                    if Page.RunModal(0, Rec13) = Action::LookupOK then
                        pRecordRef.GetTable(Rec13);
                end;
            Database::Location:
                begin
                    pRecordRef.SetTable(Rec14);
                    if Page.RunModal(0, Rec14) = Action::LookupOK then
                        pRecordRef.GetTable(Rec14);
                end;
            Database::"G/L Account":
                begin
                    pRecordRef.SetTable(Rec15);
                    if Page.RunModal(0, Rec15) = Action::LookupOK then
                        pRecordRef.GetTable(Rec15);
                end;
            Database::"Customer":
                begin
                    pRecordRef.SetTable(Rec18);
                    if Page.RunModal(0, Rec18) = Action::LookupOK then
                        pRecordRef.GetTable(Rec18);
                end;
            Database::"Vendor":
                begin
                    pRecordRef.SetTable(Rec23);
                    if Page.RunModal(0, Rec23) = Action::LookupOK then
                        pRecordRef.GetTable(Rec23);
                end;
            Database::"Item":
                begin
                    pRecordRef.SetTable(Rec27);
                    if Page.RunModal(0, Rec27) = Action::LookupOK then
                        pRecordRef.GetTable(Rec27);
                end;
            Database::"Gen. Journal Template":
                begin
                    pRecordRef.SetTable(Rec80);
                    if Page.RunModal(0, Rec80) = Action::LookupOK then
                        pRecordRef.GetTable(Rec80);
                end;
            Database::"Item Journal Template":
                begin
                    pRecordRef.SetTable(Rec82);
                    if Page.RunModal(0, Rec82) = Action::LookupOK then
                        pRecordRef.GetTable(Rec82);
                end;
            Database::"Customer Posting Group":
                begin
                    pRecordRef.SetTable(Rec92);
                    if Page.RunModal(0, Rec92) = Action::LookupOK then
                        pRecordRef.GetTable(Rec92);
                end;
            Database::"Vendor Posting Group":
                begin
                    pRecordRef.SetTable(Rec93);
                    if Page.RunModal(0, Rec93) = Action::LookupOK then
                        pRecordRef.GetTable(Rec93);
                end;
            Database::"Inventory Posting Group":
                begin
                    pRecordRef.SetTable(Rec94);
                    if Page.RunModal(0, Rec94) = Action::LookupOK then
                        pRecordRef.GetTable(Rec94);
                end;
            Database::"Resource Group":
                begin
                    pRecordRef.SetTable(Rec152);
                    if Page.RunModal(0, Rec152) = Action::LookupOK then
                        pRecordRef.GetTable(Rec152);
                end;
            Database::"Resource":
                begin
                    pRecordRef.SetTable(Rec156);
                    if Page.RunModal(0, Rec156) = Action::LookupOK then
                        pRecordRef.GetTable(Rec156);
                end;
            Database::"Job":
                begin
                    pRecordRef.SetTable(Rec167);
                    if Page.RunModal(0, Rec167) = Action::LookupOK then
                        pRecordRef.GetTable(Rec167);
                end;
            Database::"Work Type":
                begin
                    pRecordRef.SetTable(Rec200);
                    if Page.RunModal(0, Rec200) = Action::LookupOK then
                        pRecordRef.GetTable(Rec200);
                end;
            Database::"Unit of Measure":
                begin
                    pRecordRef.SetTable(Rec204);
                    if Page.RunModal(0, Rec204) = Action::LookupOK then
                        pRecordRef.GetTable(Rec204);
                end;
            Database::"Res. Journal Template":
                begin
                    pRecordRef.SetTable(Rec206);
                    if Page.RunModal(0, Rec206) = Action::LookupOK then
                        pRecordRef.GetTable(Rec206);
                end;
            Database::"Job Posting Group":
                begin
                    pRecordRef.SetTable(Rec208);
                    if Page.RunModal(0, Rec208) = Action::LookupOK then
                        pRecordRef.GetTable(Rec208);
                end;
            Database::"Job Journal Template":
                begin
                    pRecordRef.SetTable(Rec209);
                    if Page.RunModal(0, Rec209) = Action::LookupOK then
                        pRecordRef.GetTable(Rec209);
                end;
            Database::"Source Code":
                begin
                    pRecordRef.SetTable(Rec230);
                    if Page.RunModal(0, Rec230) = Action::LookupOK then
                        pRecordRef.GetTable(Rec230);
                end;
            Database::"Reason Code":
                begin
                    pRecordRef.SetTable(Rec231);
                    if Page.RunModal(0, Rec231) = Action::LookupOK then
                        pRecordRef.GetTable(Rec231);
                end;
            Database::"Gen. Business Posting Group":
                begin
                    pRecordRef.SetTable(Rec250);
                    if Page.RunModal(0, Rec250) = Action::LookupOK then
                        pRecordRef.GetTable(Rec250);
                end;
            Database::"Gen. Product Posting Group":
                begin
                    pRecordRef.SetTable(Rec251);
                    if Page.RunModal(0, Rec251) = Action::LookupOK then
                        pRecordRef.GetTable(Rec251);
                end;
            Database::"General Posting Setup":
                begin
                    pRecordRef.SetTable(Rec252);
                    if Page.RunModal(0, Rec252) = Action::LookupOK then
                        pRecordRef.GetTable(Rec252);
                end;
            Database::"Transaction Type":
                begin
                    pRecordRef.SetTable(Rec258);
                    if Page.RunModal(0, Rec258) = Action::LookupOK then
                        pRecordRef.GetTable(Rec258);
                end;
            Database::"Transport Method":
                begin
                    pRecordRef.SetTable(Rec259);
                    if Page.RunModal(0, Rec259) = Action::LookupOK then
                        pRecordRef.GetTable(Rec259);
                end;
            Database::"Bank Account":
                begin
                    pRecordRef.SetTable(Rec270);
                    if Page.RunModal(0, Rec270) = Action::LookupOK then
                        pRecordRef.GetTable(Rec270);
                end;
            Database::Territory:
                begin
                    pRecordRef.SetTable(Rec286);
                    if Page.RunModal(0, Rec286) = Action::LookupOK then
                        pRecordRef.GetTable(Rec286);
                end;
            Database::"Payment Method":
                begin
                    pRecordRef.SetTable(Rec289);
                    if Page.RunModal(0, Rec289) = Action::LookupOK then
                        pRecordRef.GetTable(Rec289);
                end;
            Database::"Shipping Agent":
                begin
                    pRecordRef.SetTable(Rec291);
                    if Page.RunModal(0, Rec291) = Action::LookupOK then
                        pRecordRef.GetTable(Rec291);
                end;
            Database::"Reminder Terms":
                begin
                    pRecordRef.SetTable(Rec292);
                    if Page.RunModal(0, Rec292) = Action::LookupOK then
                        pRecordRef.GetTable(Rec292);
                end;
            Database::"No. Series":
                begin
                    pRecordRef.SetTable(Rec308);
                    if Page.RunModal(0, Rec308) = Action::LookupOK then
                        pRecordRef.GetTable(Rec308);
                end;
            Database::"Customer Discount Group":
                begin
                    pRecordRef.SetTable(Rec340);
                    if Page.RunModal(0, Rec340) = Action::LookupOK then
                        pRecordRef.GetTable(Rec340);
                end;
            Database::"Item Discount Group":
                begin
                    pRecordRef.SetTable(Rec341);
                    if Page.RunModal(0, Rec341) = Action::LookupOK then
                        pRecordRef.GetTable(Rec341);
                end;
            Database::Dimension:
                begin
                    pRecordRef.SetTable(Rec348);
                    if Page.RunModal(0, Rec348) = Action::LookupOK then
                        pRecordRef.GetTable(Rec348);
                end;
            Database::"IC Partner":
                begin
                    pRecordRef.SetTable(Rec413);
                    if Page.RunModal(0, Rec413) = Action::LookupOK then
                        pRecordRef.GetTable(Rec413);
                end;
            Database::"VAT Business Posting Group":
                begin
                    pRecordRef.SetTable(Rec323);
                    if Page.RunModal(0, Rec323) = Action::LookupOK then
                        pRecordRef.GetTable(Rec323);
                end;
            Database::"VAT Product Posting Group":
                begin
                    pRecordRef.SetTable(Rec324);
                    if Page.RunModal(0, Rec324) = Action::LookupOK then
                        pRecordRef.GetTable(Rec324);
                end;
            Database::"VAT Posting Setup":
                begin
                    pRecordRef.SetTable(Rec325);
                    if Page.RunModal(0, Rec325) = Action::LookupOK then
                        pRecordRef.GetTable(Rec325);
                end;
            Database::"Job WIP Method":
                begin
                    pRecordRef.SetTable(Rec1006);
                    if Page.RunModal(0, Rec1006) = Action::LookupOK then
                        pRecordRef.GetTable(Rec1006);
                end;
            Database::"Contact":
                begin
                    pRecordRef.SetTable(Rec5050);
                    if Page.RunModal(0, Rec5050) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5050);
                end;
            Database::"Business Relation":
                begin
                    pRecordRef.SetTable(Rec5053);
                    if Page.RunModal(0, Rec5053) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5053);
                end;
            Database::"Industry Group":
                begin
                    pRecordRef.SetTable(Rec5057);
                    if Page.RunModal(0, Rec5057) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5057);
                end;
            Database::"Job Responsibility":
                begin
                    pRecordRef.SetTable(Rec5066);
                    if Page.RunModal(0, Rec5066) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5066);
                end;
            Database::Salutation:
                begin
                    pRecordRef.SetTable(Rec5068);
                    if Page.RunModal(0, Rec5068) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5068);
                end;
            Database::"Organizational Level":
                begin
                    pRecordRef.SetTable(Rec5070);
                    if Page.RunModal(0, Rec5070) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5070);
                end;
            Database::"Employee":
                begin
                    pRecordRef.SetTable(Rec5200);
                    if Page.RunModal(0, Rec5200) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5200);
                end;
            Database::Qualification:
                begin
                    pRecordRef.SetTable(Rec5202);
                    if Page.RunModal(0, Rec5202) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5202);
                end;
            Database::Relative:
                begin
                    pRecordRef.SetTable(Rec5204);
                    if Page.RunModal(0, Rec5204) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5204);
                end;
            Database::"Cause of Absence":
                begin
                    pRecordRef.SetTable(Rec5206);
                    if Page.RunModal(0, Rec5206) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5206);
                end;
            Database::Union:
                begin
                    pRecordRef.SetTable(Rec5209);
                    if Page.RunModal(0, Rec5209) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5209);
                end;
            Database::"Cause of Inactivity":
                begin
                    pRecordRef.SetTable(Rec5210);
                    if Page.RunModal(0, Rec5210) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5210);
                end;
            Database::"Employment Contract":
                begin
                    pRecordRef.SetTable(Rec5211);
                    if Page.RunModal(0, Rec5211) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5211);
                end;
            Database::"Employee Statistics Group":
                begin
                    pRecordRef.SetTable(Rec5212);
                    if Page.RunModal(0, Rec5212) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5212);
                end;
            Database::"Misc. Article":
                begin
                    pRecordRef.SetTable(Rec5213);
                    if Page.RunModal(0, Rec5213) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5213);
                end;
            Database::Confidential:
                begin
                    pRecordRef.SetTable(Rec5215);
                    if Page.RunModal(0, Rec5215) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5215);
                end;
            Database::"Grounds for Termination":
                begin
                    pRecordRef.SetTable(Rec5217);
                    if Page.RunModal(0, Rec5217) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5217);
                end;
            Database::"Fixed Asset":
                begin
                    pRecordRef.SetTable(Rec5600);
                    if Page.RunModal(0, Rec5600) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5600);
                end;
            Database::"FA Class":
                begin
                    pRecordRef.SetTable(Rec5607);
                    if Page.RunModal(0, Rec5607) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5607);
                end;
            Database::"FA Location":
                begin
                    pRecordRef.SetTable(Rec5609);
                    if Page.RunModal(0, Rec5609) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5609);
                end;
            Database::"Responsibility Center":
                begin
                    pRecordRef.SetTable(Rec5714);
                    if Page.RunModal(0, Rec5714) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5714);
                end;
            Database::Manufacturer:
                begin
                    pRecordRef.SetTable(Rec5720);
                    if Page.RunModal(0, Rec5720) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5720);
                end;
            Database::Purchasing:
                begin
                    pRecordRef.SetTable(Rec5721);
                    if Page.RunModal(0, Rec5721) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5721);
                end;
            Database::"Item Category":
                begin
                    pRecordRef.SetTable(Rec5722);
                    if Page.RunModal(0, Rec5722) = Action::LookupOK then
                        pRecordRef.GetTable(Rec5722);
                end;
            Database::"Config. Template Header":
                begin
                    pRecordRef.SetTable(Rec8618);
                    if Page.RunModal(0, Rec8618) = Action::LookupOK then
                        pRecordRef.GetTable(Rec8618);
                end;
            else
                OnLookupRecordRef(pRecordRef, IsHandled);
                exit(IsHandled);
        end;
        exit(pRecordRef.Number <> 0);
    end;

    /* Obsolete ?
    local procedure LookupDefaultValue(pTableID: Integer; pFieldID: Integer; var pValue: Text)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Code20: Code[20];
        Int: Integer;
    begin
        if pFieldID <> 0 then begin
            RecRef.Open(pTableID, true);
            FldRef := RecRef.Field(pFieldID);
            if FldRef.Relation <> 0 then begin
                Code20 := pValue;
                if Lookup(pTableID, pFieldID, Code20) then
                    pValue := Code20;
            end else
                if Format(FldRef.Type) = 'Option' then begin
                    if pValue <> '' then
                        Evaluate(Int, pValue);
                    Int := StrMenu(Format(FldRef.OptionCaption), Int + 1);
                    if Int <> 0 then
                        pValue := Format(Int - 1);
                end else
                    if Format(FldRef.Type) = 'Boolean' then begin
                        if pValue <> '' then
                            Evaluate(Int, pValue);
                        Int := StrMenu(Format(false) + ',' + Format(true), Int + 1);
                        if Int <> 0 then
                            pValue := Format(Int - 1);
                    end;
        end;
    end;
    */

    [IntegrationEvent(false, false)]
    local procedure OnLookupRecordRef(pRecordRef: RecordRef; pGot: Boolean)
    begin
    end;
}
