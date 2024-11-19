codeunit 87097 "WanaPort Progress"
{
    var
        ProgressDialog: Dialog;
        StartDateTime: DateTime;
        UpdateDateTime: DateTime;
        Current: Integer;

    procedure Open(pCaption: Text; pMax: Integer)
    var
        ProgressMaxMsg: Label '#1###### out of #2#######', Comment = '#1######=current;#2#######=max';
    begin
        Start(pCaption, ProgressMaxMsg, pMax);
    end;

    procedure Open(pCaption: Text)
    var
        ProgressMsg: Label '#1######', Comment = '#1######=current';
    begin
        Start(pCaption, ProgressMsg, 0);
    end;

    local procedure Start(pCaption: Text; pProgressMsg: Text; pMax: Integer)
    var
        DefaultCaptionMsg: Label 'Processing';
        EllipsisLbl: Label '...\', Locked = true;
    begin
        if not GuiAllowed then
            exit;
        Current := 0;
        if pCaption = '' then
            pCaption := DefaultCaptionMsg;
        ProgressDialog.Open(pCaption + EllipsisLbl + pProgressMsg, Current, pMax);
        StartDateTime := CurrentDateTime;
        UpdateDateTime := CurrentDateTime;
    end;

    procedure Update()
    begin
        Current += 1;
        if CurrentDateTime - UpdateDateTime >= 1000 then begin
            UpdateDateTime := CurrentDateTime;
            ProgressDialog.Update(1, Current);
        end;
    end;

    procedure Done(pCaption: Text)
    var
        DoneMsg: Label '%1 %2 in %3', Comment = '%1:count, %2:Caption, %3:ElapsedTime';
        DefaultCaption: Label 'Line(s) processed';
    begin
        if not GuiAllowed then
            exit;
        if pCaption = '' then
            pCaption := DefaultCaption;
        Message(DoneMsg, Current, pCaption, CurrentDateTime - StartDateTime)
    end;
}
