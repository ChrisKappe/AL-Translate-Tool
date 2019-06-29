page 78603 "BAC Translation Target List"
{
    Caption = 'Translation Target List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BAC Translation Target";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Trans-Unit Id"; "Trans-Unit Id")
                {
                    ApplicationArea = All;
                }
                field(Source; Source)
                {
                    ApplicationArea = All;
                }
                field(Translate2; Translate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the Translate field to no if you don''t want it to be translated';
                }
                field(Target; Target)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translated text';
                }
            }
        }
        area(Factboxes)
        {
            part(TransNotes; "BAC Translation Notes")
            {
                SubPageLink = "Project Code" = field ("Project Code"),
                            "Trans-Unit Id" = field ("Trans-Unit Id");
                Editable = false;
            }
            part(TargetFactbox; "BAC Trans Target Factbox")
            {
                SubPageLink = "Project Code" = field ("Project Code"),
                            "Trans-Unit Id" = field ("Trans-Unit Id");
            }

        }

    }

    actions
    {
        area(Processing)
        {
            action("Translate")
            {
                ApplicationArea = All;
                Caption = 'Translate';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    GoogleTranslate: Codeunit "BAC Google Translate Rest";
                    Project: Record "BAC Translation Project Name";
                begin
                    Project.get("Project Code");
                    Target := GoogleTranslate.Translate(Project."Source Language ISO code",
                                              "Target Language ISO code",
                                              Source);
                    Target := ReplaceTermInTranslation(Target);
                    Validate(Target);
                end;
            }
            action("Translate All")
            {
                ApplicationArea = All;
                Caption = 'Translate All';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    MenuSelectionTxt: Label 'Convert all,Convert only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            TranslateAll(false);

                        2:
                            TranslateAll(true);
                    end;
                end;
            }
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    WarningTxt: Label 'Mark all untranslated lines to be translated?';
                    TransTarget: Record "BAC Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then
                        TransTarget.Reset();
                    TransTarget.SetRange(Target, '');
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, true);
                    CurrPage.Update(false);

                end;
            }
            action("Deselect All")
            {
                ApplicationArea = All;
                Caption = 'Deselect All';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    WarningTxt: Label 'Remove mark from all lines and disable translation?';
                    TransTarget: Record "BAC Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then
                        TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, false);
                    CurrPage.Update(false);
                end;
            }
            action("Clear All translations")
            {
                ApplicationArea = All;
                Caption = 'Clear All translations';
                Image = RemoveLine;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    WarningTxt: Label 'Remove all translations?';
                begin
                    if Confirm(WarningTxt) then
                        ModifyAll(Target, '');
                end;
            }
            action("Export Translation File")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    WarningTxt: Label 'Export the Translation file?';
                    ExportTranslation: XmlPort "BAC Export Translation Target";
                    TransProject: Record "BAC Translation Project Name";
                begin
                    if Confirm(WarningTxt) then begin
                        TransProject.get("Project Code");
                        ExportTranslation.SetProjectCode("Project Code", TransProject."Source Language ISO code", "Target Language ISO code");
                        ExportTranslation.Run();
                    end;
                end;

            }
            action("Translation Terms")
            {
                Caption = 'Translation Terms';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                RunObject = page "BAC Translation terms";
                RunPageLink = "Project Code" = field ("Project Code"),
                            "Target Language" = field ("Target Language");
            }
        }
    }

    trigger OnOpenPage()
    var
        TransSource: Record "BAC Translation Source";
        TransTarget: Record "BAC Translation Target";
    begin
        TransSource.SetFilter("Project Code", GetFilter("Project Code"));
        if TransSource.FindSet() then
            repeat
                TransTarget.TransferFields(TransSource);
                TransTarget."Target Language" := GetFilter("Target Language");
                TransTarget."Target Language ISO code" := GetFilter("Target Language ISO code");
                if TransTarget.Insert() then;
            until TransSource.Next() = 0;
    end;

    local procedure TranslateAll(inOnlyEmpty: Boolean)
    var
        GoogleTranslate: Codeunit "BAC Google Translate Rest";
        TransTarget: Record "BAC Translation Target";
        Project: Record "BAC Translation Project Name";
        Window: Dialog;
        DialogTxt: Label 'Converting #1###### of #2######';
        Counter: Integer;
        TotalCount: Integer;
    begin
        if inOnlyEmpty then
            TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TotalCount := TransTarget.Count;
        Project.get("Project Code");
        if TransTarget.FindSet(true, true) then begin
            Window.Open(DialogTxt);
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                TransTarget.Target := GoogleTranslate.Translate(Project."Source Language ISO code",
                                          "Target Language ISO code",
                                          TransTarget.Source);
                TransTarget.Target := ReplaceTermInTranslation(TransTarget.Target);
                TransTarget.Validate(Target);
                TransTarget.Modify();
                sleep(1000);
                commit();
                SelectLatestVersion();
            until TransTarget.Next() = 0;
        end;

    end;

    local procedure ReplaceTermInTranslation(inTarget: Text[250]) outTarget: Text[250]
    var
        TransTerm: Record "BAC Translation Term";
        StartPos: Integer;
        Found: Boolean;
    begin
        if TransTerm.FindSet() then
            repeat
                StartPos := strpos(LowerCase(inTarget), LowerCase(TransTerm.Term));
                if StartPos > 0 then begin
                    if (StartPos > 1) then begin
                        outTarget := CopyStr(inTarget, 1, StartPos - 1) +
                                     TransTerm.Translation +
                                     CopyStr(inTarget, StartPos + strlen(TransTerm.Term));
                        Found := true;
                    end else begin
                        outTarget := TransTerm.Translation +
                                     CopyStr(inTarget, strlen(TransTerm.Term) + 1);
                        Found := true;
                    end;
                end;
                if Found then
                    inTarget := outTarget;
            until TransTerm.Next() = 0;
        if not Found then
            outTarget := inTarget;
    end;
}