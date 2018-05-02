unit UBuscaIncremental;

interface
uses System.Classes, System.SysUtils;

  function SentencaBuscaIncremental (var aListaCampos, aComplWhere,
  aOrderBy: string; const aCampo, aOR_AND, aLimitador,
  aTexto: string): TStringList;

implementation

function SentencaBuscaIncremental(var aListaCampos, aComplWhere,
  aOrderBy: string; const aCampo, aOR_AND, aLimitador,
  aTexto: string): TStringList;
var
  lwhere, lCampos, lTexto : TStringList;
  I: Integer;
  j: Integer;
begin
  Result := TStringList.Create;
  Result.Clear;
  lTexto := TStringList.Create;
  lTexto.Delimiter := aLimitador.Chars[0];
  ltexto.DelimitedText := aTexto;
  lCampos := TStringList.Create;
  lCampos.Delimiter := ',';
  lCampos.DelimitedText := aCampo;
  for I := 0 to lCampos.Count -1 do
    begin
      Result.Append(aListaCampos) ;
      lwhere := TStringList.Create;
      lwhere.Clear;

      for j := 0 to lTexto.Count -1 do
        begin
          if lwhere.Text.IsEmpty then
            lwhere.Append(Format('where ((%s like %s) ',
                  [lCampos[i], QuotedStr(Format( '%s%s%s',['%', lTexto[j] , '%']))]))

          else
            lwhere.Append(Format(' %s (%s like %s)',
                [aOR_AND, lCampos[i], QuotedStr(Format( '%s%s%s',[ '%', lTexto[j], '%']))]));

        end;

      if lwhere.Text.IsEmpty then
        lwhere.Append(Format('where ((%s like %s) ',
              [lCampos[i], QuotedStr(Format( '%s%s%s',['%', lTexto.Text , '%']))]));

      if (j = lTexto.Count) or (lTexto.Count = 0) then
        begin
          lwhere.Append(')');
          lwhere.Add(aComplWhere);
        end;

      Result.AddStrings(lwhere);
      if (i >= 0 ) and (i < (lCampos.Count -1)) then
        Result.Append('union');
      lwhere.Free;
    end;
  Result.Add(Format('%s', [aOrderBy]));
  lCampos.Free;

end;

end.
