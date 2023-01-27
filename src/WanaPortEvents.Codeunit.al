codeunit 87093 "WanaPort Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Export File", 'OnBeforeBLOBExport', '', false, false)]
    local procedure OnBeforeBLOBExport(var TempBlob: Codeunit "Temp Blob"; CreditTransferRegister: Record "Credit Transfer Register"; UseComonDialog: Boolean; var FieldCreated: Boolean; var IsHandled: Boolean)
    var
        WanaPort: Record WanaPort;
    begin
        if WanaPort.Get(WanaPort."Object Type"::Codeunit, Codeunit::"SEPA CT-Export File") and (WanaPort."Export Path" <> '') then
            IsHandled := WanaPort.Export(TempBlob);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA DD-Export File", 'OnExportOnAfterXMLPortExport', '', false, false)]
    local procedure OnExportOnAfterXMLPortExport(var TempBlob: Codeunit "Temp Blob"; var Result: Boolean; var IsHandled: Boolean)
    var
        WanaPort: Record WanaPort;
    begin
        if WanaPort.Get(WanaPort."Object Type"::Codeunit, Codeunit::"SEPA CT-Export File") and (WanaPort."Export Path" <> '') then
            IsHandled := WanaPort.Export(TempBlob);
    end;
}
