unit Laplase;

interface

function FLaplase(x: double): double;

implementation

//вычисление определённого интеграла методом Симпсона
//a,b-пределы интеграла, eps-точность решения, Fun-подынтегральная функция

type
  TFunction = function(x: double): double;

function Simpson(Fun: TFunction; a,b,eps: double): double;
var
  i,n: integer;
  h,s0,s: double;
begin
  n:=1; s:=0;
  repeat
    n:=n*2; h:=(b-a)/n; s0:=s;
    s:=Fun(a)+Fun(b);
    for i:=1 to n-1 do
      s:=s+2*(1+i mod 2)*Fun(a+i*h);
    s:=s*(b-a)/(3*n);
  until abs(s-s0) <= eps;
  result:=s; 
end; //Simpson 
 
//подынтегральное выражение для вычисления нормированной функции Лапласа 
function Fun(t: double): double; 
begin 
  result:=exp(-t*t/2); 
end; //Fun 
 
//нормированная функция Лапласа
function FLaplase(x: double): double;
begin
  result := Simpson(Fun,0,x,1E-12)/sqrt(2*pi);
end; //F

end.
