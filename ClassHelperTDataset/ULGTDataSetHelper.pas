{*******************************************************}
{                                                       }
{                    Landerson Gomes                    }
{                                                       }
{*       Class Helper para Classes TDataSet            *}
{                                                       }
{*******************************************************}
{
baseado em JSON Writers
http://docwiki.embarcadero.com/RADStudio/Sydney/en/Readers_and_Writers_JSON_Framework
}

unit ULGTDataSetHelper;

interface

uses
  Data.DB, System.JSON, REST.Json, System.NetEncoding;

  Type
    TDataSetHelper = class Helper for TDataSet
    public
      function DataSetToJSON () : TJSonArray;
      procedure SaveToJSON(aFileName : string);
    end;

implementation

uses
  System.Classes, System.SysUtils, System.JSON.Writers, System.JSON.Types;

{ TDataSetHelper }

function TDataSetHelper.DataSetToJSON: TJSonArray;
var
  lCols : integer;
  lStreamIn: TStream;
  lStreamOut : TStringStream;
  lStringWriter : TStringWriter;
  lJSONWriter : TJsonTextWriter;
begin
  lStringWriter := TStringWriter.Create;
  lJSONWriter := TJsonTextWriter.Create(lStringWriter);
  lJSONWriter.Formatting := TJsonFormatting.Indented;
  try
    Self.First;
    lJSONWriter.WriteStartArray;
    while not Self.Eof do
      begin
        lJSONWriter.WriteStartObject;
        for lCols := 0 to Pred(FieldCount) do
          begin
            lJSONWriter.WritePropertyName(Self.Fields[lCols].FieldName);
            if Self.Fields[lCols].IsNull then
              lJSONWriter.WriteNull
            else
              case Fields[lCols].DataType of
                ftBlob:
                  begin
                    lStreamIn := CreateBlobStream(Fields[lCols], bmRead);
                    lStreamOut := TStringStream.Create;
                    TNetEncoding.Base64.Encode(lStreamIn, lStreamOut);
                    lStreamOut.Position := 0;
                    lJSONWriter.WritePropertyName(Self.Fields[lCols].FieldName);
                    lJSONWriter.WriteValue(lStreamOut.DataString);
                  end;
                ftBoolean:
                  lJSONWriter.WriteValue(Fields[lCols].AsBoolean);
                // númericos
                ftFloat, ftExtended, ftFMTBcd, ftBCD:
                  lJSONWriter.WriteValue(Fields[lCols].AsFloat);
                ftCurrency:
                  lJSONWriter.WriteValue(Fields[lCols].AsCurrency);
                ftSmallint, ftShortint, ftWord, ftInteger, ftAutoInc,
                ftLargeint, ftLongWord:
                  lJSONWriter.WriteValue(Int64(Fields[lCols].Value));
                //string
                ftString, ftFmtMemo, ftMemo, ftWideString, ftWideMemo, ftUnknown :
                  lJSONWriter.WriteValue(Trim(Fields[lCols].Value));
                // DateTime
                ftDateTime:
                  begin
//                          var lFS : TFormatSettings;
//                          lFS := TFormatSettings.Create('pt-BR');
//                          lFS.ShortDateFormat := 'mm/dd/yyyy';
                    lJSONWriter.WriteValue(FormatDatetime('DD/MM/YYYY hh:nn:ss', Self.Fields[lCols].AsDateTime));
                  end;
                ftDate:
                  lJSONWriter.WriteValue(FormatDatetime('DD/MM/YYYY', Self.fields[lcols].AsDateTime));
                ftTime, ftTimeStamp:
                  lJSONWriter.WriteValue(FormatDatetime('hh:hh:ss', Self.Fields[lCols].AsDateTime));

                ftBytes:
                  lJSONWriter.WriteValue(Self.Fields[lCols].AsBytes);
              end;
          end;
        lJSONWriter.WriteEndObject;
        Self.Next;
      end;
    lJSONWriter.WriteEndArray;

    Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(lStringWriter.ToString), 0) as TJSONArray;
  finally
    lJSONWriter.Free;
    lStringWriter.Free;
  end;
end;

procedure TDataSetHelper.SaveToJSON(aFileName: string);
var
  S : TStringList;
begin
  S  := TStringList.Create;
  S.Clear;
  S.Add(DataSetToJSON.ToString());
  S.SaveToFile(aFileName);
end;

end.


