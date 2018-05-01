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
  lwhere, lCampos : TStringList;
  ltexto : string;
  I: Integer;
begin
  Result := TStringList.Create;
  Result.Clear;
  ltexto := aTexto;
  lCampos := TStringList.Create;
  lCampos.Delimiter := ',';
  lCampos.DelimitedText := aCampo;

  for I := 0 to lCampos.Count -1 do
    begin

      Result.Append(aListaCampos) ;
      lwhere := TStringList.Create;
      lwhere.Clear;

      while ltexto.IndexOf(aLimitador) >= 0 do
        begin
          if lwhere.Text.IsEmpty then
            begin
              lwhere.Append(Format('where ((%s like %s) ',
                  [lCampos[i], QuotedStr(Format( '%s%s%s',['%', Copy(ltexto, 0, ltexto.IndexOf(aLimitador)), '%']))]))
            end
          else
            begin
              lwhere.Append(Format(' %s (%s like %s)',
                [aOR_AND, lCampos[i], QuotedStr(Format( '%s%s%s',[ '%', Copy(ltexto, 0, ltexto.IndexOf(aLimitador)), '%']))]));
            end;
          ltexto := Copy(ltexto, ltexto.IndexOf(aLimitador)+1 + aLimitador.Length, lTexto.Length );
        end;

      if lwhere.Text.IsEmpty then
        begin
          lwhere.Append(Format('where ((%s like %s)', [lCampos[i], QuotedStr(Format( '%s%s%s',['%', ltexto, '%']))]));
          lwhere.Add(aComplWhere);
        end
      else
        begin
          lwhere.Append(Format(' %s (%s like %s)', [aOR_AND, lCampos[i], QuotedStr(Format( '%s%s%s',['%', ltexto, '%']))]));
          lwhere.Add(aComplWhere);
        end;


      Result.AddStrings(lwhere);

      if (i >= 0 ) and (i < (lCampos.Count -1)) then
        begin
          Result.Append('union');

        end;

      lwhere.Free;

    end;

  Result.Add(Format('%s', [aOrderBy]));
  lCampos.Free;

end;

end.

