page 78609 "BAC About AL Translation Tool"
{
    Caption='About AL Translation Tool';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BAC Translation Setup";
    
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Version;Version)
                {
                    ApplicationArea = All;
                    
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                
                trigger OnAction()
                begin
                    
                end;
            }
        }
    }
    
    var
        myInt: Integer;
}