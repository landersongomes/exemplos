# CLASS HELPER DATASETFIELDBASE64
## Este class Helper foi criado para automatizar a conversão de um FieldBlob de dataset para base64 e vice-versa. Com essa automação é possível por exemplo utilizar o RAD Server de forma automática para todo tipo de campo através do EMSDATASETRESOURCE. ##

### Exemplos de Uso:
#### Convertendo o conteúdo do blob em Base64:
"SEUDATASET".BlobImageFieldToBase64('SEUCAMPOBLOB');

#### Convertendo Base64 para ser inserida no Blob
_"SEUDATASET"_.Base64ToBlobImageField('*SEUCAMPOBLOB*');

Para automatizar o processo usando o EMSDATASETRESOURCE utilize o evento BeforePost para efetuar a conversão:

**procedure** TTesteResource1."SEUDATASET"BeforePost(DataSet: TDataSet);

**begin**

  _"SEUDATASET"_.Base64ToBlobImageField('*SEUCAMPOBLOB*');
  
**end**;

