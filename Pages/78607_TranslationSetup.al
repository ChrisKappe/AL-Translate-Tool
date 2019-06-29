page 78607 "BAC Translation Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BAC Translation Setup";
    Caption = 'Translation Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field("Default Source Language code"; "Default Source Language code")
                {
                    ApplicationArea = All;

                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Project Nos."; "Project Nos.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not get() then begin
            init();
            Insert();
        end;
    end;
}