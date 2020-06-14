unit ProcImportDataUnit;

interface

uses
  Windows, FormReportAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Dialogs, cxTextEdit, cxMemo,
  cxSplitter, Controls, cxSSheet, ImgList, dxBar, cxClasses, Classes,
  ActnList;

type
  TProcImportData = class(TFormReportAbs)
    cxSpreadSheet: TcxSpreadSheet;
    cxSplitter: TcxSplitter;
    cxLog: TcxMemo;
    OpenDialog: TOpenDialog;
    procedure acExcelExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acPrintExecute(Sender: TObject);
  public
    FileName: string;

    procedure LoadData();
  end;

var
  ProcImportData: TProcImportData;

implementation

uses
  DataModuleUnit
  ,ProcessMessage
  ,SysUtils
  ;

{$R *.dfm}

procedure TProcImportData.LoadData();
begin
 try
   cxSpreadSheet.LoadFromFile(OpenDialog.FileName);

   FileName := OpenDialog.FileName;
 except
   on E : Exception do
     ShowMessage(E.ClassName + E.Message);
 end;
end;

procedure TProcImportData.acExcelExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    LoadData();
end;

procedure TProcImportData.acRefreshExecute(Sender: TObject);
begin
  LoadData();
end;

procedure TProcImportData.acPrintExecute(Sender: TObject);
var
  i, j, rows: integer;

  ACell: TcxSSCellObject;

  sAlfa, sBeta,
  sTau1, sTau2, sTau3, sTau4,
  sPhi1, sPhi2, sPhi3, sPhi4,
  sI1, sI2, sI3, sI4: string;

  Alfa, Beta,
  Tau1, Tau2, Tau3, Tau4,
  Phi1, Phi2, Phi3, Phi4,
  I1, I2, I3, I4: double;
begin
  fmProcessMsg.StartMessage('Выполняется импорт данных...');

  //очищаем таблицу данных
  cxLog.Clear;
  cxLog.Lines.Add('Импорт данных начат в ' + DateTimeToStr(Now()) );

  dmPublic.tCalculation.First;

  while not dmPublic.tCalculation.Eof do
  begin
    dmPublic.tCalculation.Delete;

    dmPublic.tCalculation.First;
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
    sAlfa := Trim(cxSpreadSheet.Sheet.GetCellObject(1, i).CellValue);
    sBeta := Trim(cxSpreadSheet.Sheet.GetCellObject(2, i).CellValue);

    sTau1 := Trim(cxSpreadSheet.Sheet.GetCellObject(3, i).CellValue);
    sPhi1 := Trim(cxSpreadSheet.Sheet.GetCellObject(4, i).CellValue);
    sI1   := Trim(cxSpreadSheet.Sheet.GetCellObject(5, i).CellValue);

    sTau2 := Trim(cxSpreadSheet.Sheet.GetCellObject(6, i).CellValue);
    sPhi2 := Trim(cxSpreadSheet.Sheet.GetCellObject(7, i).CellValue);
    sI2   := Trim(cxSpreadSheet.Sheet.GetCellObject(8, i).CellValue);

    sTau3 := Trim(cxSpreadSheet.Sheet.GetCellObject(9, i).CellValue);
    sPhi3 := Trim(cxSpreadSheet.Sheet.GetCellObject(10, i).CellValue);
    sI3   := Trim(cxSpreadSheet.Sheet.GetCellObject(11, i).CellValue);

    sTau4 := Trim(cxSpreadSheet.Sheet.GetCellObject(12, i).CellValue);
    sPhi4 := Trim(cxSpreadSheet.Sheet.GetCellObject(13, i).CellValue);
    sI4   := Trim(cxSpreadSheet.Sheet.GetCellObject(14, i).CellValue);

    try Alfa := StrToFloat(sAlfa); except Alfa := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Alfa'); end;
    try Beta := StrToFloat(sBeta); except Beta := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Beta'); end;

    try Tau1 := StrToFloat(sTau1); except Tau1 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Tau1'); end;
    try Phi1 := StrToFloat(sPhi1); except Phi1 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Phi1'); end;
    try I1   := StrToFloat(sI1);   except I1   := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец I1');   end;

    try Tau2 := StrToFloat(sTau2); except Tau2 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Tau2'); end;
    try Phi2 := StrToFloat(sPhi2); except Phi2 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Phi2'); end;
    try I2   := StrToFloat(sI2);   except I2   := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец I2');   end;

    try Tau3 := StrToFloat(sTau3); except Tau3 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Tau3'); end;
    try Phi3 := StrToFloat(sPhi3); except Phi3 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Phi3'); end;
    try I3   := StrToFloat(sI3);   except I3   := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец I3');   end;

    try Tau4 := StrToFloat(sTau4); except Tau4 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Tau4'); end;
    try Phi4 := StrToFloat(sPhi4); except Phi4 := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец Phi4'); end;
    try I4   := StrToFloat(sI4);   except I4   := 0; cxLog.Lines.Add('Ошибка в строке ' + IntToStr(i) + '. Столбец I4');   end;

    dmPublic.tCalculation.Append;

    dmPublic.tCalculationObjectGUID.Value := NewGUID();

    dmPublic.tCalculationObjectId.Value := i;

    dmPublic.tCalculationAlfa.Value := Alfa;
    dmPublic.tCalculationBeta.Value := Beta;

    dmPublic.tCalculationTau1.Value := Tau1;
    dmPublic.tCalculationTau2.Value := Tau2;
    dmPublic.tCalculationTau3.Value := Tau3;
    dmPublic.tCalculationTau4.Value := Tau4;

    dmPublic.tCalculationPhi1.Value := Phi1;
    dmPublic.tCalculationPhi2.Value := Phi2;
    dmPublic.tCalculationPhi3.Value := Phi3;
    dmPublic.tCalculationPhi4.Value := Phi4;

    dmPublic.tCalculationI1.Value := I1;
    dmPublic.tCalculationI2.Value := I2;
    dmPublic.tCalculationI3.Value := I3;
    dmPublic.tCalculationI4.Value := I4;

    dmPublic.tCalculationErrorCode.Value := -1;

    dmPublic.tCalculation.Post;
  end;

  dmPublic.tCalculation.Close;

  dmPublic.tCalculation.Open;

  cxLog.Lines.Add('Импорт данных закончен в ' + DateTimeToStr(Now()) );  

  fmProcessMsg.EndMessage;
end;

end.
