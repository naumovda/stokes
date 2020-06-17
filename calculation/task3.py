from math import pi, sin, cos, exp
from statistics import fsum, sqrt, mean, stdev
from Laplace import Laplace

def chi2P(chi, df):
    """Return prob(chisq >= chi, with df degrees of freedom).
    df must be even.
    """
    assert df & 1 == 0
    # If chi is very large, exp(-m) will underflow to 0.
    m = chi / 2.0
    sum = term = exp(-m)
    for i in range(1, df//2):
        term *= m / i
        sum += term
    # With small chi and large df, accumulated
    # roundoff error, plus error in
    # the platform exp(), can cause this to spill
    # a few ULP above 1.0. For
    # example, chi2P(100, 300) on my box
    # has sum == 1.0 + 2.0**-52 at this
    # point.  Returning a value even a teensy
    # bit over 1.0 is no good.
    return min(sum, 1.0)

class itemC:
    def __init__(self):
        self.is_calc = False
        self.value = 0
        self.value_norm = 0

    def calc(self):
        pass        

class itemC1:
    def __init__(self, dTetta, Q, U, V):
        super().__init__()
        self.dTetta = dTetta
        self.Q = Q
        self.U = U
        self.V = V

        if self.V != 0:
            self.value = (Q*sin(2*dTetta*pi/180) + U*cos(2*dTetta*pi/180))/V
            self.is_calc = True
        else:
            self.value = 0
            self.is_calc = False

class itemC2:
    def __init__(self, dGamma, Q, U, V):
        super().__init__()
        self.dGamma = dGamma
        self.Q = Q
        self.U = U
        self.V = V

        if self.V != 0:
            self.value = U/V
            self.is_calc = True
        else:
            self.value = 0
            self.is_calc = False

class itemC3:
    def __init__(self, dGamma, Alfa, Beta):
        super().__init__()        
        self.dGamma = dGamma
        self.Alfa = Alfa
        self.Beta = Beta
        self.value = Alfa*Beta
        self.is_calc = True

class TInterval:
    INTERVAL_COUNT = 5

    def __init__(self):
        self.Number = None
        self.Low = None
        self.High = None
        self.ValueCount = None
        self.LaplaceValueLow = None
        self.LaplaceValueHigh = None
        self.Pi = None
        self.NPi = None
        self.Ni_NPi = None
        self.Ni_NPi_Norm = None

def getIntervals(icount, imax, imin):
    length = (imax - imin) / icount

    intervals = [TInterval() for _ in range(icount)]
    for i in range(icount):
        intervals[i].Number = i
        intervals[i].ValueCount = 0
        intervals[i].Low = imin + i * length
        intervals[i].High = imin + (i + 1) * length
        intervals[i].LaplaceValueLow = Laplace(intervals[i].Low)
        intervals[i].LaplaceValueHigh = Laplace(intervals[i].High)
        intervals[i].Pi = intervals[i].LaplaceValueHigh - intervals[i].LaplaceValueLow
    
    return intervals


def CalcStat(data):
    stat = {}

    countP = sum([1 for item in data if item.is_calc])
    midP = mean([item.value for item in data if item.is_calc])
    sdP = stdev([item.value for item in data if item.is_calc]) 

    stat[0] = ('Всего', countP) 
    stat[1] = ('Среднее (по всем)', midP)
    stat[2] = ('СКО (по всем)', sdP)

    data_n = []
    for item in data:
        item.is_calc = item.is_calc and abs(item.value-midP)<sdP 
        if item.is_calc:            
            data_n.append(item)

    # count = sum([1 for item in data_n])
    mid = mean([item.value for item in data_n])
    sd = stdev([item.value for item in data_n]) 
    min_v = min([item.value for item in data_n])
    max_v = max([item.value for item in data_n])

    for item in data:
        item.value_norm = (item.value - mid)/sd

    stat[3] = ('Минимальное', min_v) 
    stat[4] = ('Максимальное', max_v)
    stat[5] = ('Среднее', mid)
    stat[6] = ('Дисперсия', sd*sd)
    stat[7] = ('СКО', sd)

    count_n = sum([1 for item in data_n])
    min_n = min([item.value_norm for item in data_n])
    max_n = max([item.value_norm for item in data_n])

    stat[8] = ('Минимальное (норм)', min_n) 
    stat[9] = ('Максимальное (норм)', max_n)

    intervals = getIntervals(TInterval.INTERVAL_COUNT, max_n, min_n)

    SumProb = sum([item.Pi for item in intervals])
    
    for item in data_n:
        value = round(item.value, 2)
        index_f = -1
        for j in range(len(intervals)):
            if abs(value - intervals[j].High) < 1e-3:
                if j < TInterval.INTERVAL_COUNT // 2:
                    index_f = j + 1
                else:
                    index_f = j
                break
            if abs(value - intervals[j].Low) < 1e-3:
                if j < TInterval.INTERVAL_COUNT // 2:
                    index_f = j
                else:
                    index_f = j - 1
                break
            if (value > intervals[j].Low) and (value < intervals[j].High + 1e-3):
                index_f = j
                break
        if index_f == -1:
            if value <= min_n + 1e-2:
                index_f = 0
            else:
                index_f = TInterval.INTERVAL_COUNT - 1

        index = int(index_f)
        if index > TInterval.INTERVAL_COUNT - 1:
            index = TInterval.INTERVAL_COUNT - 1
        elif index < 0:
            index = 0
        intervals[index].ValueCount += 1
    
    i = 10
    for item in intervals:
        item.NPi = count_n*item.Pi/SumProb
        item.Ni_NPi = (item.ValueCount - item.NPi) ** 2
        item.Ni_NPi_Norm = item.Ni_NPi / item.NPi    

        stat[i] = (f'Pi[{i}]', item.Pi)
        stat[i+1] = (f'N[{i}]', item.ValueCount)
        i += 2
    
    SumHi = sum([item.Ni_NPi_Norm for item in intervals])

    # InvChiSquareDistribution(IntervalCount - 3, 0.05);
    SumHiTeor = chi2P(0.05, TInterval.INTERVAL_COUNT)

    stat[i] = (f'Хи-квадрат (эмп.)', SumHi)
    stat[i+1] = (f'Хи-квадрат (теор.)', SumHiTeor)
    i += 2

    midE = mean([item.value for item in data if item.is_calc])
    sdE = stdev([item.value for item in data if item.is_calc])    
    Ek = max([abs(item.value - midE) for item in data])
    Tk = Ek / sdE
    FTk = 2*Laplace(Tk)
    
    return FTk, stat

IS_DIELECTRIC = 0
IS_METALLIC = 1

class TCalc3:
    def __init__(self, Tetta, Lambda, N):
        self.Tetta = Tetta
        self.Lambda = Lambda
        self.N = N

class TParam:
    def __init__(self, Tetta, A, V, U):
        self.Tetta = Tetta
        self.A = A
        self.V = V
        self.U = U

class TMaterial:
    def __init__(self, name, label, re_min, re_max, im_min, im_max):
        self.name = name
        self.label = label
        self.re_min = re_min
        self.re_max = re_max
        self.im_min = im_min
        self.im_max = im_max
        self.length = 0

# var
#   i, idx, i1, i2: integer;
#   val, nval, nmid: double;
#   Tetta, Lambda: double;
#   Params: array of TParam;
#   RefractCoef: array of TComplexLength;
#   RefractCoefCount: integer;
#   Point: TComplex;
#   ParamCount: integer;
#   ValueCount: integer;
#   MidCount: integer;
#   U, V,
#   Umid, Vmid,
#   d1, d2, d3, d4: double;
#   ReCoef, ImCoef: double;
#   MinLength: double;
#   MinIndex: integer;
#   LogFile: TextFile;

def calcPlaneMaterial(data, planeType, writeLog):
    data = [TCalc3(0, 0, 0)] # потом убрать

    if writeLog:
        LogFile = open('LogPart03.txt', 'w')
#   Writeln(LogFile, 'Определение материала покрытия');
#   Writeln(LogFile, '------------------------------------------------------');
#   case cxPlaneType.ItemIndex of
#   0: Writeln(LogFile, '  Расчет коэффициента преломления диэлектрического покрытия');
#   1: Writeln(LogFile, '  Расчет коэффициента преломления металлического покрытия');

    
#   // определяем точку минимума
#   dmPublic.tCalcTask3_01.First;

#   i := 1; idx := 1;

#   val := dmPublic.tCalcTask3_01Lambda.Value;

#   while not dmPublic.tCalcTask3_01.Eof do
#    begin
#     if dmPublic.tCalcTask3_01Lambda.Value < val then
#     begin
#       idx := i;

#       val := dmPublic.tCalcTask3_01Lambda.Value;
#     end;

#     i := i + 1;

#     dmPublic.tCalcTask3_01.Next;
#   end;

#   Writeln(LogFile, '  индекс точки минимума = ', idx);

#   Writeln(LogFile, 'Исходные данные для расчета');

#   case cxPlaneType.ItemIndex of
#   0: Writeln(LogFile, 'Tetta':10, 'Lambda':10, 'N':10);
#   1: Writeln(LogFile, 'Tetta':10, 'Lambda':10, 'A':10);
#   end;

#   //вычисляем значение n
#   dmPublic.tCalcTask3_01.First;

#   i := 1; nmid := 0;

#   while not dmPublic.tCalcTask3_01.Eof do
#   begin
#     Tetta := Pi * dmPublic.tCalcTask3_01Tetta.Value / 180;

#     Lambda := dmPublic.tCalcTask3_01Lambda.Value;

#     case cxPlaneType.ItemIndex of
#     0: //диэлектрическая поверхность
#       if i <= idx then
#         nval := sin(Tetta) / cos(Tetta)
#           * sqrt(1 + sqr(Lambda) - 2*Lambda*cos(2*Tetta)) / (1 - Lambda)
#       else
#         nval := sin(Tetta) / cos(Tetta)
#           * sqrt(1 + sqr(Lambda) + 2*Lambda*cos(2*Tetta)) / (1 + Lambda);
#     1: // металлическая поверхность
#       if i <= idx then
#         nval := sqr(sin(Tetta)) / cos(Tetta) * (1 + Lambda) / (1 - Lambda)
#       else
#         nval := sqr(sin(Tetta)) / cos(Tetta) * (1 - Lambda) / (1 + Lambda);
#     end;

#     nmid := nmid + nval;

#     i := i + 1;

#     dmPublic.tCalcTask3_01.Edit;

#     dmPublic.tCalcTask3_01N.Value := nval;

#     dmPublic.tCalcTask3_01.Post;

#     Writeln(LogFile, Tetta*180/Pi:10:0, Lambda:10:4, nval:10:4);

#     dmPublic.tCalcTask3_01.Next;
#   end;

#   nmid := nmid / (i - 1);

#   ValueCount := i - 1;

#   if cxPlaneType.ItemIndex = 0 then //неметаллическая поверхность
#   begin
#     ReCoef := nmid;

#     ImCoef := 0;

#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, 'Коэффициент преломления:');
#     Writeln(LogFile, ReCoef:10:4);
#   end
#   else if cxPlaneType.ItemIndex = 1 then //металлическая поверхность
#   begin
#     i1 := 1;

#     if odd(ValueCount) then
#     begin
#       ParamCount := ValueCount div 2 + 1;

#       i2 := ParamCount;
#     end
#     else
#     begin
#       ParamCount := ValueCount div 2;

#       i2 := round(ValueCount / 2 + 1);      
#     end;

#     SetLength(Params, ParamCount);

#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, 'начальный индекс i1  = ', i1);
#     Writeln(LogFile, 'начальный индекс i2  = ', i2);
#     Writeln(LogFile, 'количество уравнений = ', ParamCount);

#     i := 1;

#     dmPublic.tCalcTask3_01.First;    

#     while not dmPublic.tCalcTask3_01.Eof do
#     begin
#       if i < ParamCount + 1 then
#       begin
#         Params[i - 1].Tetta1 := dmPublic.tCalcTask3_01Tetta.Value;

#         Params[i - 1].A1 := dmPublic.tCalcTask3_01N.Value;
#       end;

#       if i >= i2 then
#       begin
#         Params[i - i2].Tetta2 := dmPublic.tCalcTask3_01Tetta.Value;

#         Params[i - i2].A2 := dmPublic.tCalcTask3_01N.Value;
#       end;

#       i := i + 1;

#       dmPublic.tCalcTask3_01.Next;
#     end;

#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, '№':10, 'Tetta1':10, 'A1':10, 'Tetta2':10, 'A2':10, 'V':10, 'U':10);
#     Writeln(LogFile, '------------------------------------------------------');

#     Umid := 0; Vmid := 0; MidCount := 0;

#     for i := 0 to ParamCount -  1 do
#     begin
#       Write(LogFile, i:10, Params[i].Tetta1:10:4, Params[i].A1:10:4, Params[i].Tetta2:10:4, Params[i].A2:10:4);

#       d1 := Det2(
#         sqr(sqr(Params[i].A1)) + Params[i].A1 * sqr(sin(Params[i].Tetta1 * Pi/ 180)),
#         sqr(sqr(Params[i].A2)) + Params[i].A2 * sqr(sin(Params[i].Tetta2 * Pi/ 180)),
#         sqr(Params[i].A1),
#         sqr(Params[i].A2)
#       );

#       d2 := Det2(1, 1, sqr(Params[i].A1), sqr(Params[i].A2));

#       if d1 / d2 < 0 then
#         Writeln(LogFile, ' невозможно вычислить V, так как V*V = ',
#           FloatToStrF(d1 / d2, ffFixed, 10, 2))
#       else
#       begin
#         V := sqrt(d1 / d2);

#         d3 := Det2(
#           1,
#           1,
#           sqr(sqr(Params[i].A1)) + Params[i].A1 * sqr(sin(Params[i].Tetta1 * Pi/ 180)),
#           sqr(sqr(Params[i].A2)) + Params[i].A2 * sqr(sin(Params[i].Tetta2 * Pi/ 180)),
#         );

#         d4 := Det2(1, 1, sqr(Params[i].A1), sqr(Params[i].A2));

#         U := d3 / d4;

#         if (abs(d2) > 1e-3) and (abs(d4) > 1e-3) then
#         begin
#           Vmid := Vmid + V;

#           Umid := Umid + U;

#           MidCount := MidCount + 1;

#           Writeln(LogFile, V:10:4, U:10:4);
#         end
#         else
#           Writeln(LogFile, ' система уравнений имеет неустойчивое решение!');
#       end;
#     end;

#     Vmid := Vmid / MidCount;

#     Umid := Umid / MidCount;

#     ReCoef := sqrt((Umid + sqrt(Umid * Umid + 4 * Vmid * Vmid )) / 2);

#     ImCoef := - Vmid / ReCoef;

#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, 'Vmid = ', Vmid:10:4);
#     Writeln(LogFile, 'Umid = ', Umid:10:4);
#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, 'Коэффициент преломления:');
#     Writeln(LogFile, 'Re=', ReCoef:10:4);
#     Writeln(LogFile, 'Im=', ImCoef:10:4);
#   end;

#   //задаем значения рассчитанного коэффициента
#   Point.Re := ReCoef;
#   Point.Im := ImCoef;

#   //считаем нужные материалы
#   RefractCoefCount := 0;

#   dmPublic.tMaterialRefraction.First;

#   while not dmPublic.tMaterialRefraction.Eof do
#   begin
#     if (
#          (cxPlaneType.ItemIndex = 0)
#          and (abs(dmPublic.tMaterialRefractionImValueMin.Value) < 1e-3)
#          and (abs(dmPublic.tMaterialRefractionImValueMax.Value) < 1e-3)
#         ) or
#        (
#          (cxPlaneType.ItemIndex = 1)
#          and (abs(dmPublic.tMaterialRefractionImValueMin.Value) > 1e-3)
#          and (abs(dmPublic.tMaterialRefractionImValueMax.Value) > 1e-3)
#         )
#       then
#       RefractCoefCount := RefractCoefCount + 1;

#     dmPublic.tMaterialRefraction.Next;
#   end;

#   SetLength(RefractCoef, RefractCoefCount);

#   //заполняем массив материалов

#   i := 0;

#   dmPublic.tMaterialRefraction.First;

#   while not dmPublic.tMaterialRefraction.Eof do
#   begin
#     if ((cxPlaneType.ItemIndex = 0)
#        and (abs(dmPublic.tMaterialRefractionImValueMin.Value) < 1e-3)
#        and (abs(dmPublic.tMaterialRefractionImValueMax.Value) < 1e-3)) or
#        ((cxPlaneType.ItemIndex = 1)
#        and (abs(dmPublic.tMaterialRefractionImValueMin.Value) > 1e-3)
#        and (abs(dmPublic.tMaterialRefractionImValueMax.Value) > 1e-3)) then
#     begin
#       RefractCoef[i].MaterialName := dmPublic.tMaterialRefractionMaterialName.Value;
#       RefractCoef[i].CoefLabel := dmPublic.tMaterialRefractionLabel.Value;

#       RefractCoef[i].ReMin := dmPublic.tMaterialRefractionReValueMin.Value;
#       RefractCoef[i].ReMax := dmPublic.tMaterialRefractionReValueMax.Value;
#       RefractCoef[i].ImMin := dmPublic.tMaterialRefractionImValueMin.Value;
#       RefractCoef[i].ImMax := dmPublic.tMaterialRefractionImValueMax.Value;

#       {
#       case cxPlaneType.ItemIndex then
#       0:
#         begin
#           if (ReCoef > RefractCoef[i].ReMin)
#             and (ReCoef < RefractCoef[i].ReMax) then
#             RefractCoef[i].Length := 0
#           else
#             RefractCoef[i].Length := Min(abs(ReCoef - RefractCoef[i].ReMin),
#               abs(ReCoef - RefractCoef[i].ReMax));
#         end;
#       1:
#         begin
#       }
#       RefractCoef[i].Length := Point.LengthToRectangle(
#         RefractCoef[i].ReMin, RefractCoef[i].ReMax,
#         RefractCoef[i].ImMin, RefractCoef[i].ImMax,
#       );
#       {
#         end;
#       end;
#       }

#       i := i + 1;
#     end;

#     dmPublic.tMaterialRefraction.Next;
#   end;

#   //ищем материал с минимальным расстоянием до нашей точки
#   MinLength := 1e+38;
#   MinIndex := -1;

#   Writeln(LogFile, '------------------------------------------------------');
#   Writeln(LogFile, 'Материалы':50, ' ', 'Коэффициент');

#   for i := 0 to RefractCoefCount - 1 do
#   begin
#     Writeln(LogFile, RefractCoef[i].MaterialName:50, ' ', RefractCoef[i].CoefLabel);

#     if RefractCoef[i].Length < MinLength then
#     begin
#       MinLength := RefractCoef[i].Length;

#       MinIndex := i;
#     end;
#   end;

#   Writeln(LogFile, '------------------------------------------------------');
#   Writeln(LogFile, 'Наиболее близкий по характеристике материал к ':50, ' ('
#     + FloatToStrF(ReCoef, ffFixed, 10, 2) + ';'
#     + FloatToStrF(ImCoef, ffFixed, 10, 2) +')');

#   Writeln(LogFile, RefractCoef[MinIndex].MaterialName:50, ' ',
#     RefractCoef[MinIndex].CoefLabel);

#   CloseFile(LogFile);
# end;    