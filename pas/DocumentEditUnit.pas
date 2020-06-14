unit DocumentEditUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormEditAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxBarDBNav, dxBar, cxClasses,
  ImgList, ActnList, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxPC, ExtCtrls, cxContainer,
  cxDropDownEdit, cxCalendar, cxDBEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxLabel, cxMemo;

type
  TDocumentEdit = class(TFormEditAbs)
    cxLabel1: TcxLabel;
    cxClient: TcxDBButtonEdit;
    cxLabel2: TcxLabel;
    cxDate: TcxDBDateEdit;
    cxLabel3: TcxLabel;
    cxComment: TcxDBMemo;
    cxLabel4: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxLabel5: TcxLabel;
    cxGroup: TcxDBButtonEdit;
    tvMainPaymentDate: TcxGridDBColumn;
    tvMainPaymentSum: TcxGridDBColumn;
    tvMainPaymentDone: TcxGridDBColumn;
    cxLabel6: TcxLabel;
    cxDBDateEdit2: TcxDBDateEdit;
    procedure cxClientPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxGroupPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DocumentEdit: TDocumentEdit;

implementation

{$R *.dfm}

uses
  DataModuleUnit
  ,ClientUnit
  ,ClientEditUnit
  ,DocumentGroupUnit
  ;

procedure TDocumentEdit.cxClientPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  F: TForm;
begin
  F := TClient.Execute(ClientEdit, 'modal');

  F.ShowModal;

  if F.Tag = mrOk then
  begin
    dmPublic.tDocument.Edit;

    dmPublic.tDocumentClientId.Value := dmPublic.tClientObjectIntId.Value;

    dmPublic.tDocument.Post;
  end;

end;

procedure TDocumentEdit.cxGroupPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  F: TForm;
begin
  F := TDocumentGroup.Execute(nil, 'modal');

  F.ShowModal;

  if F.Tag = mrOk then
  begin
    dmPublic.tDocument.Edit;

    dmPublic.tDocumentGroupId.Value := dmPublic.tDocumentGroupObjectIntId.Value;

    dmPublic.tDocument.Post;
  end;
end;

end.
