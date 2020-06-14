unit LogUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormReportAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMemo, ImgList,
  dxBar, cxClasses, ActnList, cxRadioGroup, cxBarEditItem;

type
  TLog = class(TFormReportAbs)
    cxLog: TcxMemo;
    cxLogSelect: TcxBarEditItem;
    procedure FormShow(Sender: TObject);
    procedure cxLogSelectPropertiesEditValueChanged(Sender: TObject);
    procedure acPrintExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    LogValue: integer;
  end;

var
  Log: TLog;

implementation

uses
  DataModuleUnit
  ;

{$R *.dfm}

procedure TLog.FormShow(Sender: TObject);
begin
  inherited;

  cxLogSelect.EditValue := LogValue;

  cxLogSelectPropertiesEditValueChanged(Sender);
end;

procedure TLog.cxLogSelectPropertiesEditValueChanged(Sender: TObject);
begin
  case cxLogSelect.EditValue of
  0: cxLog.Lines.LoadFromFile('LogPart01.txt');
  1: cxLog.Lines.LoadFromFile('LogPart02.txt');
  2: cxLog.Lines.LoadFromFile('LogPart03.txt');
  3: cxLog.Lines.LoadFromFile('LogPart03_01.txt');    
  end;
end;

procedure TLog.acPrintExecute(Sender: TObject);
begin
  cxLog.SelectAll;

  cxLog.CopyToClipboard;

  ShowMessage('Протокол помещен в буфер обмена.');
end;

procedure TLog.acRefreshExecute(Sender: TObject);
begin
  cxLogSelectPropertiesEditValueChanged(Sender);
end;

procedure TLog.FormCreate(Sender: TObject);
begin
  inherited;

  LogValue := dmPublic.LogValue;
end;

end.
