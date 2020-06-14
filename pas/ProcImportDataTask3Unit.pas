unit ProcImportDataTask3Unit;

interface

uses
  Windows, FormReportAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Dialogs, cxTextEdit, cxMemo,
  cxSplitter, Controls, cxSSheet, ImgList, dxBar, cxClasses, Classes,
  ActnList, cxRadioGroup, cxBarEditItem, DB, ADODB;

type
  TProcImportDataTask3 = class(TFormReportAbs)
    cxSpreadSheet: TcxSpreadSheet;
    cxSplitter: TcxSplitter;
    cxLog: TcxMemo;
    OpenDialog: TOpenDialog;
    cxSelectType: TcxBarEditItem;
    procedure acExcelExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acPrintExecute(Sender: TObject);
  public
    FileName: string;

    procedure LoadData();
  end;

var
  ProcImportDataTask3: TProcImportDataTask3;

implementation

uses
  DataModuleUnit
  ,ProcessMessage
  ,SysUtils
  ;

{$R *.dfm}

procedure TProcImportDataTask3.LoadData();
begin
 try
   cxSpreadSheet.LoadFromFile(OpenDialog.FileName);

   FileName := OpenDialog.FileName;
 except
   on E : Exception do
     ShowMessage(E.ClassName + E.Message);
 end;
end;

procedure TProcImportDataTask3.acExcelExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    LoadData();
end;

procedure TProcImportDataTask3.acRefreshExecute(Sender: TObject);
begin
  LoadData();
end;

procedure TProcImportDataTask3.acPrintExecute(Sender: TObject);
var
  i, j, rows: integer;

  ACell: TcxSSCellObject;

  Index: integer;

  aTable: TADOTable;

  sAngle, sQ, sU, sV, sAlfa, sBeta, sC: string;

  fAngle, fQ, fU, fV, fAlfa, fBeta, fC: double;
begin
  Index := cxSelectType.EditValue;

  case Index of
  0: aTable := dmPublic.tC1;
  1: aTable := dmPublic.tC2;
  2: aTable := dmPublic.tC3;
  end;

  fmProcessMsg.StartMessage('Выполняется импорт данных...');

  //очищаем таблицу данных
  cxLog.Clear;
  cxLog.Lines.Add('Импорт данных начат в ' + DateTimeToStr(Now()) );

  aTable.First;

  while not aTable.Eof do
  begin
    aTable.Delete;

    aTable.First;
  end;

  i := 0;

  repeat
    ACell := cxSpreadSheet.Sheet.GetCellObject(0, i);

    if ACell.Text = '' then break;

    i := i + 1;
  until false;

  rows := i;

  for i := 1 to rows - 1 do
  begin
    aTable.Append;

    case Index of
    0:
      begin
        dmPublic.tC1ObjectGUID.Value := NewGUID();

        sAngle := Trim(cxSpreadSheet.Sheet.GetCellObject(1, i).CellValue);
        sQ := Trim(cxSpreadSheet.Sheet.GetCellObject(2, i).CellValue);
        sU := Trim(cxSpreadSheet.Sheet.GetCellObject(3, i).CellValue);
        sV := Trim(cxSpreadSheet.Sheet.GetCellObject(4, i).CellValue);
        sC := Trim(cxSpreadSheet.Sheet.GetCellObject(5, i).CellValue);

        try fAngle := StrToFloat(sAngle); except fAngle := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 1'); end;
        try fQ := StrToFloat(sQ); except fQ := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 2'); end;
        try fU := StrToFloat(sU); except fU := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 3'); end;
        try fV := StrToFloat(sV); except fV := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 4'); end;
        try fC := StrToFloat(sC); except fC := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 5'); end;

        dmPublic.tC1dTetta.Value := fAngle;
        dmPublic.tC1Q.Value := fQ;
        dmPublic.tC1U.Value := fU;
        dmPublic.tC1V.Value := fV;
        dmPublic.tC1C1.Value := fC;
      end;
    1:
      begin
        dmPublic.tC2ObjectGUID.Value := NewGUID();

        sAngle := Trim(cxSpreadSheet.Sheet.GetCellObject(1, i).CellValue);
        sU := Trim(cxSpreadSheet.Sheet.GetCellObject(2, i).CellValue);
        sV := Trim(cxSpreadSheet.Sheet.GetCellObject(3, i).CellValue);
        sC := Trim(cxSpreadSheet.Sheet.GetCellObject(4, i).CellValue);

        try fAngle := StrToFloat(sAngle); except fAngle := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 1'); end;
        try fU := StrToFloat(sU); except fU := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 2'); end;
        try fV := StrToFloat(sV); except fV := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 3'); end;
        try fC := StrToFloat(sC); except fC := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 4'); end;

        dmPublic.tC2dGamma.Value := fAngle;
        dmPublic.tC2U.Value := fU;
        dmPublic.tC2V.Value := fV;
        dmPublic.tC2C2.Value := fC;
      end;
    2:
      begin
        dmPublic.tC3ObjectGUID.Value := NewGUID();

        sAngle := Trim(cxSpreadSheet.Sheet.GetCellObject(1, i).CellValue);
        sAlfa := Trim(cxSpreadSheet.Sheet.GetCellObject(2, i).CellValue);
        sBeta := Trim(cxSpreadSheet.Sheet.GetCellObject(3, i).CellValue);
        sC := Trim(cxSpreadSheet.Sheet.GetCellObject(4, i).CellValue);

        try fAngle := StrToFloat(sAngle); except fAngle := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 1'); end;
        try fAlfa := StrToFloat(sAlfa); except fAlfa := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 2'); end;
        try fBeta := StrToFloat(sBeta); except fBeta := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 3'); end;
        try fC := StrToFloat(sC); except fC := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец 4'); end;

        dmPublic.tC3dGamma.Value := fAngle;
        dmPublic.tC3Alfa.Value := fAlfa;
        dmPublic.tC3Beta.Value := fBeta;
        dmPublic.tC3C3.Value := fC;
      end;
    end;

    aTable.Post;
  end;

  aTable.Close;
  
  aTable.Open;

  cxLog.Lines.Add('Импорт данных закончен в ' + DateTimeToStr(Now()) );

  fmProcessMsg.EndMessage;
end;

end.
