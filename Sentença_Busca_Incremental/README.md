# Senteça SQL para busca incremental com Delphi.
Função criada com propósito de permitir busca incremental em mais de um campo em banco de dados com Delphi.

Apresentação / Declaração 
function SentencaBuscaIncremental(var aListaCampos, aComplWhere,
  aOrderBy: string; const aCampo, aOR_AND, aLimitador,
  aTexto: string): TStringList;


A função em contém os seguintes parâmetros:


aListaCampos --> listagem dos campos a serem exibidos no select do SQL, normalmente indo até instrução "FROM [TABELA]" nos casos simples, ou finalizando nos "JOINs" em casos mais complexos. Uma definição mais simples seria tudo antes do "where".

aComplWhere --> Complemento do where principal, podendo englobar a instrução "Group by" nos casos necessários.

aOrderBy --> senteça que define o order by do SQL.

aCampo --> campo ou lista de campos, separados por vírgula (,), nos quais os critérios da busca serão aplicados.

aOR_AND --> determina se a instrução incremental se dará por união ou interseção.

aLimitador --> conjunto de caracteres que informam o limite entre os termos de busca.

aTexto --> cadeia de carecteres contendo os termos de busca.( separados pelo "delimitador" ou não)

Esta função tem como retorno uma TStringList.

======
Exemplo de utilização:

procedure TForm1.Button1Click(Sender: TObject);
var
 lSQLListaCampos, lSQLComplementoWhere, lSQLOrderBy : string;
 s : TStringList;
begin
  FDQuery1.Close;
  FDQuery1.Params.Clear;
  FDQuery1.SQL.Clear;

  lSQLListaCampos := 'select * from PRODUTOS' ;
  lSQLComplementoWhere := ') ';
  lSQLOrderBy := 'order by DESCRICAO ';

  s := SentencaBuscaIncremental(lSQLListaCampos,   // lista de campos
      lSQLComplementoWhere,                        // Complemento do Where
      lSQLOrderBy,                                 //  order by
      'DESCRICAO, COMPATIVEIS, CARACTERISTICAS',   // campos da busca separados por virgula
      'AND',                                       // buscar (and ou or) campos
      ' ',                                         // limitador de busca " " espaço
      edtPesquisa.Text);                           // Texto a ser buscado nos campos

  FDQuery1.SQL.AddStrings(s);
  FDQuery1.Active := True;
  FDQuery1.First;
end;
...
======

Instrução SQL gerada após a execução:

select FIRST 30 ID_PRODUTO CODIGO, CODIGO_BARRA CODBARRA, DESCRICAO, ID_FABRICANTE CODFABRIC, NOME_FABRICANTE FABRICANTE, QUANTIDADE_EMBALAGEM, ESTOQUE_ATUAL, ESTOQUE_MINIMO, PRECO_CUSTO, PRECO_VENDA, PRECO_PROMOCAO,  produto.ATIVO, produto.ID_INMOBILI, EMPRESA_ALIAS, EMPRESA_COR from PRODUTO inner join empresa on empresa.id_inmobili = produto.ID_INMOBILI and empresa.id_inmobili_matriz =  :pIDInMobiliMatriz 
where ((DESCRICAO like '%DORF%') 
 AND (DESCRICAO like '%30%')
) and (produto.ID_INMOBILI = empresa.id_inmobili) 
order by DESCRICAO 
