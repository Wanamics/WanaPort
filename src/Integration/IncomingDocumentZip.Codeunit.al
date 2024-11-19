namespace Wanamics.WanaPort;

using Microsoft.EServices.EDocument;
using System.IO;
using System.Utilities;

codeunit 87080 "WanaPort Incoming Document.Zip"
{
    TableNo = "Incoming Document";
    trigger OnRun()
    // inspired by https://yzhums.com/21483/
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        Window: Dialog;
        ZipFileName: Text;
        ZipInStream: InStream;
        FileList: List of [Text];
        FileName: Text;
        FileInStream: InStream;
        Length: Integer;
        SelectZIPFileMsg: Label 'Select ZIP File';
        ImportedMsg: Label '%1 "%2" imported successfully.', Comment = '%1:FileCount, %2:IncomingDocument.TableCaption';
    begin
        if not UploadIntoStream(SelectZIPFileMsg, '', 'Zip Files|*.zip', ZipFileName, ZipInStream) then
            Error('');

        DataCompression.OpenZipArchive(ZipInStream, false);
        DataCompression.GetEntryList(FileList);

        if GuiAllowed then
            Window.Open('#1##############################');
        foreach FileName in FileList do begin
            Length := DataCompression.ExtractEntry(FileName, TempBlob);
            TempBlob.CreateInStream(FileInStream);

            if GuiAllowed then
                Window.Update(1, FileName);
            Rec.CreateIncomingDocument(FileInStream, FileName);
            OnBeforeModify(Rec);
            CheckDuplicate(Rec);
            Rec.Modify(true);
        end;

        DataCompression.CloseZipArchive();
        if GuiAllowed then
            Window.Close();

        if GuiAllowed then
            if FileList.Count > 0 then
                Message(ImportedMsg, FileList.Count, Rec.TableCaption);
    end;

    local procedure CheckDuplicate(pIncomingDocument: Record "Incoming Document")
    var
        IncomingDocument: Record "Incoming Document";
        AlreadyExistsErr: Label '%1 %2 already exists (%3 %4).', Comment = '%1:"Document Type", %2: "Document No.", %3:FieldCaption."Entry No.", %4:"Entry No."';
    begin
        if pIncomingDocument."Document No." = '' then
            exit;
        IncomingDocument.SetCurrentKey("Document No.");
        IncomingDocument.SetRange("Document No.", pIncomingDocument."Document No.");
        IncomingDocument.SetRange("Document Type", pIncomingDocument."Document Type");
        if IncomingDocument.FindFirst() then
            Error(AlreadyExistsErr, IncomingDocument."Document Type", IncomingDocument."Document No.", IncomingDocument.FieldCaption("Entry No."), IncomingDocument."Entry No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var pRec: Record "Incoming Document")
    begin
    end;
}
