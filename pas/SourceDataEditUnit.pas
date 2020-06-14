unit SourceDataEditUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormEditAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxBarDBNav, dxBar, cxClasses,
  ImgList, ActnList, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxPC, ExtCtrls,
  dxLayoutControl, cxContainer, dxLayoutcxEditAdapters, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalc, cxDBEdit, Menus, StdCtrls, cxButtons,
  cxMemo, cxRadioGroup, cxLabel, cxBarEditItem, dxLayoutLookAndFeels;

type
  TSourceDataEdit = class(TFormEditAbs)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    cxDBCalcEdit1: TcxDBCalcEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    cxDBCalcEdit2: TcxDBCalcEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    cxDBCalcEdit3: TcxDBCalcEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    cxDBCalcEdit4: TcxDBCalcEdit;
    dxLayoutControl1Item4: TdxLayoutItem;
    cxDBCalcEdit5: TcxDBCalcEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    cxDBCalcEdit6: TcxDBCalcEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    cxDBCalcEdit7: TcxDBCalcEdit;
    dxLayoutControl1Item7: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    dxLayoutControl1Group2: TdxLayoutGroup;
    dxLayoutControl1Group3: TdxLayoutGroup;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group5: TdxLayoutGroup;
    cxDBCalcEdit8: TcxDBCalcEdit;
    dxLayoutControl1Item8: TdxLayoutItem;
    cxDBCalcEdit9: TcxDBCalcEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    cxDBCalcEdit10: TcxDBCalcEdit;
    dxLayoutControl1Item10: TdxLayoutItem;
    cxDBCalcEdit11: TcxDBCalcEdit;
    dxLayoutControl1Item11: TdxLayoutItem;
    cxDBCalcEdit12: TcxDBCalcEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    cxDBCalcEdit13: TcxDBCalcEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    cxDBCalcEdit14: TcxDBCalcEdit;
    dxLayoutControl1Item14: TdxLayoutItem;
    dxLayoutControl1Group7: TdxLayoutGroup;
    dxLayoutControl1Group6: TdxLayoutGroup;
    dxLayoutControl1Group8: TdxLayoutGroup;
    dxLayoutControl1Group9: TdxLayoutGroup;
    dxLayoutControl1Group11: TdxLayoutGroup;
    dxLayoutControl1Group12: TdxLayoutGroup;
    dxLayoutControl1Group10: TdxLayoutGroup;
    cxDBCalcEdit15: TcxDBCalcEdit;
    dxLayoutControl1Item15: TdxLayoutItem;
    cxDBCalcEdit16: TcxDBCalcEdit;
    dxLayoutControl1Item16: TdxLayoutItem;
    cxDBCalcEdit17: TcxDBCalcEdit;
    dxLayoutControl1Item17: TdxLayoutItem;
    cxDBCalcEdit18: TcxDBCalcEdit;
    dxLayoutControl1Item18: TdxLayoutItem;
    cxDBCalcEdit19: TcxDBCalcEdit;
    dxLayoutControl1Item19: TdxLayoutItem;
    cxDBCalcEdit20: TcxDBCalcEdit;
    dxLayoutControl1Item20: TdxLayoutItem;
    cxDBCalcEdit21: TcxDBCalcEdit;
    dxLayoutControl1Item21: TdxLayoutItem;
    cxDBCalcEdit22: TcxDBCalcEdit;
    dxLayoutControl1Item22: TdxLayoutItem;
    cxDBCalcEdit23: TcxDBCalcEdit;
    dxLayoutControl1Item23: TdxLayoutItem;
    cxDBCalcEdit24: TcxDBCalcEdit;
    dxLayoutControl1Item24: TdxLayoutItem;
    cxDBCalcEdit25: TcxDBCalcEdit;
    dxLayoutControl1Item25: TdxLayoutItem;
    cxDBCalcEdit26: TcxDBCalcEdit;
    dxLayoutControl1Item26: TdxLayoutItem;
    cxDBCalcEdit27: TcxDBCalcEdit;
    dxLayoutControl1Item27: TdxLayoutItem;
    cxDBCalcEdit28: TcxDBCalcEdit;
    dxLayoutControl1Item28: TdxLayoutItem;
    cxButton2: TcxButton;
    dxLayoutControl1Item30: TdxLayoutItem;
    cxButton3: TcxButton;
    dxLayoutControl1Item31: TdxLayoutItem;
    acCalc01: TAction;
    acCalc02: TAction;
    acCalc03: TAction;
    dxLayoutControl1Group13: TdxLayoutGroup;
    dxLayoutControl1SeparatorItem1: TdxLayoutSeparatorItem;
    cxLog: TcxMemo;
    cxLogSelect: TcxBarEditItem;
    dxBarButton7: TdxBarButton;
    acCopyToClipboard: TAction;
    dxLayoutControl1Group14: TdxLayoutGroup;
    dxLayoutLookAndFeelList1: TdxLayoutLookAndFeelList;
    dxLayoutCxLookAndFeel1: TdxLayoutCxLookAndFeel;
    procedure acCalc01Execute(Sender: TObject);
    procedure acCalc02Execute(Sender: TObject);
    procedure acCalc03Execute(Sender: TObject);
    procedure cxLogSelectPropertiesEditValueChanged(Sender: TObject);
    procedure acCopyToClipboardExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SourceDataEdit: TSourceDataEdit;

implementation

{$R *.dfm}

  uses
    DataModuleUnit
    ,SourceDataUnit
    ;

procedure TSourceDataEdit.acCalc01Execute(Sender: TObject);
var
  F: TSourceData;
begin
  F := TSourceData.Create(self);

  F.acCalcClear.Execute;

  F.Free;
end;

procedure TSourceDataEdit.acCalc02Execute(Sender: TObject);
var
  F: TSourceData;
begin
  F := TSourceData.Create(self);

  F.WriteLog := true;

  F.acCalcRadiation.Execute;

  F.Free;
end;

procedure TSourceDataEdit.acCalc03Execute(Sender: TObject);
var
  F: TSourceData;
begin
  F := TSourceData.Create(self);

  F.WriteLog := true;
    
  F.acCalcReflection.Execute;

  F.Free;
end;

procedure TSourceDataEdit.cxLogSelectPropertiesEditValueChanged(
  Sender: TObject);
var
  FileName: string;
begin
  try
    case cxLogSelect.EditValue of
    0: FileName := 'LogPart01.txt';
    1: FileName := 'LogPart02.txt';
    2: FileName := 'LogPart03.txt';
    end;

    cxLog.Lines.LoadFromFile(FileName);
  except
    ShowMessage('Ошибка: файл ' + FileName + ' не найден!');
  end;
end;

procedure TSourceDataEdit.acCopyToClipboardExecute(Sender: TObject);
begin
  cxLog.SelectAll;

  cxLog.CopyToClipboard;

  ShowMessage('Протокол помещен в буфер обмена.');
end;

procedure TSourceDataEdit.FormShow(Sender: TObject);
begin
  inherited;

  cxLog.Clear;

  cxLogSelect.EditValue := NULL;
end;

end.
