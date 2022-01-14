unit main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Net.HttpClientComponent,
  System.Net.HttpClient,
  System.JSON,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  Rest.JSON, Vcl.ComCtrls, acPNG, Vcl.ExtCtrls;

const
  URL = 'http://viacep.com.br/ws/';
  Extension = '/json/';

type
  TCEP = class
  private
    FCEP: String;
    FDDD: String;
    FUF: String;
    FErro: Boolean;
    FLogradouro: String;
    FBairro: String;
    FLocalidade: String;
    procedure SetCEP(const Value: String);
    procedure SetDDD(const Value: String);
    procedure SetUF(const Value: String);
    procedure SetErro(const Value: Boolean);
    procedure SetBairro(const Value: String);
    procedure SetLocalidade(const Value: String);
    procedure SetLogradouro(const Value: String);
  public
    property CEP: String Read FCEP write SetCEP;
    property Logradouro: String Read FLogradouro write SetLogradouro;
    property Bairro: String Read FBairro write SetBairro;
    property Localidade: String Read FLocalidade write SetLocalidade;
    property UF: String Read FUF write SetUF;
    property DDD: String Read FDDD write SetDDD;
    property Erro: Boolean Read FErro write SetErro;
  end;

type
  TGetCEP = class
  public
    class procedure GetCep(ACep: String; var pRetorno: String);
  end;

type
  TFormSearchCEP = class(TForm)
    edtCEP: TEdit;
    btSearch: TButton;
    edtPublicPlace: TEdit;
    edtDstrict: TEdit;
    edtLocation: TEdit;
    edtUF: TEdit;
    edtDDD: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    StatusBar: TStatusBar;
    procedure btSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSearchCEP: TFormSearchCEP;

implementation

{$R *.dfm}

procedure TFormSearchCEP.btSearchClick(Sender: TObject);
var
  CEP: TCEP;
  LReturn: String;
begin
  TGetCEP.GetCep(edtCEP.Text, LReturn);
end;

{ TCEP }

procedure TCEP.SetBairro(const Value: String);
begin
  FBairro := Value;
end;

procedure TCEP.SetCEP(const Value: String);
begin
  FCEP := Value;
end;

procedure TCEP.SetDDD(const Value: String);
begin
  FDDD := Value;
end;

procedure TCEP.SetErro(const Value: Boolean);
begin
  FErro := Value;
end;

procedure TCEP.SetLocalidade(const Value: String);
begin
  FLocalidade := Value;
end;

procedure TCEP.SetLogradouro(const Value: String);
begin
  FLogradouro := Value;
end;

procedure TCEP.SetUF(const Value: String);
begin
  FUF := Value;
end;

{ TGetCEP }

class procedure TGetCEP.GetCep(ACep: String; var pRetorno: String);
var
  httpRequest: TNetHTTPRequest;
  HttpClient: TNetHTTPClient;
  response: IHTTPResponse;
  objCEP: TCEP;
begin
  FormSearchCEP.StatusBar.Panels[0].Text := 'Status: Buscando...';

  try
    if ACep.Trim.Length <> 8 then
      MessageDlg('CEP incorreto', mtError, [mbOk], 0);

    try
      httpRequest := TNetHTTPRequest.Create(nil);
      HttpClient := TNetHTTPClient.Create(nil);
      httpRequest.Client := HttpClient;

      response := httpRequest.Get(URL + ACep + Extension);

      if response.StatusCode = 200 then
      begin
        FormSearchCEP.StatusBar.Panels[0].Text := 'Status: Sucesso';

        objCEP := TJson.JsonToObject<TCEP>
          (TJSONObject(TJSONObject.ParseJSONValue(response.ContentAsString())));

        if objCEP.Erro then
          MessageDlg('CEP não localizado', mtError, [mbOk], 0)
        else
        begin
          pRetorno := response.ContentAsString();

          FormSearchCEP.edtPublicPlace.Text := objCEP.FLogradouro;
          FormSearchCEP.edtDstrict.Text := objCEP.FBairro;
          FormSearchCEP.edtLocation.Text := objCEP.FLocalidade;
          FormSearchCEP.edtUF.Text := objCEP.FUF;
          FormSearchCEP.edtDDD.Text := objCEP.FDDD;
        end;
      end
      else
      begin
        FormSearchCEP.StatusBar.Panels[0].Text := 'Status: Erro!';
        MessageDlg(response.StatusText, mtError, [mbOk], 0);
      end;
    finally
      FreeAndNil(httpRequest);
      FreeAndNil(HttpClient);
      if Assigned(objCEP) then
        FreeAndNil(objCEP);
    end;
  except
    on E: Exception do
    begin
      pRetorno := E.Message;
    end;
  end;
end;

procedure TFormSearchCEP.FormShow(Sender: TObject);
begin
  FormSearchCEP.StatusBar.Panels[0].Text := 'Status: Aguardando...';
end;

end.
