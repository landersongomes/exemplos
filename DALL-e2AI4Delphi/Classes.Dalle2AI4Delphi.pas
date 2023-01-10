unit Classes.Dalle2AI4Delphi;

interface
{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes,
  FMX.Graphics,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  Data.DB;

CONST
  APIKEY = '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'; //Default API KEY
  SIZE1024 = '1024x1024';
  SIZE512 = '512x512';
  SIZE256 = '256x256';


type
  TDalle2AI4Delphi = class(TComponent)
  private
    FHttp: THttpClient;
    FResponse : IHTTPResponse;
    FSecretKey: string;
    FPrompt: string;
    FNumber: Integer;
    FBaseURL: string;
    FResource: string;
    FSize: string;
    FResponseContent: string;
    procedure SetSecretKey(const Value: string);
    procedure SetNumber(const Value: Integer);
    procedure SetPrompt(const Value: string);
    procedure SetBaseURL(const Value: string);
    procedure SetResource(const Value: string);
    procedure SetSize(const Value: string);
    procedure SetResponseContent(const Value: string);
    procedure SetResponse(const Value: IHTTPResponse);

  protected


  public
    constructor Create(aOwner: TComponent);override;
    destructor Destroy; override;
    procedure SetupDalle(AKey, APrompt, ASize: string;
  ANumber: integer);
    class function GenerateJSONBodyRequest(APrompt, ASize: string;
  ANumber: integer) : String;
    function DoRequest : boolean;
    function ExtractValueJSONProperty(AJSON2Search, APropertyName : string) : string;
    procedure DownloadImage(AURL : string; ABitmap : TBitmap);
    procedure ResponseJSONArrayToDataset(ADataset: TDataset);
  published
    property SecretKey : string read FSecretKey write SetSecretKey;
    property Prompt : string read FPrompt write SetPrompt;
    property Number : Integer read FNumber write SetNumber;
    property BaseURL : string read FBaseURL write SetBaseURL;
    property Resource : string read FResource write SetResource;
    property Size : string read FSize write SetSize;
    property Response : IHTTPResponse read FResponse write SetResponse;
    property ResponseContent : string read FResponseContent write SetResponseContent;
  end;

procedure Register;

implementation

{ TDalle2AI4Delphi }

uses
  System.IOUtils,
  System.NetEncoding,
  System.JSON, System.JSON.Readers, System.JSON.Writers,
  System.JSON.Types,
  REST.Response.Adapter;


constructor TDalle2AI4Delphi.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Self.SetupDalle(Self.SecretKey, 'Spartan man cyber punk', SIZE1024, 1);

end;

destructor TDalle2AI4Delphi.Destroy;
begin

  inherited;
end;

procedure TDalle2AI4Delphi.DownloadImage(AURL: string; ABitmap: TBitmap);
var
  lMemStream : TMemoryStream;
  lHTTPClient : TNetHTTPClient;
  lResponse: IHTTPResponse;
begin
  TThread.Synchronize(TThread.CurrentThread,
  procedure
    begin
      lHTTPClient := TNetHTTPClient.Create(nil);
      try
        lMemStream := TMemoryStream.Create();
        try
            lResponse := lHTTPClient.Get(AURL, lMemStream);
            if lResponse.StatusCode = 200 then
              begin
                  lMemStream.Position := 0;
                  ABitmap.LoadFromStream(lMemStream);
              end;
        finally
            lMemStream.Free;
        end;
      finally
          lHTTPClient.Free;
      end;
    end);
end;

function TDalle2AI4Delphi.ExtractValueJSONProperty(AJSON2Search,
  APropertyName: string): string;
var
  lStringReader: TStringReader;
  lJSONReader: TJsonTextReader;
begin
  lStringReader := TStringReader.Create(AJSON2Search);
  lJSONReader := TJsonTextReader.Create(lStringReader);
  try
    while lJSONReader.Read do
      case lJSONReader.TokenType of
        TJsonToken.PropertyName:
          begin
            if LowerCase(lJSONReader.Value.AsString) = LowerCase(APropertyName) then
            begin
              lJSONReader.Read;
              Result := lJSONReader.Value.ToString;
            end;
          end
      end;
  finally
    lJSONReader.Free;
    lStringReader.Free;
  end;

end;

class function TDalle2AI4Delphi.GenerateJSONBodyRequest(APrompt, ASize: string;
  ANumber: integer) : String;
var
  lJSONWriter : TJsonTextWriter;
  lStringWriter: TStringWriter;
begin
  Result := EmptyStr;
  lStringWriter := TStringWriter.Create();
  lJSONWriter := TJsonTextWriter.Create(lStringWriter);
  lJSONWriter.Formatting := TJsonFormatting.Indented;
  try
    lJSONWriter.WriteStartObject;
    lJSONWriter.WritePropertyName('prompt');
    lJSONWriter.WriteValue(APrompt);
    if not ASize.IsEmpty then
      begin
        lJSONWriter.WritePropertyName('size');
        lJSONWriter.WriteValue(ASize);
      end;
    if ANumber > 1 then
      begin
        lJSONWriter.WritePropertyName('n');
        lJSONWriter.WriteValue(ANumber);
      end;
    lJSONWriter.WriteEndObject;
    Result := lStringWriter.ToString;
  finally
    lJSONWriter.Free;
    lStringWriter.Free;
  end;
 end;

procedure TDalle2AI4Delphi.ResponseJSONArrayToDataset(ADataset: TDataset);
var
  lJSONAdapter : TCustomJSONDataSetAdapter;
  lJO : TJSONObject;
  lJA : TJSONArray;
begin
  lJSONAdapter := TCustomJSONDataSetAdapter.Create(Nil);
  lJSONAdapter.Dataset := ADataset;
  lJO := TJSonObject.ParseJSONValue(Self.ResponseContent) as TJSONObject;
  if lJO <> nil then
    begin
      try
        lJA := lJO.GetValue('data') as TJSONArray;
        lJSONAdapter := TCustomJSONDataSetAdapter.Create(Nil);
        lJSONAdapter.Dataset := ADataset;
        lJSONAdapter.UpdateDataSet(lJA);
      finally
        lJO.Free;
        lJSONAdapter.Free;
      end;
    end;
end;

function TDalle2AI4Delphi.DoRequest: boolean;
var
  lRequest: IHTTPRequest;
  lResponse: IHTTPResponse;
  lBody: TStringStream;
begin
  Result := False;
  try
    if not Assigned(FHttp) then
      begin
        FHttp := THttpClient.Create;
        // allow cookies
        FHttp.AllowCookies := True;
      end;

    lRequest := FHttp.GetRequest('POST', BaseURL + Resource);
    lRequest.AddHeader('content-type', 'application/json');
    lRequest.AddHeader('Authorization', 'Bearer ' + SecretKey);

    lBody := TStringStream.Create(GenerateJSONBodyRequest(Prompt, Size, Number)) ;
    lRequest.SourceStream := lBody;
    lResponse := FHttp.Execute(lRequest);
    FResponse := lResponse;

    if lResponse.StatusCode = 200 then
      begin
        ResponseContent := lResponse.ContentAsString();
        Result := True;
      end
    else
      ResponseContent := Format('%s - %s', [lResponse.StatusCode.ToString, lResponse.StatusText]);


  except on E: Exception do
    raise Exception.Create('Error Message: ' + E.Message);
  end;

end;

procedure TDalle2AI4Delphi.SetBaseURL(const Value: string);
begin
  FBaseURL := Value;
end;

procedure TDalle2AI4Delphi.SetNumber(const Value: Integer);
begin
  FNumber := Value;
end;

procedure TDalle2AI4Delphi.SetPrompt(const Value: string);
begin
  FPrompt := Value;
end;

procedure TDalle2AI4Delphi.SetResource(const Value: string);
begin
  FResource := Value;
end;

procedure TDalle2AI4Delphi.SetResponse(const Value: IHTTPResponse);
begin
  FResponse := Value;
end;

procedure TDalle2AI4Delphi.SetResponseContent(const Value: string);
begin
  FResponseContent := Value;
end;

procedure TDalle2AI4Delphi.SetSecretKey(const Value: string);
begin
  FSecretKey := Value;
end;

procedure TDalle2AI4Delphi.SetSize(const Value: string);
begin
  FSize := Value;
end;

procedure TDalle2AI4Delphi.SetupDalle(AKey, APrompt, ASize: string;
  ANumber: integer);
begin
  BaseURL := 'https://api.openai.com/v1/images/';
  Resource := 'generations';

  SecretKey := AKey;
  Prompt := APrompt;
  Size := ASize;
  Number := ANumber;

end;

procedure Register;
begin
  RegisterComponents('DALL-e2AI', [TDalle2AI4Delphi]);
end;

end.
