unit SourceDataTask3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormAbsUnit, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxBar, cxClasses, ActnList, ImgList,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, Menus, dxLayoutControl,
  dxLayoutcxEditAdapters, cxContainer, cxGroupBox, cxRadioGroup,
  dxLayoutLookAndFeels, StdCtrls, cxButtons, ADODB;

type
  TSourceTask3 = class(TFormListAbs)
    dxLayout: TdxLayoutControl;
    cxButton2: TcxButton;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutCalcRadiation: TdxLayoutGroup;
    dxLayoutItem8: TdxLayoutItem;
    dxLayoutLookAndFeelList1: TdxLayoutLookAndFeelList;
    dxLayoutCxLookAndFeel1: TdxLayoutCxLookAndFeel;
    cxSelectType: TcxRadioGroup;
    dxLayoutItem1: TdxLayoutItem;
    lvC1: TcxGridLevel;
    lvC2: TcxGridLevel;
    lvC3: TcxGridLevel;
    tvC1: TcxGridDBTableView;
    tvC2: TcxGridDBTableView;
    tvC3: TcxGridDBTableView;
    tvC1dTetta: TcxGridDBColumn;
    tvC1Q: TcxGridDBColumn;
    tvC1U: TcxGridDBColumn;
    tvC1V: TcxGridDBColumn;
    tvC1C1: TcxGridDBColumn;
    tvC1IsCalc: TcxGridDBColumn;
    tvC1DBColumn1SubMid: TcxGridDBColumn;
    tvC1DBColumn1SubMidSqr: TcxGridDBColumn;
    tvC1DBColumn1T: TcxGridDBColumn;
    tvC2dGamma: TcxGridDBColumn;
    tvC2U: TcxGridDBColumn;
    tvC2V: TcxGridDBColumn;
    tvC2C2: TcxGridDBColumn;
    tvC2IsCalc: TcxGridDBColumn;
    tvC2C2SubMid: TcxGridDBColumn;
    tvC2C2SubMidSqr: TcxGridDBColumn;
    tvC2DBColumn2T: TcxGridDBColumn;
    tvC3dGamma: TcxGridDBColumn;
    tvC3Alfa: TcxGridDBColumn;
    tvC3Beta: TcxGridDBColumn;
    tvC3C3: TcxGridDBColumn;
    tvC3IsCalc: TcxGridDBColumn;
    tvC3C3SubMid: TcxGridDBColumn;
    tvC3C3SubMidSqr: TcxGridDBColumn;
    tvC3C3T: TcxGridDBColumn;
    dxLayoutItem2: TdxLayoutItem;
    cxButtonCalc: TcxButton;
    tvMainSign: TcxGridDBColumn;
    tvMainParameterName: TcxGridDBColumn;
    tvMainParameterValue: TcxGridDBColumn;
    tvMainNumber: TcxGridDBColumn;
    acCalc: TAction;
    acCalcStat: TAction;
    lvC3_01: TcxGridLevel;
    tvC3_01: TcxGridDBTableView;
    tvC3_01Tetta: TcxGridDBColumn;
    tvC3_01N: TcxGridDBColumn;
    tvC3_01Lambda: TcxGridDBColumn;
    cxSourceType: TcxRadioGroup;
    dxLayoutItem3: TdxLayoutItem;
    cxCalcTask3_01: TcxButton;
    dxLayoutItem4: TdxLayoutItem;
    dxLayoutCalcRefraction: TdxLayoutGroup;
    cxPlaneType: TcxRadioGroup;
    dxLayoutItem5: TdxLayoutItem;
    cxCalcPlaneType: TcxButton;
    dxLayoutItem6: TdxLayoutItem;
    cxLog: TcxButton;
    dxLayoutItem7: TdxLayoutItem;
    acShowLog: TAction;
    dxLayoutGroup2: TdxLayoutGroup;
    procedure cxSelectTypePropertiesChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acCalcExecute(Sender: TObject);
    procedure acCalcStatExecute(Sender: TObject);
    procedure cxCalcTask3_01Click(Sender: TObject);
    procedure cxCalcPlaneTypeClick(Sender: TObject);
    procedure acShowLogExecute(Sender: TObject);
  public
    function CalcStat(var Table: TADOTable; FieldName: string; LabelName,
      F1Name, F2Name, F3Name: string): double;
  end;

var
  SourceTask3: TSourceTask3;

implementation

{$R *.dfm}

uses
  DataModuleUnit
  ,Laplase
  ,chisquaredistr
  ,Math
  ,ProcImportDataTask3_1Unit
  ,LogUnit
  ,Complex
  ;

procedure TSourceTask3.cxSelectTypePropertiesChange(Sender: TObject);
begin
  case cxSelectType.ItemIndex of
  0:
    begin
      Grid.ActiveLevel := lvC1;

      DS.DataSet := dmPublic.tC1;
    end;
  1:
    begin
      Grid.ActiveLevel := lvC2;

      DS.DataSet := dmPublic.tC2;
    end;
  2:
    begin
      Grid.ActiveLevel := lvC3;

      DS.DataSet := dmPublic.tC3;
    end;
  3:
    begin
      Grid.ActiveLevel := lvMain;

      DS.DataSet := dmPublic.tCalcTask3;
    end;
  4:
    begin
      Grid.ActiveLevel := lvC3_01;

      DS.DataSet := dmPublic.tCalcTask3_01;
    end;
  end;
end;

procedure TSourceTask3.FormShow(Sender: TObject);
begin
  inherited;

  cxSelectType.ItemIndex := 3;

  cxSelectTypePropertiesChange(Sender);
end;

procedure TSourceTask3.acCalcExecute(Sender: TObject);
begin
  // расчет первого признака
  with dmPublic do
  begin
    tC1.First;

    while not tC1.Eof do
    begin
      tC1.Edit;

      if tC1V.Value <> 0 then
      begin
        tC1C1.Value := (tC1Q.Value * sin(2*tC1dTetta.Value * Pi/180) + tC1U.Value
          * cos(2*tC1dTetta.Value * Pi/180)) / tC1V.Value;

        tC1IsCalc.Value := true;          
      end
      else
      begin
        tC1C1.Value := 0;

        tC1IsCalc.Value := false;
      end;

      tC1.Post;

      tC1.Next;
    end;
  end;

  //расчет второго признака
  with dmPublic do
  begin
    tC2.First;

    while not tC2.Eof do
    begin
      tC2.Edit;

      if tC2V.Value <> 0 then
      begin
        tC2C2.Value := tC2U.Value / tC2V.Value;

        tC2IsCalc.Value := true;
      end
      else
      begin
        tC2C2.Value := 0;

        tC2IsCalc.Value := false;
      end;

      tC2.Post;

      tC2.Next;
    end;
  end;

  //расчет третьего признака
  with dmPublic do
  begin
    tC3.First;

    while not tC3.Eof do
    begin
      tC3.Edit;

      tC3C3.Value := tC3Alfa.Value * tC3Beta.Value;
      //sin(2 * tC3Alfa.Value) * sin(2 * tC3Beta.Value);

      tC3IsCalc.Value := true;

      tC3.Post;

      tC3.Next;
    end;
  end;

  ShowMessage('Расчет завершен!');
end;

procedure TSourceTask3.acCalcStatExecute(Sender: TObject);
var
  p1, p2, p3: double;
begin
  // обнуление статистики
  dmPublic.tCalcTask3.First;

  while not dmPublic.tCalcTask3.Eof do
  begin
    dmPublic.tCalcTask3.Delete;

    dmPublic.tCalcTask3.First;
  end;

  p1 := CalcStat(dmPublic.tC1, 'C1', 'C1', 'С1SubMid', 'С1SubMidSqr', 'С1T');

  p2 := CalcStat(dmPublic.tC2, 'C2', 'C2', 'C2SubMid', 'C2SubMidSqr', 'С2T');

  p3 := CalcStat(dmPublic.tC3, 'C3', 'C3', 'C3SubMid', 'C3SubMidSqr', 'C3T');

  dmPublic.tCalcTask3.Append;
  dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
  dmPublic.tCalcTask3Number.Value := 0;
  dmPublic.tCalcTask3Sign.Value := '';
  dmPublic.tCalcTask3ParameterName.Value := 'Вероятность попадания объекта в класс';
  dmPublic.tCalcTask3ParameterValue.Value := p1 * p2 * p3;
  dmPublic.tCalcTask3.Post;
  
  ShowMessage('Расчет завершен!');
end;

function TSourceTask3.CalcStat(var Table: TADOTable; FieldName: string;
  LabelName, F1Name, F2Name, F3Name: string): double;
const
  IntervalCount = 5;
type
  TInterval = record
    Number: integer;

    Low, High: double;

    ValueCount: integer;

    LaplaseValueLow, LaplaseValueHigh,
    Pi, NPi, Ni_NPi, Ni_NPi_Norm: double;
  end;
var
  aValue, index_f, CountP, MidP, SKOP, Count, Mid, SKO, Min, Max, SumHi, SumHiTeor,
    SumProb, Ek, Tk, Ftk: double;

  eMid, eMin, eMax, eSKO, eDisp, eCount: double;

  i, index: integer;

  IntervalLength: double;

  Intervals: array of TInterval;

  s: String;
begin
  with dmPublic do
  begin
    CountP := 0; MidP := 0;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        CountP := CountP + 1;

        MidP := MidP + Table.FieldValues[FieldName];
      end;

      Table.Next;
    end;

    if CountP <> 0 then
      MidP := MidP / CountP;

    SKOP := 0;

    Table.First;

    while not Table.Eof do
    begin
      SKOP := SKOP + Sqr(Table.FieldValues[FieldName] - MidP);

      Table.Next;
    end;

    if CountP <> 1 then
      SKOP := Sqrt(SKOP / (CountP - 1))
    else
      SKOP := 0;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 1;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Среднее (по всем)';
    dmPublic.tCalcTask3ParameterValue.Value := MidP;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 2;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'СКО (по всем)';
    dmPublic.tCalcTask3ParameterValue.Value := SKOP;
    dmPublic.tCalcTask3.Post;

    Count := 0; Mid := 0; SKO := 0;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        Table.Edit;

        if abs(Table.FieldValues[FieldName] - MidP) < SKOP then
        begin
          Count := Count + 1;

          Mid := Mid + Table.FieldValues[FieldName];

          Table.FieldValues['IsCalc'] := true;
        end
        else
          Table.FieldValues['IsCalc'] := false;

        Table.Post;
      end;

      Table.Next;
    end;

    Mid := Mid / Count;

    Min := 1e+5;
    Max := -1e+5;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        if Min > Table.FieldValues[FieldName] then Min := Table.FieldValues[FieldName];
        if Max < Table.FieldValues[FieldName] then Max := Table.FieldValues[FieldName];

        SKO := SKO + Sqr(Table.FieldValues[FieldName] - Mid);
      end;

      Table.Next;
    end;

    SKO := Sqrt(SKO / (Count - 1));

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        Table.Edit;

        Table.FieldValues[F1Name] := Table.FieldValues[FieldName] - Mid;

        Table.FieldValues[F2Name] := Sqr(Table.FieldValues[FieldName] - Mid);

        Table.FieldValues[F3Name] := (Table.FieldValues[FieldName] - Mid) / SKO;

        Table.Post;
      end;

      Table.Next;
    end;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 3;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Минимальное';
    dmPublic.tCalcTask3ParameterValue.Value := Min;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 4;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Максимальное';
    dmPublic.tCalcTask3ParameterValue.Value := Max;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 5;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Среднее';
    dmPublic.tCalcTask3ParameterValue.Value := Mid;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 6;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Дисперсия';
    dmPublic.tCalcTask3ParameterValue.Value := SKO * SKO;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 7;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'СКО';
    dmPublic.tCalcTask3ParameterValue.Value := SKO;
    dmPublic.tCalcTask3.Post;

    Min := 1e+5;
    Max := -1e+5;

    Ek := 0;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        if Min > Table.FieldValues[F3Name] then Min := Table.FieldValues[F3Name];
        if Max < Table.FieldValues[F3Name] then Max := Table.FieldValues[F3Name];

        if Ek < abs(Table.FieldValues[F3Name]) then
          Ek := abs(Table.FieldValues[F3Name]);
      end;

      Table.Next;
    end;

    //IntervalCount := 5;
    //Min, Max - границы
    SetLength(Intervals, IntervalCount);

    SumProb := 0;

    IntervalLength := (Max - Min) / IntervalCount;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 8;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Минимальное (норм.)';
    dmPublic.tCalcTask3ParameterValue.Value := Min;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 9;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Максимальное (норм.)';
    dmPublic.tCalcTask3ParameterValue.Value := Max;
    dmPublic.tCalcTask3.Post;

    for i := 0 to IntervalCount - 1 do
    begin
      Intervals[i].Number := i;

      Intervals[i].ValueCount := 0;

      Intervals[i].Low := Min + i * IntervalLength;

      Intervals[i].High := Min + (i+1) * IntervalLength;

      //Intervals[i].LaplaseValueLow := FLaplase( (Intervals[i].Low - Mid) / SKO);
      //Intervals[i].LaplaseValueHigh := FLaplase( (Intervals[i].High - Mid) / SKO);

      Intervals[i].LaplaseValueLow := FLaplase( Intervals[i].Low );
      Intervals[i].LaplaseValueHigh := FLaplase( Intervals[i].High );

      Intervals[i].Pi := (Intervals[i].LaplaseValueHigh
        - Intervals[i].LaplaseValueLow);

      SumProb := SumProb + Intervals[i].Pi;
    end;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        aValue := RoundTo(Table.FieldValues[F3Name], -2);

        index_f := -1;

        for i := 0 to IntervalCount - 1 do
        begin
          if abs(aValue - Intervals[i].High) < 1e-3 then
          begin
            if i < IntervalCount div 2 then
              index_f := i + 1
            else
              index_f := i;

            break;
          end;

          if abs(aValue - Intervals[i].Low) < 1e-3 then
          begin
            if i < IntervalCount div 2 then
              index_f := i
            else
              index_f := i - 1;

            break;
          end;

          if (aValue > Intervals[i].Low) and (aValue < Intervals[i].High + 1e-3) then
          begin
            index_f := i;

            break;
          end;
        end;
       //index_f := (Table.FieldValues[F3Name] - Min) / IntervalLength + 1e-6;

       if index_f = -1 then
        if aValue <= Min + 1e-2 then
          index_f := 0
        else
          index_f := IntervalCount - 1;

       index := Trunc(index_f);

       if index > IntervalCount - 1 then
          index := IntervalCount - 1;

       if index < 0 then
          index := 0;

       Inc(Intervals[ index ].ValueCount);
      end;

      Table.Next;
    end;

    SumHi := 0;

    for i := 0 to IntervalCount - 1 do
    begin
      //Intervals[i].NPi := CountP * Intervals[i].Pi;
      //Intervals[i].NPi := Count * Intervals[i].Pi;

      Intervals[i].NPi := Count * Intervals[i].Pi / SumProb;

      Intervals[i].Ni_NPi := Sqr(Intervals[i].ValueCount - Intervals[i].NPi);

      Intervals[i].Ni_NPi_Norm := Intervals[i].Ni_NPi / Intervals[i].NPi;

      dmPublic.tCalcTask3.Append;
      dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
      dmPublic.tCalcTask3Number.Value := 11 + 2*i - 1;
      dmPublic.tCalcTask3Sign.Value := LabelName;
      dmPublic.tCalcTask3ParameterName.Value := 'Pi[' + IntToStr(i) + ']';
      dmPublic.tCalcTask3ParameterValue.Value := Intervals[i].Pi;
      dmPublic.tCalcTask3.Post;

      dmPublic.tCalcTask3.Append;
      dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
      dmPublic.tCalcTask3Number.Value := 11 + 2*i;
      dmPublic.tCalcTask3Sign.Value := LabelName;
      dmPublic.tCalcTask3ParameterName.Value := 'N[' + IntToStr(i) + ']';
      dmPublic.tCalcTask3ParameterValue.Value := Intervals[i].ValueCount;
      dmPublic.tCalcTask3.Post;

      SumHi := SumHi + Intervals[i].Ni_NPi_Norm;
    end;

    SumHiTeor := InvChiSquareDistribution(IntervalCount - 3, 0.05);

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 13;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Хи-квадрат (эмп.)';
    dmPublic.tCalcTask3ParameterValue.Value := SumHi;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 14;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Хи-квадрат (теор.)';
    dmPublic.tCalcTask3ParameterValue.Value := SumHiTeor;
    dmPublic.tCalcTask3.Post;

    eCount := 0; eMid := 0; eDisp := 0;

    Table.First;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
      begin
        eCount := eCount + 1;

        eMid := eMid + Table.FieldValues[FieldName];

        eDisp := eDisp + sqr(Table.FieldValues[FieldName]);
      end;

      Table.Next;
    end;

    eMid := eMid / eCount;

    eDisp := (eDisp / eCount - eMid * eMid) * eCount / (eCount - 1);

    eSKO := sqrt(eDisp);

    Table.First;

    eMax := 0;

    while not Table.Eof do
    begin
      if Table.FieldValues['IsCalc'] then
        if abs( Table.FieldValues[FieldName] - eMid ) > eMax then
          eMax := abs( Table.FieldValues[FieldName] - eMid );

      Table.Next;
    end;

    Ek := eMax;

    //Tk := Ek/ 1.96;
    //Tk := 1.42;
    Tk := Ek/ eSKO;
    //Tk := Ek;

    FTk := 2 * FLaplase( Tk );

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 15;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Ek=';
    dmPublic.tCalcTask3ParameterValue.Value := Ek;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 16;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Tk=';
    dmPublic.tCalcTask3ParameterValue.Value := Tk;
    dmPublic.tCalcTask3.Post;

    dmPublic.tCalcTask3.Append;
    dmPublic.tCalcTask3ObjectGUID.Value := NewGUID();
    dmPublic.tCalcTask3Number.Value := 17;
    dmPublic.tCalcTask3Sign.Value := LabelName;
    dmPublic.tCalcTask3ParameterName.Value := 'Ф(tk)=';
    dmPublic.tCalcTask3ParameterValue.Value := FTk;
    dmPublic.tCalcTask3.Post;
  end;

  Result := FTk;
end;

procedure TSourceTask3.cxCalcTask3_01Click(Sender: TObject);
var
  F: TForm;
begin
  //отображаем данные
  cxSelectType.ItemIndex := 4;

  tvC3_01.BeginUpdate;

  //очищаем данные
  dmPublic.tCalcTask3_01.First;

  while not dmPublic.tCalcTask3_01.Eof do
  begin
    dmPublic.tCalcTask3_01.Delete;

    dmPublic.tCalcTask3_01.First;
  end;

  tvC3_01.EndUpdate;

  //выполняем загрузку
  case cxSourceType.ItemIndex of
  0:
    F := TProcImportDataTask3_1.Execute(true);
  1:
    ShowMessage('В разработке');
  end;

end;

function Det2(a11, a21, a12, a22: double): double;
begin
  Result := a11 * a22 - a21 * a12;
end;

procedure TSourceTask3.cxCalcPlaneTypeClick(Sender: TObject);
type
  TParam = record
    Tetta1, Tetta2,
    A1, A2,
    V1, V2,
    U1, U2: double;
  end;

  TComplexLength = record
    Length: double;

    ReMin, ReMax, ImMin, ImMax: double;

    MaterialName,
    CoefLabel : string;
  end;
var
  i, idx, i1, i2: integer;

  val, nval, nmid: double;

  Tetta, Lambda: double;

  Params: array of TParam;

  RefractCoef: array of TComplexLength;
  RefractCoefCount: integer;

  Point: TComplex;

  ParamCount: integer;
  ValueCount: integer;
  MidCount: integer;

  U, V,
  Umid, Vmid,
  d1, d2, d3, d4: double;

  ReCoef, ImCoef: double;

  MinLength: double;
  MinIndex: integer;

  LogFile: TextFile;
begin
  AssignFile(LogFile, 'LogPart03_01.txt');

  Rewrite(LogFile);

  Writeln(LogFile, 'Определение материала покрытия');
  Writeln(LogFile, '------------------------------------------------------');

  case cxPlaneType.ItemIndex of
  0: Writeln(LogFile, '  Расчет коэффициента преломления диэлектрического покрытия');
  1: Writeln(LogFile, '  Расчет коэффициента преломления металлического покрытия');
  end;

  // определяем точку минимума
  dmPublic.tCalcTask3_01.First;

  i := 1; idx := 1;

  val := dmPublic.tCalcTask3_01Lambda.Value;

  while not dmPublic.tCalcTask3_01.Eof do
   begin
    if dmPublic.tCalcTask3_01Lambda.Value < val then
    begin
      idx := i;

      val := dmPublic.tCalcTask3_01Lambda.Value;
    end;

    i := i + 1;

    dmPublic.tCalcTask3_01.Next;
  end;

  Writeln(LogFile, '  индекс точки минимума = ', idx);

  Writeln(LogFile, 'Исходные данные для расчета');

  case cxPlaneType.ItemIndex of
  0: Writeln(LogFile, 'Tetta':10, 'Lambda':10, 'N':10);
  1: Writeln(LogFile, 'Tetta':10, 'Lambda':10, 'A':10);
  end;

  //вычисляем значение n
  dmPublic.tCalcTask3_01.First;

  i := 1; nmid := 0;

  while not dmPublic.tCalcTask3_01.Eof do
  begin
    Tetta := Pi * dmPublic.tCalcTask3_01Tetta.Value / 180;

    Lambda := dmPublic.tCalcTask3_01Lambda.Value;

    case cxPlaneType.ItemIndex of
    0: //диэлектрическая поверхность
      if i <= idx then
        nval := sin(Tetta) / cos(Tetta)
          * sqrt(1 + sqr(Lambda) - 2*Lambda*cos(2*Tetta)) / (1 - Lambda)
      else
        nval := sin(Tetta) / cos(Tetta)
          * sqrt(1 + sqr(Lambda) + 2*Lambda*cos(2*Tetta)) / (1 + Lambda);
    1: // металлическая поверхность
      if i <= idx then
        nval := sqr(sin(Tetta)) / cos(Tetta) * (1 + Lambda) / (1 - Lambda)
      else
        nval := sqr(sin(Tetta)) / cos(Tetta) * (1 - Lambda) / (1 + Lambda);
    end;

    nmid := nmid + nval;

    i := i + 1;

    dmPublic.tCalcTask3_01.Edit;

    dmPublic.tCalcTask3_01N.Value := nval;

    dmPublic.tCalcTask3_01.Post;

    Writeln(LogFile, Tetta*180/Pi:10:0, Lambda:10:4, nval:10:4);

    dmPublic.tCalcTask3_01.Next;
  end;

  nmid := nmid / (i - 1);

  ValueCount := i - 1;

  if cxPlaneType.ItemIndex = 0 then //неметаллическая поверхность
  begin
    ReCoef := nmid;

    ImCoef := 0;

    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Коэффициент преломления:');
    Writeln(LogFile, ReCoef:10:4);
  end
  else if cxPlaneType.ItemIndex = 1 then //металлическая поверхность
  begin
    i1 := 1;

    if odd(ValueCount) then
    begin
      ParamCount := ValueCount div 2 + 1;

      i2 := ParamCount;
    end
    else
    begin
      ParamCount := ValueCount div 2;

      i2 := round(ValueCount / 2 + 1);      
    end;

    SetLength(Params, ParamCount);

    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'начальный индекс i1  = ', i1);
    Writeln(LogFile, 'начальный индекс i2  = ', i2);
    Writeln(LogFile, 'количество уравнений = ', ParamCount);

    i := 1;

    dmPublic.tCalcTask3_01.First;    

    while not dmPublic.tCalcTask3_01.Eof do
    begin
      if i < ParamCount + 1 then
      begin
        Params[i - 1].Tetta1 := dmPublic.tCalcTask3_01Tetta.Value;

        Params[i - 1].A1 := dmPublic.tCalcTask3_01N.Value;
      end;

      if i >= i2 then
      begin
        Params[i - i2].Tetta2 := dmPublic.tCalcTask3_01Tetta.Value;

        Params[i - i2].A2 := dmPublic.tCalcTask3_01N.Value;
      end;

      i := i + 1;

      dmPublic.tCalcTask3_01.Next;
    end;

    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, '№':10, 'Tetta1':10, 'A1':10, 'Tetta2':10, 'A2':10, 'V':10, 'U':10);
    Writeln(LogFile, '------------------------------------------------------');

    Umid := 0; Vmid := 0; MidCount := 0;

    for i := 0 to ParamCount -  1 do
    begin
      Write(LogFile, i:10, Params[i].Tetta1:10:4, Params[i].A1:10:4, Params[i].Tetta2:10:4, Params[i].A2:10:4);

      d1 := Det2(
        sqr(sqr(Params[i].A1)) + Params[i].A1 * sqr(sin(Params[i].Tetta1 * Pi/ 180)),
        sqr(sqr(Params[i].A2)) + Params[i].A2 * sqr(sin(Params[i].Tetta2 * Pi/ 180)),
        sqr(Params[i].A1),
        sqr(Params[i].A2)
      );

      d2 := Det2(1, 1, sqr(Params[i].A1), sqr(Params[i].A2));

      if d1 / d2 < 0 then
        Writeln(LogFile, ' невозможно вычислить V, так как V*V = ',
          FloatToStrF(d1 / d2, ffFixed, 10, 2))
      else
      begin
        V := sqrt(d1 / d2);

        d3 := Det2(
          1,
          1,
          sqr(sqr(Params[i].A1)) + Params[i].A1 * sqr(sin(Params[i].Tetta1 * Pi/ 180)),
          sqr(sqr(Params[i].A2)) + Params[i].A2 * sqr(sin(Params[i].Tetta2 * Pi/ 180)),
        );

        d4 := Det2(1, 1, sqr(Params[i].A1), sqr(Params[i].A2));

        U := d3 / d4;

        if (abs(d2) > 1e-3) and (abs(d4) > 1e-3) then
        begin
          Vmid := Vmid + V;

          Umid := Umid + U;

          MidCount := MidCount + 1;

          Writeln(LogFile, V:10:4, U:10:4);
        end
        else
          Writeln(LogFile, ' система уравнений имеет неустойчивое решение!');
      end;
    end;

    Vmid := Vmid / MidCount;

    Umid := Umid / MidCount;

    ReCoef := sqrt((Umid + sqrt(Umid * Umid + 4 * Vmid * Vmid )) / 2);

    ImCoef := - Vmid / ReCoef;

    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Vmid = ', Vmid:10:4);
    Writeln(LogFile, 'Umid = ', Umid:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Коэффициент преломления:');
    Writeln(LogFile, 'Re=', ReCoef:10:4);
    Writeln(LogFile, 'Im=', ImCoef:10:4);
  end;

  //задаем значения рассчитанного коэффициента
  Point.Re := ReCoef;
  Point.Im := ImCoef;

  //считаем нужные материалы
  RefractCoefCount := 0;

  dmPublic.tMaterialRefraction.First;

  while not dmPublic.tMaterialRefraction.Eof do
  begin
    if (
         (cxPlaneType.ItemIndex = 0)
         and (abs(dmPublic.tMaterialRefractionImValueMin.Value) < 1e-3)
         and (abs(dmPublic.tMaterialRefractionImValueMax.Value) < 1e-3)
        ) or
       (
         (cxPlaneType.ItemIndex = 1)
         and (abs(dmPublic.tMaterialRefractionImValueMin.Value) > 1e-3)
         and (abs(dmPublic.tMaterialRefractionImValueMax.Value) > 1e-3)
        )
      then
      RefractCoefCount := RefractCoefCount + 1;

    dmPublic.tMaterialRefraction.Next;
  end;

  SetLength(RefractCoef, RefractCoefCount);

  //заполняем массив материалов

  i := 0;

  dmPublic.tMaterialRefraction.First;

  while not dmPublic.tMaterialRefraction.Eof do
  begin
    if ((cxPlaneType.ItemIndex = 0)
       and (abs(dmPublic.tMaterialRefractionImValueMin.Value) < 1e-3)
       and (abs(dmPublic.tMaterialRefractionImValueMax.Value) < 1e-3)) or
       ((cxPlaneType.ItemIndex = 1)
       and (abs(dmPublic.tMaterialRefractionImValueMin.Value) > 1e-3)
       and (abs(dmPublic.tMaterialRefractionImValueMax.Value) > 1e-3)) then
    begin
      RefractCoef[i].MaterialName := dmPublic.tMaterialRefractionMaterialName.Value;
      RefractCoef[i].CoefLabel := dmPublic.tMaterialRefractionLabel.Value;

      RefractCoef[i].ReMin := dmPublic.tMaterialRefractionReValueMin.Value;
      RefractCoef[i].ReMax := dmPublic.tMaterialRefractionReValueMax.Value;
      RefractCoef[i].ImMin := dmPublic.tMaterialRefractionImValueMin.Value;
      RefractCoef[i].ImMax := dmPublic.tMaterialRefractionImValueMax.Value;

      {
      case cxPlaneType.ItemIndex then
      0:
        begin
          if (ReCoef > RefractCoef[i].ReMin)
            and (ReCoef < RefractCoef[i].ReMax) then
            RefractCoef[i].Length := 0
          else
            RefractCoef[i].Length := Min(abs(ReCoef - RefractCoef[i].ReMin),
              abs(ReCoef - RefractCoef[i].ReMax));
        end;
      1:
        begin
      }
      RefractCoef[i].Length := Point.LengthToRectangle(
        RefractCoef[i].ReMin, RefractCoef[i].ReMax,
        RefractCoef[i].ImMin, RefractCoef[i].ImMax,
      );
      {
        end;
      end;
      }

      i := i + 1;
    end;

    dmPublic.tMaterialRefraction.Next;
  end;

  //ищем материал с минимальным расстоянием до нашей точки
  MinLength := 1e+38;
  MinIndex := -1;

  Writeln(LogFile, '------------------------------------------------------');
  Writeln(LogFile, 'Материалы':50, ' ', 'Коэффициент');

  for i := 0 to RefractCoefCount - 1 do
  begin
    Writeln(LogFile, RefractCoef[i].MaterialName:50, ' ', RefractCoef[i].CoefLabel);

    if RefractCoef[i].Length < MinLength then
    begin
      MinLength := RefractCoef[i].Length;

      MinIndex := i;
    end;
  end;

  Writeln(LogFile, '------------------------------------------------------');
  Writeln(LogFile, 'Наиболее близкий по характеристике материал к ':50, ' ('
    + FloatToStrF(ReCoef, ffFixed, 10, 2) + ';'
    + FloatToStrF(ImCoef, ffFixed, 10, 2) +')');

  Writeln(LogFile, RefractCoef[MinIndex].MaterialName:50, ' ',
    RefractCoef[MinIndex].CoefLabel);

  CloseFile(LogFile);
end;

procedure TSourceTask3.acShowLogExecute(Sender: TObject);
var
  F: TForm;
begin
  dmPublic.LogValue := 3;
  
  F := TLog.Execute();
end;

end.
