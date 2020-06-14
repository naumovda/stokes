unit ProcChartUnit;

interface

uses
  Windows, Messages, SysUtils, FormReportAbsUnit, cxRadioGroup, DB, dxBar,
  cxBarEditItem, Controls,
  ExtCtrls, Chart, DBChart, ImgList, cxClasses, Classes, ActnList,
  TeeProcs, TeEngine;

type
  TProcChart = class(TFormReportAbs)
    cxChart: TDBChart;
    DataSource1: TDataSource;
    dxBarSubItem2: TdxBarSubItem;
    cxParameter: TcxBarEditItem;
    dxBarButton5: TdxBarButton;
    dxBarSubItem3: TdxBarSubItem;
    acPrintData: TAction;
    dxBarButton6: TdxBarButton;
    procedure cxParameterPropertiesEditValueChanged(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acPrintExecute(Sender: TObject);
    procedure acExcelExecute(Sender: TObject);
    procedure acPrintDataExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProcChart: TProcChart;

implementation

uses
  DataModuleUnit
  ,Dialogs
  ;

{$R *.dfm}

procedure TProcChart.cxParameterPropertiesEditValueChanged(
  Sender: TObject);
begin
  case cxParameter.EditValue of
  00: cxChart.Series[0].YValues.ValueSource := 'J';
  01: cxChart.Series[0].YValues.ValueSource := 'Q';
  02: cxChart.Series[0].YValues.ValueSource := 'U';
  03: cxChart.Series[0].YValues.ValueSource := 'V';
  04: cxChart.Series[0].YValues.ValueSource := 'P';

  05: cxChart.Series[0].YValues.ValueSource := 'J0';
  06: cxChart.Series[0].YValues.ValueSource := 'Q0';
  07: cxChart.Series[0].YValues.ValueSource := 'U0';
  08: cxChart.Series[0].YValues.ValueSource := 'V0';
  09: cxChart.Series[0].YValues.ValueSource := 'P0';

  10: cxChart.Series[0].YValues.ValueSource := 'Alfa1';
  11: cxChart.Series[0].YValues.ValueSource := 'Beta1';
  12: cxChart.Series[0].YValues.ValueSource := 'Re_Hi';
  13: cxChart.Series[0].YValues.ValueSource := 'Im_Hi';
  end;

  cxChart.Title.Text.Clear;
  cxChart.Title.Text.Add(cxChart.Series[0].YValues.ValueSource + '(m,n)');
end;

procedure TProcChart.acRefreshExecute(Sender: TObject);
begin
  dmPublic.tCalculation.Close;

  dmPublic.tCalculation.Open;
end;

procedure TProcChart.acPrintExecute(Sender: TObject);
begin
  cxChart.PrintLandscape;
end;

procedure TProcChart.acExcelExecute(Sender: TObject);
begin
  cxChart.CopyToClipboardBitmap();

  ShowMessage('График помещен в буфер обмена.');
end;

procedure TProcChart.acPrintDataExecute(Sender: TObject);
begin
  dmPublic.frxReport.LoadFromFile('SourceData01.fr3');

  dmPublic.frxReport.ShowReport();
end;

end.
