unit SourceDataUnit;

interface

uses
  Windows, Forms, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, dxBar,
  cxClasses, Classes, ActnList, ImgList, Controls, cxGridLevel,
  cxGridCustomView, cxGrid, Graphics, cxCheckBox, cxBarEditItem,
  FormAbsUnit, cxLabel, cxContainer, dxLayoutcxEditAdapters,
  dxLayoutControl, Menus, StdCtrls, cxButtons, cxSplitter,
  dxLayoutLookAndFeels, cxGroupBox, cxRadioGroup;

type
  TSourceData = class(TFormListAbs)
    tvMainObjectId: TcxGridDBColumn;
    tvMainAlfa: TcxGridDBColumn;
    tvMainBeta: TcxGridDBColumn;
    tvMainTau1: TcxGridDBColumn;
    tvMainPhi1: TcxGridDBColumn;
    tvMainI1: TcxGridDBColumn;
    tvMainTau2: TcxGridDBColumn;
    tvMainPhi2: TcxGridDBColumn;
    tvMainI2: TcxGridDBColumn;
    tvMainTau3: TcxGridDBColumn;
    tvMainPhi3: TcxGridDBColumn;
    tvMainI3: TcxGridDBColumn;
    tvMainTau4: TcxGridDBColumn;
    tvMainPhi4: TcxGridDBColumn;
    tvMainI4: TcxGridDBColumn;
    tvMainJ: TcxGridDBColumn;
    tvMainQ: TcxGridDBColumn;
    tvMainU: TcxGridDBColumn;
    tvMainV: TcxGridDBColumn;
    acCalcRadiation: TAction;
    acCalcAllRadiation: TAction;
    dxBarSubItem2: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    tvMainErrorCode: TcxGridDBColumn;
    acCalcClear: TAction;
    dxBarButton3: TdxBarButton;
    tvMainP: TcxGridDBColumn;
    cxStyleMain: TcxStyle;
    tvMainJ0: TcxGridDBColumn;
    tvMainQ0: TcxGridDBColumn;
    tvMainU0: TcxGridDBColumn;
    tvMainV0: TcxGridDBColumn;
    tvMainP0: TcxGridDBColumn;
    dxLayoutGroup_Root: TdxLayoutGroup;
    dxLayout: TdxLayoutControl;
    cxSplitter: TcxSplitter;
    cxShowAnglesBox: TcxCheckBox;
    dxLayoutItem1: TdxLayoutItem;
    cxShowIntensivityBox: TcxCheckBox;
    dxLayoutItem2: TdxLayoutItem;
    cxShowPBox: TcxCheckBox;
    dxLayoutItem3: TdxLayoutItem;
    cxShowP0Box: TcxCheckBox;
    dxLayoutItem4: TdxLayoutItem;
    cxShowHiBox: TcxCheckBox;
    dxLayoutItem5: TdxLayoutItem;
    cxButton1: TcxButton;
    dxLayoutItem6: TdxLayoutItem;
    cxBarEditItem1: TcxBarEditItem;
    dxBarSubItem4: TdxBarSubItem;
    acCalcReflection: TAction;
    acCalcAllReflection: TAction;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxLayoutGroupParameters: TdxLayoutGroup;
    cxButton2: TcxButton;
    dxLayoutItem7: TdxLayoutItem;
    cxButton3: TcxButton;
    dxLayoutItem8: TdxLayoutItem;
    cxButton4: TcxButton;
    dxLayoutItem9: TdxLayoutItem;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    tvMainAlfa1: TcxGridDBColumn;
    tvMainBeta1: TcxGridDBColumn;
    tvMainRe_Hi: TcxGridDBColumn;
    tvMainIm_Hi: TcxGridDBColumn;
    cxButton5: TcxButton;
    dxLayoutItem10: TdxLayoutItem;
    tvMainErrorCode01: TcxGridDBColumn;
    dxLayoutLookAndFeelList1: TdxLayoutLookAndFeelList;
    dxLayoutCxLookAndFeel1: TdxLayoutCxLookAndFeel;
    cxCalcType: TcxRadioGroup;
    dxLayoutItem11: TdxLayoutItem;
    procedure acCalcRadiationExecute(Sender: TObject);
    procedure acCalcClearExecute(Sender: TObject);
    procedure acCalcAllRadiationExecute(Sender: TObject);
    procedure tvMainStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acCalcReflectionExecute(Sender: TObject);
    procedure cxShowAnglesBoxPropertiesEditValueChanged(Sender: TObject);
    procedure cxShowIntensivityBoxPropertiesEditValueChanged(
      Sender: TObject);
    procedure cxShowPBoxPropertiesEditValueChanged(Sender: TObject);
    procedure cxShowP0BoxPropertiesEditValueChanged(Sender: TObject);
    procedure cxCheckBox5PropertiesEditValueChanged(Sender: TObject);
    procedure acCalcAllReflectionExecute(Sender: TObject);
  public
    WriteLog: Boolean;

    procedure RefreshInfo();
  end;

var
  SourceData: TSourceData;

implementation

uses
  DataModuleUnit
  ,Calculation
  ,ProcessMessage
  ,IniFiles
  ,Gradient
  ,Complex
  ;

{$R *.dfm}

procedure TSourceData.RefreshInfo;
begin
  inherited;

  if Visible then
  begin
    acCalcRadiation.Enabled := acEdit.Enabled;

    acCalcAllRadiation.Enabled := acNew.Enabled;

    acCalcReflection.Enabled := acEdit.Enabled;

    acCalcAllReflection.Enabled := acNew.Enabled;

    acCalcClear.Enabled := acNew.Enabled;
  end;
end;

procedure TSourceData.acCalcRadiationExecute(Sender: TObject);
var
  I1, I2, I3, I4: TIntesity;

  V: TStokesVector;
  N: TStokesNaturalVector;

  Tau1, Tau2, Tau3, Tau4,
  Phi1, Phi2, Phi3, Phi4,
  dI1,  dI2,  dI3,  dI4: double;
begin
  Tau1 := dmPublic.tCalculationTau1.Value;
  Tau2 := dmPublic.tCalculationTau2.Value;
  Tau3 := dmPublic.tCalculationTau3.Value;
  Tau4 := dmPublic.tCalculationTau4.Value;

  Phi1 := dmPublic.tCalculationPhi1.Value;
  Phi2 := dmPublic.tCalculationPhi2.Value;
  Phi3 := dmPublic.tCalculationPhi3.Value;
  Phi4 := dmPublic.tCalculationPhi4.Value;

  dI1  := dmPublic.tCalculationI1.Value;
  dI2  := dmPublic.tCalculationI2.Value;
  dI3  := dmPublic.tCalculationI3.Value;
  dI4  := dmPublic.tCalculationI4.Value;

  I1 := TIntesity.Create;
  I1.Init(dI1, Tau1, Phi1);

  I2 := TIntesity.Create;
  I2.Init(dI2, Tau2, Phi2);

  I3 := TIntesity.Create;
  I3.Init(dI3, Tau3, Phi3);

  I4 := TIntesity.Create;
  I4.Init(dI4, Tau4, Phi4);

  V := TStokesVector.Create;

  V.Init;

  V.Calculate(I1, I2, I3, I4, WriteLog);

  N := TStokesNaturalVector.Create;

  N.Init;

  N.CalculateNatural(V, WriteLog);

  dmPublic.tCalculation.Edit;

  dmPublic.tCalculationJ.Value := V.GetJ();
  dmPublic.tCalculationQ.Value := V.GetQ();
  dmPublic.tCalculationU.Value := V.GetU();
  dmPublic.tCalculationV.Value := V.GetV();
  dmPublic.tCalculationP.Value := V.GetP();

  dmPublic.tCalculationJ0.Value := N.GetJ();
  dmPublic.tCalculationQ0.Value := N.GetQ();
  dmPublic.tCalculationU0.Value := N.GetU();
  dmPublic.tCalculationV0.Value := N.GetV();
  dmPublic.tCalculationP0.Value := N.GetP();

  dmPublic.tCalculationErrorCode.Value := V.ErrorCode;

  dmPublic.tCalculation.Post;
end;

procedure TSourceData.acCalcClearExecute(Sender: TObject);
begin
  dmPublic.tCalculation.First;

  while not dmPublic.tCalculation.Eof do
  begin
    dmPublic.tCalculation.Edit;

    dmPublic.tCalculationJ.Value := 0;
    dmPublic.tCalculationQ.Value := 0;
    dmPublic.tCalculationU.Value := 0;
    dmPublic.tCalculationV.Value := 0;
    dmPublic.tCalculationP.Value := 0;

    dmPublic.tCalculationJ0.Value := 0;
    dmPublic.tCalculationQ0.Value := 0;
    dmPublic.tCalculationU0.Value := 0;
    dmPublic.tCalculationV0.Value := 0;
    dmPublic.tCalculationP0.Value := 0;

    dmPublic.tCalculationAlfa1.Value := 0;
    dmPublic.tCalculationBeta1.Value := 0;
    dmPublic.tCalculationRe_Hi.Value := 0;
    dmPublic.tCalculationIm_Hi.Value := 0;        

    dmPublic.tCalculationErrorCode.Value := -1;

    dmPublic.tCalculationErrorCode01.Value := -1;

    dmPublic.tCalculation.Post;

    dmPublic.tCalculation.Next;
  end;
end;

procedure TSourceData.acCalcAllRadiationExecute(Sender: TObject);
begin
  fmProcessMsg.StartMessage('Выполняется расчет компонент вектора...');

  WriteLog := false;

  tvMain.BeginUpdate;

  dmPublic.tCalculation.First;

  while not dmPublic.tCalculation.Eof do
  begin
    acCalcRadiation.Execute;

    dmPublic.tCalculation.Next;
  end;

  tvMain.EndUpdate;

  WriteLog := true;

  fmProcessMsg.EndMessage;
end;

procedure TSourceData.tvMainStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
begin
  if AItem.Index = tvMainJ.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Jmin) or (ARecord.Values[AItem.Index] > dmPublic.Jmax) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainQ.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Qmin) or (ARecord.Values[AItem.Index] > dmPublic.Qmax) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainU.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Umin) or (ARecord.Values[AItem.Index] > dmPublic.Umax) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainV.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Vmin) or (ARecord.Values[AItem.Index] > dmPublic.Vmax) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainP.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Pmin) or (ARecord.Values[AItem.Index] > dmPublic.Pmax) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainJ0.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.J0min) or (ARecord.Values[AItem.Index] > dmPublic.J0max) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainQ0.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.Q0min) or (ARecord.Values[AItem.Index] > dmPublic.Q0max) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainU0.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.U0min) or (ARecord.Values[AItem.Index] > dmPublic.U0max) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainV0.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.V0min) or (ARecord.Values[AItem.Index] > dmPublic.V0max) then
      AStyle.Color := clYellow;
  end;

  if AItem.Index = tvMainP0.Index then
  begin
    AStyle := TcxStyle.Create(Sender);
    AStyle.Font.Style := [fsBold];

    if (ARecord.Values[AItem.Index] < dmPublic.P0min) or (ARecord.Values[AItem.Index] > dmPublic.P0max) then
      AStyle.Color := clYellow;
  end;
end;

procedure TSourceData.FormShow(Sender: TObject);
var
  Ini : TIniFile;
begin
  inherited;

  Ini := TIniFile.Create(self.Name + Parameters);

  cxShowAnglesBox.EditValue := INI.ReadBool(self.Name + Parameters, 'Show1', true);

  cxShowIntensivityBox.EditValue := INI.ReadBool(self.Name + Parameters, 'Show2', true);

  cxShowPBox.EditValue := INI.ReadBool(self.Name + Parameters, 'Show3', true);

  cxShowP0Box.EditValue := INI.ReadBool(self.Name + Parameters, 'Show4', true);

  cxShowHiBox.EditValue := INI.ReadBool(self.Name + Parameters, 'Show5', true);

  Ini.Free;

  WriteLog := true;
end;

procedure TSourceData.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini : TIniFile;
begin
  inherited;

  Ini := TIniFile.Create(self.Name + Parameters);

  Ini.WriteBool(self.Name + Parameters, 'Show1', cxShowAnglesBox.EditValue);
  Ini.WriteBool(self.Name + Parameters, 'Show2', cxShowIntensivityBox.EditValue);
  Ini.WriteBool(self.Name + Parameters, 'Show3', cxShowPBox.EditValue);
  Ini.WriteBool(self.Name + Parameters, 'Show4', cxShowP0Box.EditValue);
  Ini.WriteBool(self.Name + Parameters, 'Show5', cxShowHiBox.EditValue);

  Ini.Free;
end;

procedure TSourceData.acCalcReflectionExecute(Sender: TObject);
var
  x, x0, y, y0: real;

  a, b, c, d, t, x1, x2: real;

  isDone, isAnalitic: Boolean;

  d1, d2: TDateTime;

  J, Q, U, V: real;

  Alfa, Beta: real;

  Hi, Down: TComplex;

  LogFile: TextFile;
begin
  J := dmPublic.tCalculationJ.Value;
  Q := dmPublic.tCalculationQ.Value;
  U := dmPublic.tCalculationU.Value;
  V := dmPublic.tCalculationV.Value;

  Gradient.Gamma := dmPublic.Gamma;

  isAnalitic := cxCalcType.ItemIndex = 1;

  if Q*Q + V*V + U*U < 1e-5 then
  begin
    Gradient.W := 0;
    Gradient.V := 0;
  end
  else
  begin
    Gradient.W := Q / sqrt(Q*Q + V*V + U*U);
    Gradient.V := U / sqrt(Q*Q + V*V + U*U);
  end;

  x0 := 0;

  y0 := 0;

  if WriteLog then
  begin
    AssignFile(LogFile, 'LogPart03.txt');

    Rewrite(LogFile);

    //Выводим исходные параметры
    Writeln(LogFile, 'Расчет параметров поляризации');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'J = ', J:10:4);
    Writeln(LogFile, 'Q = ', Q:10:4);
    Writeln(LogFile, 'U = ', U:10:4);
    Writeln(LogFile, 'V = ', V:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Gamma = ', Gradient.Gamma:10:4);
    Writeln(LogFile, 'Q / sqrt(Q*Q + V*V + U*U) = ', Gradient.W:10:4);
    Writeln(LogFile, 'U / sqrt(Q*Q + V*V + U*U) = ', Gradient.V:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Начальное приближение');
    Writeln(LogFile, 'x0 = ', x0:10:4);
    Writeln(LogFile, 'y0 = ', y0:10:4);
  end;

  if isAnalitic then
  begin
    isDone := true;

    Beta := abs(arctan(V / sqrt(Q*Q + U*U + sqr(cos(Gradient.Gamma)) * (Q*Q + V*V + U*U))));

    if Gradient.Gamma * V > 0 then
      Beta := - Beta;

    Alfa := abs(arctan( sin(2*Beta)/cos(2*Beta)*cos(Gradient.Gamma)));

    if abs(U) < 1e-5 then
      Alfa := 0
    else if U < 0 then
      Alfa := - Alfa;

      Writeln(LogFile, '------------------------------------------------------');
      Writeln(LogFile, 'Найдено аналитическим методом:');
      Writeln(LogFile, 'alfa = ', Alfa:10:4);
      Writeln(LogFile, 'beta = ', Beta:10:4);
      Writeln(LogFile, '------------------------------------------------------');
  end
  else
  begin
    isDone := GradientMethod(Gradient.F, Gradient.dFdx, Gradient.dFdy, x0, y0,
      1e-5, x, y);

    //максимум не найден
    if not IsDone then
    begin
      dmPublic.tCalculation.Edit;

      dmPublic.tCalculationAlfa1.Value := 0;

      dmPublic.tCalculationBeta1.Value := 0;

      dmPublic.tCalculationRe_Hi.Value := 0;

      dmPublic.tCalculationIm_Hi.Value := 0;

      dmPublic.tCalculationGamma.Value := dmPublic.Gamma;

      dmPublic.tCalculationErrorCode01.Value := 1;

      dmPublic.tCalculation.Post;

      if WriteLog then
      begin
        Writeln(LogFile, '------------------------------------------------------');
        Writeln(LogFile, 'Метод градиента не смог найти минимум функции');
        Writeln(LogFile, '------------------------------------------------------');
        CloseFile(LogFile);
      end;

      exit;
    end;

    //не найден, но не корень
    if abs(Gradient.F(x, y)) > 1e-5 then
    begin
      dmPublic.tCalculation.Edit;

      dmPublic.tCalculationAlfa1.Value := 0;

      dmPublic.tCalculationBeta1.Value := 0;

      dmPublic.tCalculationRe_Hi.Value := 0;

      dmPublic.tCalculationIm_Hi.Value := 0;

      dmPublic.tCalculationGamma.Value := dmPublic.Gamma;

      dmPublic.tCalculationErrorCode01.Value := 2;

      dmPublic.tCalculation.Post;

      if WriteLog then
      begin
        Writeln(LogFile, '------------------------------------------------------');
        Writeln(LogFile, 'Ошибка: система не имеет решения');
        Writeln(LogFile, 'cos(2a)cos(2b) - cos(gamma)sin(2a)sin(2b)=',Gradient.W:10:4);
        Writeln(LogFile, 'sin(2a)cos(2b) + cos(gamma)sin(2a)sin(2b)=',Gradient.V:10:4);
        Writeln(LogFile, '------------------------------------------------------');

        CloseFile(LogFile);
      end;

      exit;
    end;

    if WriteLog then
    begin
      Writeln(LogFile, '------------------------------------------------------');
      Writeln(LogFile, 'Найдено решение методом градиента');
      Writeln(LogFile, 'alfa1 = ', x:10:4);
      Writeln(LogFile, 'beta1 = ', y:10:4);
      Writeln(LogFile, '------------------------------------------------------');
    end;

    a := cos(-2*y) + w;

    b := sqrt(2)*sin(-2*y);

    c := w - cos(-2*y);

    d := b*b-4*c*a;

    //почему-то не найден второй корень - альфа
    if d < 0 then
    begin
      dmPublic.tCalculation.Edit;

      dmPublic.tCalculationAlfa1.Value := 0;

      dmPublic.tCalculationBeta1.Value := 0;

      dmPublic.tCalculationRe_Hi.Value := 0;

      dmPublic.tCalculationIm_Hi.Value := 0;

      dmPublic.tCalculationGamma.Value := dmPublic.Gamma;

      dmPublic.tCalculationErrorCode01.Value := 3;

      dmPublic.tCalculation.Post;

      if WriteLog then
      begin
        Writeln(LogFile, '------------------------------------------------------');
        Writeln(LogFile, 'Ошибка: не найдено второе решение alfa 2 для beta2 = ', -y:10:4);
        Writeln(LogFile, '------------------------------------------------------');

        CloseFile(LogFile);
      end;

      exit;
    end;

    x1 := arctan((-b + sqrt(d))/2/a);

    x2 := arctan((-b - sqrt(d))/2/a);

    if abs(x1 - x) > abs(x2 - x) then
      x2 := x1;

    Alfa := (x + x2) /2;

    if {Gamma *} V > 0 then
      Beta := -abs(y)
    else
      Beta := abs(y);

  end; //численно

  Hi := TComplex.Create;
  Hi.Init(sin(Alfa)/cos(Alfa), sin(Beta)/cos(Beta));

  Down := TComplex.Create;
  Down.Init(1, -1*sin(Alfa)*sin(Beta)/cos(Alfa)/cos(Beta));

  Hi.Divide(Down);

  dmPublic.tCalculation.Edit;

  dmPublic.tCalculationAlfa1.Value := Alfa;

  dmPublic.tCalculationBeta1.Value := Beta;

  dmPublic.tCalculationRe_Hi.Value := Hi.Re;

  dmPublic.tCalculationIm_Hi.Value := Hi.Im;

  dmPublic.tCalculationGamma.Value := dmPublic.Gamma;  

  dmPublic.tCalculationErrorCode01.Value := 0;

  dmPublic.tCalculation.Post;

  if WriteLog then
  begin
    Writeln(LogFile, 'alfa1 = ', x:10:4);
    Writeln(LogFile, 'beta1 = ', y:10:4);
    Writeln(LogFile, 'alfa2 = ', x2:10:4);    
    Writeln(LogFile, 'beta2 = ', -y:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'alfa = (alfa1+alfa2)/2 = ', alfa:10:4);
    Writeln(LogFile, 'beta = ', beta:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Re(Hi) = ', Hi.Re:10:4);
    Writeln(LogFile, 'Im(Hi) = ', Hi.Im:10:4);
    Writeln(LogFile, '|Hi|   = ', Hi.Module():10:4);
    Writeln(LogFile, '/_Hi   = ', Hi.Angle():10:4, ' рад. = ', Hi.Angle()/Pi*180:10:4, ' град.');    
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Расчет завершен');
    Writeln(LogFile, '------------------------------------------------------');

    CloseFile(LogFile);
  end;
end;

procedure TSourceData.cxShowAnglesBoxPropertiesEditValueChanged(
  Sender: TObject);
begin
  tvMain.BeginUpdate;

  tvMainTau1.Visible := cxShowAnglesBox.EditValue;

  tvMainTau2.Visible := cxShowAnglesBox.EditValue;

  tvMainTau3.Visible := cxShowAnglesBox.EditValue;

  tvMainTau4.Visible := cxShowAnglesBox.EditValue;

  tvMainPhi1.Visible := cxShowAnglesBox.EditValue;

  tvMainPhi2.Visible := cxShowAnglesBox.EditValue;

  tvMainPhi3.Visible := cxShowAnglesBox.EditValue;

  tvMainPhi4.Visible := cxShowAnglesBox.EditValue;

  tvMain.EndUpdate;
end;

procedure TSourceData.cxShowIntensivityBoxPropertiesEditValueChanged(
  Sender: TObject);
begin
  tvMain.BeginUpdate;

  tvMainI1.Visible := cxShowIntensivityBox.EditValue;

  tvMainI2.Visible := cxShowIntensivityBox.EditValue;

  tvMainI3.Visible := cxShowIntensivityBox.EditValue;

  tvMainI4.Visible := cxShowIntensivityBox.EditValue;

  tvMain.EndUpdate;
end;

procedure TSourceData.cxShowPBoxPropertiesEditValueChanged(
  Sender: TObject);
begin
  tvMain.BeginUpdate;

  tvMainJ.Visible := cxShowPBox.EditValue;

  tvMainQ.Visible := cxShowPBox.EditValue;

  tvMainU.Visible := cxShowPBox.EditValue;

  tvMainV.Visible := cxShowPBox.EditValue;

  tvMainP.Visible := cxShowPBox.EditValue;

  tvMain.EndUpdate;
end;

procedure TSourceData.cxShowP0BoxPropertiesEditValueChanged(
  Sender: TObject);
begin
  tvMain.BeginUpdate;

  tvMainJ0.Visible := cxShowP0Box.EditValue;

  tvMainQ0.Visible := cxShowP0Box.EditValue;

  tvMainU0.Visible := cxShowP0Box.EditValue;

  tvMainV0.Visible := cxShowP0Box.EditValue;

  tvMainP0.Visible := cxShowP0Box.EditValue;

  tvMain.EndUpdate;
end;

procedure TSourceData.cxCheckBox5PropertiesEditValueChanged(
  Sender: TObject);
begin
  tvMain.BeginUpdate;

  tvMainAlfa1.Visible := cxShowHiBox.EditValue;

  tvMainBeta1.Visible := cxShowHiBox.EditValue;

  tvMainRe_Hi.Visible := cxShowHiBox.EditValue;

  tvMainIm_Hi.Visible := cxShowHiBox.EditValue;

  tvMainErrorCode01.Visible := cxShowHiBox.EditValue;

  tvMain.EndUpdate;
end;

procedure TSourceData.acCalcAllReflectionExecute(Sender: TObject);
begin
  fmProcessMsg.StartMessage('Выполняется расчет поляризации...');

  WriteLog := false;

  tvMain.BeginUpdate;

  dmPublic.tCalculation.First;

  while not dmPublic.tCalculation.Eof do
  begin
    acCalcReflection.Execute;

    dmPublic.tCalculation.Next;
  end;

  tvMain.EndUpdate;

  WriteLog := true;

  fmProcessMsg.EndMessage;
end;

end.
