unit MAIN;

interface

uses Windows, Forms, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxBar, cxClasses, ImgList, Controls, StdActns, Classes, ActnList, Dialogs,
  dxStatusBar, SysUtils;

type
  TGUIState = (gsConnected, gsWorkOffline, gsAdminRights, gsUserOMTSRights, gsUserStockRights);

  TGUIStates = set of TGUIState;

  TMainForm = class(TForm)
    OpenDialog1: TOpenDialog;
    ActionList: TActionList;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout: TAction;
    WindowTileVertical1: TWindowTileVertical;
    ilImageListMain: TImageList;
    actConnectDB: TAction;
    actDisconnectDB: TAction;
    actBlockDB: TAction;
    OpenDialog: TOpenDialog;
    acExit: TAction;
    acPickServer: TAction;
    acPickDatabase: TAction;
    actCloseAll: TAction;
    acDataSetFilter: TAction;
    acRefresh: TAction;
    acHelp: TAction;
    dxBarManager: TdxBarManager;
    dxStatusBar: TdxStatusBar;
    dxBarManager1Bar1: TdxBar;
    dxConnect: TdxBarButton;
    dxFile: TdxBarSubItem;
    dxDisconnect: TdxBarButton;
    dxExit: TdxBarButton;
    dxBarManagerBar1: TdxBar;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarPopupMenu: TdxBarPopupMenu;
    acCalcTest: TAction;
    dxBarCalc: TdxBarSubItem;
    dxBarButton14: TdxBarButton;
    acImportData: TAction;
    dxBarButton15: TdxBarButton;
    dxBarLargeButton5: TdxBarLargeButton;
    acSourceData: TAction;
    dxBarButton16: TdxBarButton;
    dxBarLargeButton6: TdxBarLargeButton;
    acChart: TAction;
    dxBarLargeButton7: TdxBarLargeButton;
    dxBarButton17: TdxBarButton;
    acIntervals: TAction;
    dxBarButton18: TdxBarButton;
    acPrintCalc01: TAction;
    dxBarLargeButton8: TdxBarLargeButton;
    dxBarSubItem3: TdxBarSubItem;
    dxBarButton19: TdxBarButton;
    ImageList: TImageList;
    acConstant: TAction;
    dxBarButton20: TdxBarButton;
    acShowLog: TAction;
    dxBarButton21: TdxBarButton;
    dxBarSubItem5: TdxBarSubItem;
    dxBarGradientTest: TdxBarButton;
    acCalcGradientTest: TAction;
    dxBarPopupPrint: TdxBarPopupMenu;
    acPrintCalc02: TAction;
    acPrintCalc03: TAction;
    dxBarButton22: TdxBarButton;
    dxBarButton23: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    acImportDataTask3: TAction;
    dxBarButton2: TdxBarButton;
    dxBarPopupMenuImport: TdxBarPopupMenu;
    dxBarPopupMenuSource: TdxBarPopupMenu;
    dxBarButton3: TdxBarButton;
    acSourceDataTask3: TAction;
    acMaterialRefraction: TAction;
    dxBarButton4: TdxBarButton;
    procedure FileExit1Execute(Sender: TObject);
    procedure actConnectDBExecute(Sender: TObject);
    procedure actDisconnectDBExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acCalcTestExecute(Sender: TObject);
    procedure acImportDataExecute(Sender: TObject);
    procedure acSourceDataExecute(Sender: TObject);
    procedure acChartExecute(Sender: TObject);
    procedure acIntervalsExecute(Sender: TObject);
    procedure acPrintCalc01Execute(Sender: TObject);
    procedure acConstantExecute(Sender: TObject);
    procedure acShowLogExecute(Sender: TObject);
    procedure acCalcGradientTestExecute(Sender: TObject);
    procedure acPrintCalc02Execute(Sender: TObject);
    procedure acPrintCalc03Execute(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure acHelpExecute(Sender: TObject);
    procedure acImportDataTask3Execute(Sender: TObject);
    procedure acSourceDataTask3Execute(Sender: TObject);
    procedure acMaterialRefractionExecute(Sender: TObject);
  private
  public
    Err : boolean;

    aServer, aDatabase, aUserName, aPassword : string;

    GUIState    : TGUIStates;

    TableCount  : integer;

    CurrentTable: integer;

    procedure SetGUIState(State : TGUIStates);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  FormAbsUnit
  ,DataModuleUnit
  ,Variants
  ,Calculation
  ,ProcImportDataUnit
  ,ProcImportDataTask3Unit
  ,SourceDataUnit
  ,SourceDataTask3  
  ,ProcChartUnit
  ,IntervalsUnit
  ,ConstantUnit
  ,ConstantEditUnit
  ,IniFiles
  ,LogUnit
  ,Gradient
  ,SourceDataEditUnit
  ,ExtActns
  ,MaterialRefractionUnit
  ,MaterialRefractionEditUnit
  ;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actConnectDBExecute(Sender: TObject);
var
  success: OleVariant;

  Ini: TIniFile;
begin
  dxStatusBar.Panels[0].Text := 'Соединение c ' + aServer + '://' + aDatabase + ':' + aUserName;

  dmPublic.Conn.Close;

  dmPublic.Conn.Open;

  Success := dmPublic.Conn.Connected;

  if not Success then begin
    MessageDlg('Ошибка соединения с базой данных',  mtCustom, [mbOk], 0);

    exit;
  end;

  if not dmPublic.SetOnline(true, true, false) then begin
    MessageDlg('Ошибка открытия таблиц базы данных',  mtCustom, [mbOk], 0);

    exit;
  end;

  SetGUIState([gsConnected]);
end;

procedure TMainForm.actDisconnectDBExecute(Sender: TObject);
begin
  dmPublic.SetOnline(false, false, true);

  actBlockDB.Checked := false;

  SetGUIState([]);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SetGUIState([]);

  self.actConnectDB.Execute();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SetGUIState([]);
end;

procedure TMainForm.acExitExecute(Sender: TObject);
begin
  try
    dmPublic.Conn.Close;

    SetGUIState([]);
  except
    Application.Terminate;
  end;

  Close;
end;

procedure TMainForm.SetGUIState(State: TGUIStates);
var
  i: integer;

  item: TdxBarItem;

  start: Boolean;

  link: TdxBaritemLink;
begin
  GUIState := State;
  
  if gsConnected in State then begin
    for i := 0 to ActionList.ActionCount-1 do begin
      if (ActionList.Actions[i] as TAction).Category = 'Database' then
        (ActionList.Actions[i] as TAction).Enabled := true;
    end;

    if not (gsWorkOffline in State) then begin
      actConnectDB.Enabled    := false;
      actDisconnectDB.Enabled := true;
      actBlockDB.Enabled      := true;
      actBlockDB.Checked      := false;
      acRefresh.Enabled       := true;

      dxStatusBar.Panels[0].Text := 'Соединено c ' + aServer + '://' + aDatabase + ':' + aUserName;
    end
    else begin
      actConnectDB.Enabled    := true;
      actDisconnectDB.Enabled := false;
      actBlockDB.Checked      := true;
      acRefresh.Enabled       := false;

      dxStatusBar.Panels[0].Text := 'Локальное соединение';
    end;

    start := true;
  end
  else
  begin
    for i := 0 to ActionList.ActionCount-1 do begin
      if (ActionList.Actions[i] as TAction).Category = 'Database' then
        (ActionList.Actions[i] as TAction).Enabled := false;
    end;

    actConnectDB.Enabled    := true;
    actDisconnectDB.Enabled := false;
    actBlockDB.Enabled      := false;
    acRefresh.Enabled       := false;

    dxStatusBar.Panels[0].Text := 'Отключено';

    for i := MDIChildCount-1 downto 0 do
      MDIChildren[i].Close;
  end;
end;

procedure TMainForm.actCloseAllExecute(Sender: TObject);
var
  i: integer;
begin
  for i := MDIChildCount-1 downto 0 do
    MDIChildren[i].Close;
end;

procedure TMainForm.acRefreshExecute(Sender: TObject);
begin
  ShowMessage('Обновление завершено!');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  actCloseAllExecute(Self);
end;

procedure TMainForm.acCalcTestExecute(Sender: TObject);
var
  I1, I2, I3, I4: TIntesity;

  V: TStokesVector;
begin
  I1 := TIntesity.Create;
  I1.Init(1.160, 0, 0);

  I2 := TIntesity.Create;
  I2.Init(0.060, 0, Pi/2);

  I3 := TIntesity.Create;
  I3.Init(0.685, 0, Pi/4);

  I4 := TIntesity.Create;
  I4.Init(0.620, Pi/2, Pi/4);

  V := TStokesVector.Create;
  V.Init;

  V.Calculate(I1, I2, I3, I4, true);

  ShowMessage(FloatToStrF(V.GetJ(), ffFixed, 10, 2));
  ShowMessage(FloatToStrF(V.GetQ(), ffFixed, 10, 2));
  ShowMessage(FloatToStrF(V.GetU(), ffFixed, 10, 2));
  ShowMessage(FloatToStrF(V.GetV(), ffFixed, 10, 2));
end;

procedure TMainForm.acImportDataExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TProcImportData.Execute;

  F.Show;
end;

procedure TMainForm.acSourceDataExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TSourceData.Execute(SourceDataEdit, '');
end;

procedure TMainForm.acChartExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TProcChart.Execute;

  F.Show;
end;

procedure TMainForm.acIntervalsExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TIntervals.Execute(nil, '');
end;

procedure TMainForm.acPrintCalc01Execute(Sender: TObject);
begin
  dmPublic.frxReport.LoadFromFile('SourceData01.fr3');

  dmPublic.frxReport.ShowReport();
end;

procedure TMainForm.acConstantExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TConstant.Execute(ConstantEdit, '');
end;

procedure TMainForm.acShowLogExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TLog.Execute();
end;

procedure TMainForm.acCalcGradientTestExecute(Sender: TObject);
var
  x, x0, y, y0: real;

  a, b, c, d, t, x1, x2: real;

  isDone: Boolean;

  d1, d2: TDateTime;
begin
  Gradient.W := 0.77;

  Gradient.V := -0.3;

  ShowMessage('w=' + FloatToStrF(w, ffFixed, 10, 4) + ' v='
    + FloatToStrF(v, ffFixed, 10, 4));

  d1 := Now;

  x0 := 0;

  y0 := 0;

  isDone := GradientMethod(Gradient.F, Gradient.dFdx, Gradient.dFdy, x0, y0,
    1e-5, x, y);

  d2 := Now;

  ShowMessage(DateTimeToStr(d1) + ':' + DateTimeToStr(d2));

  if IsDone then
    ShowMessage('x=' + FloatToStrF(x, ffFixed, 10, 4) + ' y='
      + FloatToStrF(y, ffFixed, 10, 4))
  else
  begin
    ShowMessage('Минимум не найден!');

    exit;
  end;

  a := cos(-2*y) + w;

  b := sqrt(2)*sin(-2*y);

  c := w - cos(-2*y);

  d := b*b-4*c*a;

  if d < 0 then
  begin
    ShowMessage('Второй корень не найден!');

    exit;
  end;

  x1 := arctan((-b + sqrt(d))/2/a);

  x2 := arctan((-b - sqrt(d))/2/a);

  if abs(x1 - x) > abs(x2 - x) then
    ShowMessage('x2=' + FloatToStrF(x1, ffFixed, 10, 4))
  else
    ShowMessage('x2=' + FloatToStrF(x2, ffFixed, 10, 4));
end;

procedure TMainForm.acPrintCalc02Execute(Sender: TObject);
begin
  dmPublic.frxReport.LoadFromFile('SourceData02.fr3');

  dmPublic.frxReport.ShowReport();
end;

procedure TMainForm.acPrintCalc03Execute(Sender: TObject);
begin
  dmPublic.frxReport.LoadFromFile('SourceData03.fr3');

  dmPublic.frxReport.ShowReport();
end;

function TMainForm.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
  Application.HelpFile := 'help.chm';

  Application.HelpContext(0);
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = chr(VK_Help) then
    Application.HelpContext(0);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Help then
    Application.HelpContext(0);
end;

procedure TMainForm.acHelpExecute(Sender: TObject);
var
  fr: TFileRun;
begin
  fr := TFileRun.Create(self);

  fr.FileName := 'help.chm';

  fr.Execute;

  fr.Free;
end;

procedure TMainForm.acImportDataTask3Execute(Sender: TObject);
var
  F: TForm;
begin
  F := TProcImportDataTask3.Execute;

  F.Show;
end;

procedure TMainForm.acSourceDataTask3Execute(Sender: TObject);
var
  F: TForm;
begin
  F := TSourceTask3.Execute(nil, '');
end;

procedure TMainForm.acMaterialRefractionExecute(Sender: TObject);
var
  F: TForm;
begin
  F := TMaterialRefraction.Execute(MaterialRefractionEdit, '');
end;

end.
