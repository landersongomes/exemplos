unit Classes.Helpers.DatasetBase64;

interface
uses
  Data.DB;

type
  TDatasetBase64 = class Helper for TDataset
  public
/// <summary>Encode Image content in Blob field to Base64 string
/// </summary>
/// <param name="ABlobFielName">Field name of blob field.
/// </param>
/// <returns>String (Base64 encoded);
/// </returns>
    function BlobImageFieldToBase64(ABlobFieldName : string): string;
/// <summary>Decode Base64 String to image in Blob field.
/// </summary>
/// <param name="ABlobFielName">Field name of blob field.
/// </param>
    procedure Base64ToBlobImageField(ABlobFieldName : string);
  end;



implementation

uses
  System.Classes, System.NetEncoding;

{ TDatasetBase64 }

procedure TDatasetBase64.Base64ToBlobImageField(ABlobFieldName : string);
var
  lData: TStringStream;
  lMemory: TMemoryStream;
begin
  lData := TStringStream.Create(Self.FieldByName(ABlobFieldName).asString);
  lMemory := TMemoryStream.Create;
  try
    lData.Position := 0;
    TNetEncoding.Base64.Decode(lData, lMemory);
    lMemory.Position := 0;
    TBlobField(Self.FieldByName(ABlobFieldName)).LoadFromStream(lMemory);
  finally
    lMemory.Free;
    lData.Free;
  end;
end;

function TDatasetBase64.BlobImageFieldToBase64(ABlobFieldName : string): string;
var
  lOutStream: TStringStream;
  lInStream: TStream;
begin
  lOutStream := TStringStream.Create;
  lInStream := Self.CreateBlobStream(Self.FieldByName(ABlobFieldName), bmRead);
  try
    TNetEncoding.Base64.Encode(lInStream, lOutStream);
    lOutStream.Position := 0;
    Result := lOutStream.DataString;
  finally
    lInStream.Free;
    lOutStream.Free;
  end;

end;

end.
