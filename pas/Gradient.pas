unit Gradient;

interface

var
  Gamma: real = Pi/4;
  W: real = 0.77;
  V: real = -0.3;

type
  TFunction = function(x, y: real): real;

  function F(x, y: real): real;
  function dFdx(x, y: real): real;
  function dFdy(x, y: real): real;

  function GradientMethod(F, dFdx, dFdy: TFunction; x0, y0: real; eps: real;
    var x,y: real): Boolean;

implementation

function F(x, y: real): real;
begin
  Result := sqr(cos(2*x)*cos(2*y) - cos(Gamma)*sin(2*x)*sin(2*y) - W)
    + sqr(sin(2*x)*cos(2*y)+cos(Gamma)*cos(2*x)*sin(2*y) - V);
end;

function dFdx(x, y: real): real;
begin
  Result := 4*cos(2*x)*cos(gamma)*sin(2*y)*w + 4*cos(gamma)*sin(2*x)*sin(2*y)*v
    - 4*cos(2*x)*cos(2*y)*v+4*cos(2*y)*sin(2*x)*w;
  //2*cos(2*x)*sqrt(2)*sin(2*y)*W + 2*sqrt(2)*sin(2*x)*sin(2*y)*V
  //  - 4*cos(2*x)*cos(2*y)*V + 4*cos(2*y)*sin(2*x)*W;
end;

function dFdy(x, y: real): real;
begin
  Result := -4*cos(2*x)*cos(2*y)*cos(gamma)*v
    + 4*cos(2*y)*cos(gamma)*cos(gamma)*sin(2*y)
    + 4*cos(2*y)*cos(gamma)*sin(2*x)*w + 4*cos(2*x)*sin(2*y)*w
    + 4*sin(2*x)*sin(2*y)*v - 4*cos(2*y)*sin(2*y);
  //-2*cos(2*x)*cos(2*y)*sqrt(2)*V + 2*cos(2*y)*sqrt(2)*sin(2*x)*W
  //  + 4*cos(2*x)*sin(2*y)*W + 4*sin(2*x)*sin(2*y)*v-2*cos(2*y)*sin(2*y);
end;

function GradientMethod(F, dFdx, dFdy: TFunction; x0, y0: real; eps: real;
  var x,y: real): Boolean;
var
  t: real;

  xt, yt: real;

  Fx, Fxt: real;

  i, n: integer;
begin
  t := Pi/8;

  x := x0; y := y0;

  i := 0; n := 1000;

  repeat
    if i > n then
    begin
      x := x0;

      y := y0;

      Result := false;

      exit;
    end;

    xt := x - t * dFdx(x, y);

    yt := y - t * dFdy(x, y);

    if abs(sqrt((x - xt)*(x - xt))+sqrt((y - yt)*(y - yt))) < eps then
    begin
      x := xt;

      y := yt;

      Result := true;

      exit;
    end;

    Fx := F(x, y);

    Fxt := F(xt, yt);

    if Fx < Fxt then
      t := t / 2
    else
    begin
      x := xt;

      y := yt;
    end;

    i := i + 1;
  until false;
end;

end.
