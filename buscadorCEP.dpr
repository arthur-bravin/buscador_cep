program buscadorCEP;

uses
  Vcl.Forms,
  main in 'main.pas' {FormSearchCEP};

{$R *.res}

begin
  { Arthur Bravin Pereira }
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSearchCEP, FormSearchCEP);
  Application.Run;
end.
