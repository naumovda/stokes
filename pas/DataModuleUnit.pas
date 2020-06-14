unit DataModuleUnit;

interface

uses
  Forms, frxExportRTF, frxExportXLS, frxClass, frxExportPDF, DB, ADODB,
  frxDBSet, Classes, Complex;

type
  TdmPublic = class(TDataModule)
    Conn: TADOConnection;
    frxReport: TfrxReport;
    frxDB: TfrxDBDataset;
    dsCalculation: TDataSource;
    tCalculation: TADOTable;
    tCalculationObjectGUID: TWideStringField;
    tCalculationAlfa: TFloatField;
    tCalculationBeta: TFloatField;
    tCalculationTau1: TFloatField;
    tCalculationPhi1: TFloatField;
    tCalculationI1: TFloatField;
    tCalculationTau2: TFloatField;
    tCalculationPhi2: TFloatField;
    tCalculationI2: TFloatField;
    tCalculationTau3: TFloatField;
    tCalculationPhi3: TFloatField;
    tCalculationI3: TFloatField;
    tCalculationTau4: TFloatField;
    tCalculationPhi4: TFloatField;
    tCalculationI4: TFloatField;
    tCalculationJ: TFloatField;
    tCalculationQ: TFloatField;
    tCalculationU: TFloatField;
    tCalculationV: TFloatField;
    tCalculationErrorCode: TIntegerField;
    tCalculationObjectId: TIntegerField;
    frxPDFExport: TfrxPDFExport;
    frxXLSExport: TfrxXLSExport;
    frxRTFExport: TfrxRTFExport;
    tCalculationP: TFloatField;
    tIntervals: TADOTable;
    tIntervalsFieldName: TWideStringField;
    tIntervalsFieldMin: TFloatField;
    tIntervalsFieldMax: TFloatField;
    dsConstant: TDataSource;
    tConstant: TADOTable;
    tConstantCode: TWideStringField;
    tConstantName: TWideStringField;
    tConstantValue: TWideStringField;
    tConstantValueDouble: TFloatField;
    tCalculationJ0: TFloatField;
    tCalculationQ0: TFloatField;
    tCalculationU0: TFloatField;
    tCalculationV0: TFloatField;
    tCalculationP0: TFloatField;
    tCalculationAlfa1: TFloatField;
    tCalculationBeta1: TFloatField;
    tCalculationRe_Hi: TFloatField;
    tCalculationIm_Hi: TFloatField;
    tCalculationErrorCode01: TIntegerField;
    tCalculationGamma: TFloatField;
    dsC1: TDataSource;
    tC1: TADOTable;
    tC1ObjectGUID: TWideStringField;
    tC1ObjectId: TAutoIncField;
    tC1dTetta: TFloatField;
    tC1Q: TFloatField;
    tC1U: TFloatField;
    tC1V: TFloatField;
    tC1C1: TFloatField;
    tC1IsCalc: TBooleanField;
    tC1DSDesigner1SubMid: TFloatField;
    tC1DSDesigner1SubMidSqr: TFloatField;
    tC1DSDesigner1T: TFloatField;
    dsC2: TDataSource;
    tC2: TADOTable;
    tC2ObjectGUID: TWideStringField;
    tC2ObjectId: TAutoIncField;
    tC2dGamma: TFloatField;
    tC2Q: TFloatField;
    tC2U: TFloatField;
    tC2V: TFloatField;
    tC2C2: TFloatField;
    tC2IsCalc: TBooleanField;
    tC2C2SubMid: TFloatField;
    tC2C2SubMidSqr: TFloatField;
    tC2DSDesigner2T: TFloatField;
    dsC3: TDataSource;
    tC3: TADOTable;
    tC3ObjectGUID: TWideStringField;
    tC3ObjectId: TAutoIncField;
    tC3dGamma: TFloatField;
    tC3Alfa: TFloatField;
    tC3Beta: TFloatField;
    tC3C3: TFloatField;
    tC3IsCalc: TBooleanField;
    tC3C3SubMid: TFloatField;
    tC3C3SubMidSqr: TFloatField;
    tC3C3T: TFloatField;
    dsCalcTask3: TDataSource;
    tCalcTask3: TADOTable;
    tCalcTask3ObjectGUID: TWideStringField;
    tCalcTask3ObjectId: TAutoIncField;
    tCalcTask3Sign: TWideStringField;
    tCalcTask3Number: TIntegerField;
    tCalcTask3ParameterName: TWideStringField;
    tCalcTask3ParameterValue: TFloatField;
    dsCalcTask3_01: TDataSource;
    tCalcTask3_01: TADOTable;
    tCalcTask3_01ObjectGUID: TWideStringField;
    tCalcTask3_01ObjectId: TAutoIncField;
    tCalcTask3_01Tetta: TFloatField;
    tCalcTask3_01N: TFloatField;
    tCalcTask3_01Lambda: TFloatField;
    dsMaterialRefraction: TDataSource;
    tMaterialRefraction: TADOTable;
    tMaterialRefractionObjectGUID: TWideStringField;
    tMaterialRefractionObjectId: TAutoIncField;
    tMaterialRefractionMaterialName: TWideStringField;
    tMaterialRefractionReValueMin: TFloatField;
    tMaterialRefractionImValueMin: TFloatField;
    tMaterialRefractionReValueMax: TFloatField;
    tMaterialRefractionImValueMax: TFloatField;
    tMaterialRefractionLabel: TStringField;
    procedure tMaterialRefractionAfterInsert(DataSet: TDataSet);
    procedure tMaterialRefractionCalcFields(DataSet: TDataSet);

  public
    Jmin, Qmin, Umin, Vmin, Pmin,
    Jmax, Qmax, Umax, Vmax, Pmax: double;

    J0min, Q0min, U0min, V0min, P0min,
    J0max, Q0max, U0max, V0max, P0max: double;

    Phi, ReNju, ImNju: double;

    Nju: TComplex;

    Gamma: double;

    LogValue: integer;

    function GetOnline(): boolean;
    function SetOnline(const Value, Open, Save: boolean): boolean;
  end;

var
  dmPublic: TdmPublic;

function NewGUID(): string;
  
implementation
  uses
    IniFiles
    ,SysUtils
    ,StrUtils
    ,Controls
    ,Variants
    ;

{$R *.dfm}

function NewGUID(): string;
var
  guid: TGUID;
begin
  CreateGUID(guid);

  result := GUIDToString(guid);
end;

function TdmPublic.GetOnline(): boolean;
begin
  result := self.Conn.Connected;
end;

function TdmPublic.SetOnline(const Value, Open, Save: boolean): boolean;
begin
  tConstant.Open;

  tMaterialRefraction.Open;

  tCalculation.Open;

  tIntervals.Open;

  tC1.Open;
  tC2.Open;
  tC3.Open;

  tCalcTask3.Open;

  tCalcTask3_01.Open;

  Jmin := 0.0;
  Qmin := 0.0;
  Umin := 0.0;
  Vmin := 0.0;
  Pmin := 0.0;

  Jmax := 0.0;
  Qmax := 0.0;
  Umax := 0.0;
  Vmax := 0.0;
  Pmax := 0.0;

  tIntervals.First;

  while not tIntervals.Eof do
  begin
    if tIntervalsFieldName.Value = 'J' then
    begin
      Jmin := tIntervalsFieldMin.Value;

      Jmax := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'Q' then
    begin
      Qmin := tIntervalsFieldMin.Value;

      Qmax := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'U' then
    begin
      Umin := tIntervalsFieldMin.Value;

      Umax := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'V' then
    begin
      Vmin := tIntervalsFieldMin.Value;

      Vmax := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'P' then
    begin
      Pmin := tIntervalsFieldMin.Value;

      Pmax := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'J0' then
    begin
      J0min := tIntervalsFieldMin.Value;

      J0max := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'Q0' then
    begin
      Q0min := tIntervalsFieldMin.Value;

      Q0max := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'U0' then
    begin
      U0min := tIntervalsFieldMin.Value;

      U0max := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'V0' then
    begin
      V0min := tIntervalsFieldMin.Value;

      V0max := tIntervalsFieldMax.Value;
    end;

    if tIntervalsFieldName.Value = 'P0' then
    begin
      P0min := tIntervalsFieldMin.Value;

      P0max := tIntervalsFieldMax.Value;
    end;

    tIntervals.Next;
  end;

  if dmPublic.tConstant.Locate('Code', 'Fi', []) then
    Phi := dmPublic.tConstantValueDouble.Value
  else
    Phi := 0;

  if dmPublic.tConstant.Locate('Code', 'Re(Nju)', []) then
    ReNju := dmPublic.tConstantValueDouble.Value
  else
    ReNju := 0;

  if dmPublic.tConstant.Locate('Code', 'Im(Nju)', []) then
    ImNju := dmPublic.tConstantValueDouble.Value
  else
    ImNju := 0;

  if dmPublic.tConstant.Locate('Code', 'Gamma', []) then
    Gamma := dmPublic.tConstantValueDouble.Value * Pi/ 180
  else
    Gamma := Pi/4;

  Nju := TComplex.Create;

  Nju.Init(ReNju, ImNju);

  Result := true;
end;

procedure TdmPublic.tMaterialRefractionAfterInsert(DataSet: TDataSet);
begin
  tMaterialRefractionObjectGUID.Value := NewGUID;
end;

procedure TdmPublic.tMaterialRefractionCalcFields(DataSet: TDataSet);
var
  s: string;
begin
  if abs(tMaterialRefractionReValueMax.Value
    - tMaterialRefractionReValueMin.Value) < 1e-3 then
    s := FloatToStrF(tMaterialRefractionReValueMax.Value, ffFixed, 10, 2)
  else
    s := '(' + FloatToStrF(tMaterialRefractionReValueMin.Value, ffFixed, 10, 2)
      + '..' + FloatToStrF(tMaterialRefractionReValueMax.Value, ffFixed, 10, 2)
      + ')';

  if abs(tMaterialRefractionImValueMax.Value
    - tMaterialRefractionImValueMin.Value) < 1e-3 then
    if abs(tMaterialRefractionImValueMax.Value) < 1e-3 then
      s := s
    else
      s := s + '-' + FloatToStrF(-tMaterialRefractionImValueMax.Value, ffFixed, 10, 2)
        + 'i'
  else
    s := s + '- (' + FloatToStrF(-tMaterialRefractionImValueMin.Value, ffFixed, 10, 2)
      + '..' + FloatToStrF(-tMaterialRefractionImValueMax.Value, ffFixed, 10, 2)
      + ')i';

  tMaterialRefractionLabel.Value := s;
end;

end.
