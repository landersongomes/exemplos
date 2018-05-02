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
  lSQLListaCampos := 'select * from pessoas';
  lSQLWhereComplemento := 'and (pessoas.ativo = :ativo)';
  lSQLOrderBy := 'order by nomerazao limit :limit';
  DMCadastros.Query_Pessoas.Close;
  DMCadastros.Query_Pessoas.SQL.Clear;
  DMCadastros.Query_Pessoas.SQL := DMCadastros.SentencaBuscaIncremental(
                        lSQLListaCampos, // lista de campos
                        lSQLWhereComplemento,  // Complemento do Where
                        lSQLOrderBy, //  order by
                        'pessoas.nomerazao, pessoas.fantasia, pessoas.cnpj', // campo da busca
                        'and', //and ou or
                        ' ', // Limitador " " (espaço)
                        EditBusca.Text);  // Texto a pesquisar

  DMCadastros.Query_Pessoas.ParamByName('ativo').AsInteger := 1;
  DMCadastros.Query_Pessoas.ParamByName('limit').AsInteger := 100;
  DMCadastros.Query_Pessoas.Open;    
...
======

Instrução SQL gerada após a execução: (com o EditBusca.Text = 'no t au')

select * from pessoas
where ((pessoas.nomerazao like '%no%') 
 and (pessoas.nomerazao like '%t%')
 and (pessoas.nomerazao like '%au%')
)
and (pessoas.ativo = :ativo)
union
select * from pessoas
where ((pessoas.fantasia like '%no%') 
 and (pessoas.fantasia like '%t%')
 and (pessoas.fantasia like '%au%')
)
and (pessoas.ativo = :ativo)
union
select * from pessoas
where ((pessoas.cnpj like '%no%') 
 and (pessoas.cnpj like '%t%')
 and (pessoas.cnpj like '%au%')
)
and (pessoas.ativo = :ativo)
order by nomerazao limit :limit
.
