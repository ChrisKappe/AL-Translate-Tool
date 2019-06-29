xmlport 78602 "BAC Import Translation Target"
{
    Caption = 'Import Translation Target';
    DefaultNamespace = 'urn:oasis:names:tc:xliff:document:1.2';
    Direction = Import;
    Encoding = UTF16;
    XmlVersionNo = V10;
    Format = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(xliff)
        {
            textattribute(version)
            {
            }
            textelement(infile)
            {
                XmlName = 'file';
                textattribute(datatype)
                {
                }
                textattribute("source-language")
                {
                }
                textattribute("target-language")
                {
                    trigger OnAfterAssignVariable()
                    begin
                        Target.TestField("Target Language ISO code", TargetLangCode);
                    end;
                }
                textattribute(original)
                {
                }
                textelement(body)
                {
                    textelement(group)
                    {
                        textattribute(id1)
                        {
                            XmlName = 'id';
                        }
                        tableelement(Target; "BAC Translation Target")
                        {
                            XmlName = 'trans-unit';

                            fieldattribute(id; Target."Trans-Unit Id")
                            {
                            }
                            textattribute("size-unit")
                            {
                            }
                            textattribute(translate)
                            {
                            }
                            fieldelement(source; Target.Source)
                            {
                            }

                            textelement(note)
                            {
                                textattribute(from)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.From := from;
                                        CreateTranNote();
                                    end;
                                }
                                textattribute(annotates)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.Annotates := annotates;
                                    end;
                                }
                                textattribute(priority)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.Priority := priority;
                                    end;
                                }
                                trigger OnAfterAssignVariable()
                                begin
                                    TransNotes.Note := note;
                                    CreateTranNote();
                                end;

                            }
                            fieldelement(target; Target.Target)
                            {
                            }

                            trigger OnBeforeInsertRecord()
                            begin
                                if ProjectCode = '' then
                                    error(MissingProjNameTxt);
                                Target."Project Code" := ProjectCode;
                            end;

                        }
                    }
                }
            }
        }
    }

    var
        ProjectCode: Code[10];
        TargetLangCode: Text[10];
        SourceLangCode: Text[10];
        MissingProjNameTxt: Label 'Project Name is Missing';
        TransNotes: Record "BAC Translation Notes";

    trigger OnPostXmlPort()
    var
        TransProject: Record "BAC Translation Project Name";
    begin
        with TransProject do begin
            get(ProjectCode);
            "File Name" := currXMLport.Filename();
            while (StrPos("File Name", '\') > 0) do
                "File Name" := CopyStr("File Name", StrPos("File Name", '\') + 1);
            Modify();
        end;
    end;

    procedure SetProjectCode(inProjectCode: Code[10]; inSourceLangCode: text[10]; inTargetLangCode: Text[10])
    begin
        ProjectCode := inProjectCode;
        TargetLangCode := inTargetLangCode;
        SourceLangCode := inSourceLangCode;
    end;

    local procedure CreateTranNote()
    begin
        if (TransNotes.From <> '') and
           (TransNotes.Annotates <> '') and
           (TransNotes.Priority <> '') then begin
            TransNotes."Project Code" := ProjectCode;
            TransNotes."Trans-Unit Id" := Target."Trans-Unit Id";
            if TransNotes.Insert() then;
            clear(TransNotes);
        end;
    end;
}

