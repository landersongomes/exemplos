unit Unit1;

interface
// Git por dentro do delphi

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, FMX.StdCtrls, FMX.Controls.Presentation,
  Data.Bind.Components, Data.Bind.DBScope, FMX.ListView, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter, REST.Client,
  Data.Bind.ObjectScope, FMX.Objects, System.ImageList, FMX.ImgList, FMX.Effects,
  REST.Types;

type
  TForm1 = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    ListView1: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    ToolBar1: TToolBar;
    ListView2: TListView;
    RESTClient2: TRESTClient;
    RESTRequest2: TRESTRequest;
    RESTResponse2: TRESTResponse;
    RESTResponseDataSetAdapter2: TRESTResponseDataSetAdapter;
    FDMemTable2: TFDMemTable;
    Image1: TImage;
    ImageList1: TImageList;
    Image2: TImage;
    Button1: TButton;
    ShadowEffect1: TShadowEffect;
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
uses System.JSON, System.JSON.Readers, System.JSON.Types;

procedure TForm1.Button1Click(Sender: TObject);
var
  SR : TStringReader;
  JR : TJsonTextReader;
  JA : TJSONArray;
  JO : TJSONObject;
  JP : TJSONPair;
  JV : TJSONValue;
  I, j: Integer;
  li : TListViewItem;

begin
  RESTRequest1.Execute;
  ListView2.Items.Clear;
  ListView2.BeginUpdate;
  for j := 0 to FDMemTable1.RecordCount -1 do
    begin
      RESTResponse2.RootElement := Format('documents[%u].fields',
        [j]);
      RESTRequest2.Execute;
      JA := TJSONArray.Create;
      for I := 0 to FDMemTable2.FieldCount -1 do
        begin
          JO := TJSONObject.Create;
          JO.AddPair(FDMemTable2.Fields[i].FieldName, FDMemTable2.Fields[i].AsString);
          JA.AddElement(jo);
        end;
      SR := TStringReader.Create(JA.ToString);
      JR := TJsonTextReader.Create(SR);
      li := ListView2.Items.Add;
      while JR.Read do
        begin
          if jr.TokenType = TJsonToken.PropertyName then
            begin
              if UpperCase(jr.Value.ToString) = 'NOME' then
                begin
                  JR.Read;
                  JO := TJSONObject.Create;
                  jp := TJSONPair.Create;
                  jv := TJSONObject.ParseJSONValue(jr.Value.ToString);
                  JO := jv as TJSONObject;
                  jp := jo.Get(0);
                  LI.Text := jp.JsonValue.Value;
                end;

              if UpperCase(jr.Value.ToString) = 'ID' then
                begin
                  JR.Read;
                  JO := TJSONObject.Create;
                  jp := TJSONPair.Create;
                  jv := TJSONObject.ParseJSONValue(jr.Value.ToString);
                  JO := jv as TJSONObject;
                  jp := jo.Get(0);
                  LI.Detail := jp.JsonValue.Value;
                end;
            end;
        end;
      li.ImageIndex := 0;
      ListView2.EndUpdate;
      JR.Free;
      SR.Free;
      JA.Free;
    end;

end;

procedure TForm1.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
  JA : TJSonArray;
  JO : TJSONObject;
  JR : TJsonTextReader;
  SR : TStringReader;
  I  : Integer;
  jp : TJSONPair;
  jv : TJSONValue;

begin

  RESTResponse2.RootElement := Format('documents[%u].fields',
    [FDMemTable1.RecNo -1]);
  RESTRequest2.Execute;

  JA := TJSONArray.Create;
  for I := 0 to FDMemTable2.FieldCount -1 do
    begin
      JO := TJSONObject.Create;
      JO.AddPair(FDMemTable2.Fields[i].FieldName, FDMemTable2.Fields[i].AsString);
      JA.AddElement(jo);
    end;
  SR := TStringReader.Create(JA.ToString);
  JR := TJsonTextReader.Create(SR);
  while JR.Read do
    begin
      if jr.TokenType = TJsonToken.PropertyName then
        begin
          if UpperCase(jr.Value.ToString) =  'NOME' then
            begin
              JR.Read;
              JO := TJSONObject.Create;
              jp := TJSONPair.Create;
              jv := TJSONObject.ParseJSONValue(jr.Value.ToString);
              JO := jv as TJSONObject;
              jp := jo.Get(0);
              ShowMessage(jp.JsonValue.Value);

            end;
        end;
    end;
  JR.Free;
  SR.Free;
  JA.Free;

end;

end.
