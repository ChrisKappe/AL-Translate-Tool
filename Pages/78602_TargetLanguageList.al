page 78602 "BAC Target Language List"
{
    PageType = List;
    SourceTable = "BAC Target Language";
    Caption = 'Target Language List';
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Project Name"; "Project Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language"; "Source Language")
                {
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language ISO code"; "Source Language ISO code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }

                field("Target Language"; "Target Language")
                {
                    ApplicationArea = All;
                }
                field("Target Language ISO code"; "Target Language ISO code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Translation Target")
            {
                Caption = 'Translation Target';
                ApplicationArea = All;
                Image = Translate;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "BAC Translation Target List";
                RunPageLink = "Project Code" = field ("Project Code"),
                            "Target Language" = field ("Target Language"),
                            "Target Language ISO code" = field ("Target Language ISO code");
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
                begin
                    if Confirm(WarningTxt) then begin
                        ExportTranslation.SetProjectCode("Project Code", "Source Language ISO code", "Target Language ISO code");
                        ExportTranslation.Run();
                    end;
                end;

            }
            action("Import Target")
            {
                ApplicationArea = All;
                Caption = 'Import Target';
                Image = ImportLog;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ImportTargetXML: XmlPort "BAC Import Translation Target";
                    TransTarget: Record "BAC Translation Target";
                    DeleteWarningTxt: Label 'This will overwrite the Translation target for %1';
                begin
                    TransTarget.SetRange("Project Code", "Project Code");
                    if not TransTarget.IsEmpty then
                        if Confirm(DeleteWarningTxt, false, "Project Code") then begin
                            TransTarget.DeleteAll();
                        end else
                            exit;
                    ImportTargetXML.SetProjectCode(Rec."Project Code", "Source Language ISO code", "Target Language ISO code");
                    ImportTargetXML.Run();
                end;
            }
        }
    }
}