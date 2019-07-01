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
            group(General)
            {
                Caption = 'General';
                field("Default Source Language code"; "Default Source Language code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Languange to be defaulted on every project';
                }
                field("Use Free Google Translate"; "Use Free Google Translate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Use the free Google API for translation. The limitation is that it is only possible to access the API a limited number of times each hour.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Project Nos."; "Project Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. Series to be used with Projects';
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