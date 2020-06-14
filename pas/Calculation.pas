unit Calculation;

interface

uses
  Complex
  ,DataModuleUnit
  ;

type
  TIntesity = class;
  
  TStokesVector = class
      ValueJ: double;
      ValueQ: double;
      ValueU: double;
      ValueV: double;

      ValueP: double;

      ErrorCode: integer;
    public
      procedure Init();

      procedure Calculate(var I1, I2, I3, I4: TIntesity; WriteLog: Boolean);

      function GetJ(): double;
      function GetQ(): double;
      function GetU(): double;
      function GetV(): double;

      function GetP(): double;
  end;

  TStokesNaturalVector = class(TStokesVector)
    public
      procedure CalculateNatural(StokesVector: TStokesVector; WriteLog: Boolean);
  end;

  TIntesity = class
    ValueI:   double;
    ValueTau: double;
    ValuePhi: double;
  public
    procedure Init(aI, aTau, aPhi: double);

    function GetI(): double;
    function GetTau(): double;
    function GetPhi(): double;

    procedure SetI(aValue: double);
    procedure SetTau(aValue: double);
    procedure SetPhi(aValue: double);
  end;

implementation

procedure TIntesity.Init(aI, aTau, aPhi: double);
begin
  SetI(aI);

  SetTau(aTau);

  SetPhi(aPhi);
end;

function TIntesity.GetI(): double;
begin
  Result := ValueI;
end;

function TIntesity.GetTau(): double;
begin
  Result := ValueTau;
end;

function TIntesity.GetPhi(): double;
begin
  Result := ValuePhi;
end;

procedure TIntesity.SetI(aValue: double);
begin
  ValueI := aValue;
end;

procedure TIntesity.SetTau(aValue: double);
begin
  ValueTau := aValue;
end;

procedure TIntesity.SetPhi(aValue: double);
begin
  ValuePhi := aValue;
end;

procedure TStokesVector.Init();
begin
  ValueJ := 0.0;

  ValueQ := 0.0;

  ValueU := 0.0;

  ValueV := 0.0;

  ErrorCode := -1;
end;

function TStokesVector.GetJ(): double;
begin
  Result := ValueJ;
end;

function TStokesVector.GetQ(): double;
begin
  Result := ValueQ;
end;

function TStokesVector.GetU(): double;
begin
  Result := ValueU;
end;

function TStokesVector.GetV(): double;
begin
  Result := ValueV;
end;

function TStokesVector.GetP(): double;
begin
  if abs(GetJ()) < 1e-8 then
    Result := 0.0
  else
    Result := SQRT(GetQ() * GetQ() + GetU() * GetU() + GetV() * GetV()) / GetJ();

  if Result > 1 then
    Result := 1;
end;
                                
procedure TStokesVector.Calculate(var I1, I2, I3, I4: TIntesity; WriteLog: Boolean);
var
  A: array[1..4, 1..5] of double;
  B, X: array[1..4] of double;

  i, j, k, n, z, idx: integer;

  r, g, max: double;

  LogFile: TextFile;

  procedure Swap(k, n:integer);
  var
    i, j: integer;
    z:    double;
  begin
    z := A[k,k];

    i := k;

    for j := k + 1 to n do
      if abs(A[j, k]) > z then
      begin
        z := A[j, k];

        i := j;
      end;

    if i > k then
    begin
      for j := k to n do
      begin
        z := A[i, j];

        A[i, j] := A[k, j];

        A[k, j] := z;
      end;

      z := B[i];

      B[i] := B[k];

      B[k] := z;
    end;
  end;

  procedure LogMatrix;
  var
    i, j: integer;
  begin
    if not WriteLog then
      exit;
      
    Writeln(LogFile, '------------------------------------------------------');

    for i := 1 to 4 do
    begin
      for j := 1 to 4 do
        Write(LogFile, A[i, j]:10:4, ' ');

      Writeln(LogFile, ' | ', B[i]:10:4);
    end;
  end;

begin
  ErrorCode := -1;

  ValueJ := 0;
  ValueQ := 0;
  ValueU := 0;
  ValueV := 0;

  //Формируем протокол расчета
  if WriteLog then
  begin
    AssignFile(LogFile, 'LogPart01.txt');

    Rewrite(LogFile);

  //Выводим исходные параметры
    Writeln(LogFile, 'Расчет параметров вектора Стокса рассеянного излучения');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'I1 = ', I1.GetI():10:4);
    Writeln(LogFile, '  tau1 = ', I1.GetTau():10:4);
    Writeln(LogFile, '  phi1 = ', I1.GetPhi():10:4);
    Writeln(LogFile, 'I2 = ', I2.GetI():10:4);
    Writeln(LogFile, '  tau2 = ', I2.GetTau():10:4);
    Writeln(LogFile, '  phi2 = ', I2.GetPhi():10:4);
    Writeln(LogFile, 'I3 = ', I3.GetI():10:4);
    Writeln(LogFile, '  tau3 = ', I3.GetTau():10:4);
    Writeln(LogFile, '  phi3 = ', I3.GetPhi():10:4);
    Writeln(LogFile, 'I4 = ', I4.GetI():10:4);
    Writeln(LogFile, '  tau4 = ', I4.GetTau():10:4);
    Writeln(LogFile, '  phi4 = ', I4.GetPhi():10:4);
  end;

  B[1] := 2 * I1.GetI();
  B[2] := 2 * I2.GetI();
  B[3] := 2 * I3.GetI();
  B[4] := 2 * I4.GetI();

  A[1, 1] := 1;
  A[2, 1] := 1;
  A[3, 1] := 1;
  A[4, 1] := 1;

  A[1, 2] := cos(2*I1.GetPhi());
  A[2, 2] := cos(2*I2.GetPhi());
  A[3, 2] := cos(2*I3.GetPhi());
  A[4, 2] := cos(2*I4.GetPhi());

  A[1, 3] := sin(2*I1.GetPhi()) * cos(I1.GetTau());
  A[2, 3] := sin(2*I2.GetPhi()) * cos(I2.GetTau());
  A[3, 3] := sin(2*I3.GetPhi()) * cos(I3.GetTau());
  A[4, 3] := sin(2*I4.GetPhi()) * cos(I4.GetTau());

  A[1, 4] := sin(2*I1.GetPhi()) * sin(I1.GetTau());
  A[2, 4] := sin(2*I2.GetPhi()) * sin(I2.GetTau());
  A[3, 4] := sin(2*I3.GetPhi()) * sin(I3.GetTau());
  A[4, 4] := sin(2*I4.GetPhi()) * sin(I4.GetTau());

  LogMatrix;

  n := 4;

  for i := 1 to n do
  begin
    A[i, n + 1] := B[i];

    X[i] := 0;
  end;

  for k := 1 to n do //по строкам
  begin
    if abs(A[k, k]) < 1e-10 then
    begin
      //поиск максимального по модулю в столбце k ниже строки k
      max := abs(A[k, k]);

      idx := k;

      for z := k + 1 to n do
        if abs(A[k, z]) > max then
        begin
          idx := z;

          max := abs(A[k, z]);
        end;

      if idx <> k then
        Swap(k, idx)
      else
      begin
        if abs(A[k, n + 1]) > 1e-8 then
          ErrorCode := 2
        else
          ErrorCode := 1;

        exit;
      end;
    end;

    for j := k + 1 to n do //со следующей строки до последней
    begin
      r := A[j, k] / A[k, k]; //рассчитываем коэффициент

      for i := 1 to n + 1 do //по столбцам до последнего
        A[j, i] := A[j, i] - r * A[k, i];

      B[j] := B[j] - r * B[k];
    end;

    LogMatrix;
  end;

  for k := n downto 1 do
  begin
    r := 0;

    for j := k + 1 to n do
    begin
      g := A[k, j] * X[j];

      r := r + g;
    end;

    X[k] := (B[k] - r) / A[k, k];
  end;

  ValueJ := X[1];

  ValueQ := X[2];

  ValueU := X[3];

  ValueV := X[4];

  if WriteLog then
  begin
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'J  = ', X[1]:10:4);
    Writeln(LogFile, 'Q  = ', X[2]:10:4);
    Writeln(LogFile, 'U  = ', X[3]:10:4);
    Writeln(LogFile, 'V  = ', X[4]:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'P  = ', GetP():10:4);
    Writeln(LogFile, '------------------------------------------------------');

    CloseFile(LogFile);
  end;

  ErrorCode := 0;
end;

procedure TStokesNaturalVector.CalculateNatural(StokesVector: TStokesVector; WriteLog: Boolean);
var
  nju, nju2, cosphi, sinphi, sinphi2,
  sn, sq, ch1, zn1, ch2, zn2,
  nju2cosphi, r1, r2, r1r2_: TComplex;

  r1_2, r2_2, r1r2_2: double;

  LogFile: TextFile;
begin
  //Формируем протокол расчета
  if WriteLog then
  begin
    AssignFile(LogFile, 'LogPart02.txt');

    Rewrite(LogFile);

  //Выводим исходные параметры
    Writeln(LogFile, 'Расчет параметров вектора Стокса естественного излучения');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Вектор Стокса рассеянного излучения');
    Writeln(LogFile, '  J = ', StokesVector.GetJ():10:4);
    Writeln(LogFile, '  Q = ', StokesVector.GetQ():10:4);
    Writeln(LogFile, '  U = ', StokesVector.GetU():10:4);
    Writeln(LogFile, '  V = ', StokesVector.GetV():10:4);
    Writeln(LogFile, '  P = ', StokesVector.GetP():10:4);
  end;
  //расчет r1 и r2
  nju := dmPublic.Nju;

  nju2 := nju.Multiply(nju);

  cosphi := TComplex.Create;

  cosphi.Init( cos( dmPublic.Phi/180 ), 0);

  sinphi := TComplex.Create;

  sinphi.Init( sin( dmPublic.Phi/180 ), 0);

  sinphi2 := sinphi.Multiply(sinphi);

  sn := nju2.Substract(sinphi2);

  sq := sn.SquareRoot(0);

  if sq.Image > 0 then
    sq := sn.SquareRoot(1);

  ch1 := cosphi.Substract(sq);

  zn1 := cosphi.Add(sq);

  nju2cosphi := nju2.Multiply(cosphi);

  ch2 := nju2cosphi.Substract(sq);

  zn2 := nju2cosphi.Add(sq);

  r1 := ch1.Divide(zn1);

  r2 := ch2.Divide(zn2);

  //расчет действительных и мнимых частей
  r1_2 := r1.Module * r1.Module;

  r2_2 := r2.Module * r2.Module;

  r1r2_ := r1.Multiply(r2.Covariant());

  r1r2_2:= r1r2_.Module * r1r2_.Module;

  //расчет компонент вектора
  ValueJ := (StokesVector.GetJ * (r1_2 + r2_2) - StokesVector.GetQ * (r1_2 - r2_2))
    / (2 * r1_2 * r2_2);

  ValueQ := (StokesVector.GetQ * (r1_2 + r2_2) - StokesVector.GetJ * (r1_2 - r2_2))
    / (2 * r1_2 * r2_2);

  ValueU := (StokesVector.GetU * r1r2_.Real + StokesVector.GetV * r1r2_.Image) / r1r2_2;

  ValueV := (StokesVector.GetV * r1r2_.Real - StokesVector.GetU * r1r2_.Image) / r1r2_2;

  //Формируем протокол расчета
  if WriteLog then
  begin
    Writeln(LogFile, 'Исходные параметры');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, ' Phi                    = ', dmPublic.Phi:10:4, ' град.');
    Writeln(LogFile, ' Nju                    = (', nju.Real:10:4, ',', nju.Image:10:4, ')');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Промежуточные переменные');
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, ' Nju^2                  = (', nju2.Real:10:4, ',', nju2.Image:10:4, ')');
    Writeln(LogFile, ' Nju^2-sin(Phi)^2       = (', sn.Real:10:4, ',', sn.Image:10:4, ')');
    Writeln(LogFile, ' SQRT(Nju^2-sin(Phi)^2) = (', sq.Real:10:4, ',', sq.Image:10:4, ')');
    Writeln(LogFile, ' r1                     = (', r1.Real:10:4, ',', r1.Image:10:4, ')');
    Writeln(LogFile, ' r2                     = (', r2.Real:10:4, ',', r2.Image:10:4, ')');

    Writeln(LogFile, ' |r1|^2                 = ', r1_2:10:4);
    Writeln(LogFile, ' |r2|^2                 = ', r2_2:10:4);

    Writeln(LogFile, ' r1*_r2                 = (', r1r2_.Real:10:4, ',', r1r2_.Image:10:4, ')');
    Writeln(LogFile, ' |r1*_r2|^2             = ', r1r2_2:10:4);
    Writeln(LogFile, '------------------------------------------------------');
    Writeln(LogFile, 'Вектор Стокса естественного излучения');
    Writeln(LogFile, '  J0                    = ', GetJ():10:4);
    Writeln(LogFile, '  Q0                    = ', GetQ():10:4);
    Writeln(LogFile, '  U0                    = ', GetU():10:4);
    Writeln(LogFile, '  V0                    = ', GetV():10:4);
    Writeln(LogFile, '  P0                    = ', GetP():10:4);
    CloseFile(LogFile);
  end;
end;

end.
