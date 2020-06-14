unit Complex;

interface

type
  TComplex = class
      Re, Im: double;

    public
      procedure Init(aRe, aIm: double);

      function Real(): double;

      function Image(): double;

      function Add(A:TComplex): TComplex; overload;

      function Substract(A:TComplex): TComplex;

      function Multiply(A:TComplex): TComplex;

      function Divide(A:TComplex): TComplex;

      function Covariant(): TComplex;

      function Module(): double;

      function Angle(): double;

      function SquareRoot(Index: integer): TComplex;

      function LengthToRectangle(ReMin, ReMax, ImMin, ImMax: double): double;
  end;

function Min(A, B: double): double;
function Max(A, B: double): double;
function Equal(A, B: double; Eps: double = 1e-3): Boolean;

implementation

function Min(A, B: double): double;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(A, B: double): double;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Equal(A, B: double; Eps: double = 1e-3): Boolean;
begin
  if abs(A - B) < abs(Eps) then
    Result := true
  else
    Result := false;
end;

procedure TComplex.Init(aRe, aIm: double);
begin
  Re := aRe;

  Im := aIm;
end;

function  TComplex.Real(): double;
begin
  Result := Re;
end;

function  TComplex.Image(): double;
begin
  Result := Im;
end;

function  TComplex.Add(A:TComplex): TComplex;
var
  R: TComplex;
begin
  R := TComplex.Create;

  R.Init(Re + A.Real(), Im + A.Image());

  Result := R;
end;

function  TComplex.Substract(A:TComplex): TComplex;
var
  R: TComplex;
begin
  R := TComplex.Create;

  R.Init(Re - A.Real(), Im - A.Image());

  Result := R;
end;

function  TComplex.Multiply(A:TComplex): TComplex;
var
  R: TComplex;
begin
  R := TComplex.Create;

  R.Init(Re * A.Real() - Im * A.Image(), Im * A.Real() + Re * A.Image());

  Result := R;
end;

function  TComplex.Divide(A:TComplex): TComplex;
var
  z: double;

  R: TComplex;
begin
  R := TComplex.Create;

  Z := A.Real * A.Real + A.Image * A.Image;

  R.Init((Re * A.Real + Im * A.Image) / Z, (Im * A.Real - Re * A.Image) / Z);

  Result := R;
end;

function  TComplex.Covariant(): TComplex;
var
  R: TComplex;
begin
  R := TComplex.Create;

  R.Init(Re, -Im);

  Result := R;
end;

function  TComplex.Module(): double;
begin
  Result := SQRT(Re * Re + Im * Im);
end;

function  TComplex.Angle(): double;
begin
  Result := 0;
  
  if Re < 1e-10 then
    if Im > 0 then
      Result := Pi/2
    else
      Result := -Pi/2
  else
    if Re > 0 then
      Result := arctan(Im / Re)
    else
      Result := Pi + arctan(Im / Re);
end;

function TComplex.SquareRoot(Index: integer): TComplex;
var
  a, phi: double;

  R: TComplex;
begin
  R := TComplex.Create;

  a := SQRT(SQRT(Re * Re + Im * Im));

  phi := ARCTAN(Im / Re);

  if Re < 0 then
    phi := phi + Pi;

  if (Index < 0) or (Index > 1) then
     Index := 0;

  if Index = 1 then
    phi := phi + Pi;

  R.Init(a * cos(phi), a * sin(phi));

  Result := R;
end;

function TComplex.LengthToRectangle(ReMin, ReMax, ImMin, ImMax: double): double;
var
  x1, x2, y1, y2: double;
begin
  x1 := Min(ReMin, ReMax);

  x2 := Max(ReMin, ReMax);

  y1 := Min(ImMin, ImMax);

  y2 := Max(ImMin, ImMax);

  {
  1 | 2 | 3
  4 | - | 5
  6 | 7 | 8
  }

  if (Re >= x1) and (Re <= x2) and (Im >= y1) and (Im <= y2) then
    Result := 0
  else if Re < x1 then
  begin //левее границы
    if Im > y2 then // 1
      Result := sqrt(sqr(Re - x1) + sqr(Im - y2))
    else if Im < y1 then // 6
      Result := sqrt(sqr(Re - x1) + sqr(Im - y1))
    else // 4
      Result := abs(Re - x1);
  end
  else if Re > x2 then
  begin //правее границы
    if Im > y2 then // 3
      Result := sqrt(sqr(Re - x2) + sqr(Im - y2))
    else if Im < y1 then // 8
      Result := sqrt(sqr(Re - x2) + sqr(Im - y1))
    else // 5
      Result := abs(Re - x2);
  end
  else
    Result := Min(abs(Im - y1), abs(Im - y2));
end;

end.
