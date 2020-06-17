from math import pi, sin, cos, tan, exp, sqrt
from statistics import mean, stdev
from Laplace import Laplace

def det2(a11, a21, a12, a22):
  return a11*a22 - a21*a12

def len2rect(re, im, re1, re2, im1, im2):

    x1 = min(re1, re2)
    x2 = max(re1, re2)
    y1 = min(im1, im2)
    y2 = max(im1, im2)

    """
    1 | 2 | 3
    4 | - | 5
    6 | 7 | 8
    """

    if (re >= x1) and (re <= x2) and (im >= y1) and (im <= y2):
        return 0
    elif re < x1:
        if im > y2:
            return sqrt((re - x1)**2 + (im - y2)**2)
        elif im < y1:
            return sqrt((re - x1)**2 + (im - y1)**2)
        else:
            return abs(re - x1)
    elif re > x2:
        if im > y2:
            return sqrt((re - x2)**2 + (im - y2)**2)
        elif im < y1:
            return sqrt((re - x2)**2 + (im - y1)**2)
        else:
            return abs(re - x2)
    else:
        return min(abs(im - y1), abs(im - y2))

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
    def __init__(self, Tetta1, Tetta2, A1, A2, V1, V2, U1, U2):
        self.Tetta1 = Tetta1
        self.A1 = A1
        self.V1 = V1
        self.U1 = U1
        self.Tetta2 = Tetta2
        self.A2 = A2
        self.V2 = V2
        self.U2 = U2

class TMaterial:
    def __init__(self, name, label, re_min, re_max, im_min, im_max):
        self.name = name
        self.label = label
        self.re_min = re_min
        self.re_max = re_max
        self.im_min = im_min
        self.im_max = im_max
        self.length = 0

def calcPlaneMaterial(data, materials, planeType, writeLog):
    if writeLog:
        LogFile = open('LogPart03.txt', 'w')
        LogFile.writelines(
            'Определение материала покрытия\n',
            '------------------------------------------------------\n'
        )

        if planeType == IS_DIELECTRIC:
            LogFile.writelines('  Расчет коэффициента преломления диэлектрического покрытия')
        elif planeType == IS_METALLIC:
            LogFile.writelines('  Расчет коэффициента преломления металлического покрытия')
        else:
            pass

    idx = 0
    val = min([item.Lambda for item in data])
    for item in data:
        if val == item.Lambda:
            break
        idx += 1

    if writeLog:
        LogFile.writelines(
            f'  индекс точки минимума = {idx}\n',
            '------------------------------------------------------\n'
            'Исходные данные для расчета\n'
        )

    if writeLog:
        if planeType == IS_DIELECTRIC:
            LogFile.writelines('Tetta Lambda N')
        elif planeType == IS_METALLIC:
            LogFile.writelines('Tetta Lambda A')
        else:
            pass
    
    # вычисляем значение n
    i = 0    
    for item in data:
        Tetta = pi * item.Tetta.Value/180
        Lambda = item.Lambda

        if planeType == IS_DIELECTRIC:
            if i <= idx:
                item.N = tan(Tetta)*sqrt(1+Lambda**2-2*Lambda*cos(2*Tetta))/(1-Lambda)
            else:
                item.N = tan(Tetta)*sqrt(1+Lambda**2-2*Lambda*cos(2*Tetta))/(1+Lambda)
        elif planeType == IS_METALLIC:
            if i <= idx:
                item.N = sin(Tetta)**2/cos(Tetta)*(1+Lambda)/(1-Lambda)
            else:
                item.N = sin(Tetta)**2/cos(Tetta)*(1-Lambda)/(1+Lambda)
        else:
            pass

    nmid = mean([item.N for item in data])

    if writeLog:
        for item in data:
            LogFile.writelines(f'{item.Tetta*180/pi} {item.Lambda} {item.N}') 

    if planeType == IS_DIELECTRIC:
        coef = complex(nmid, 0)
    elif planeType == IS_METALLIC:
        count = len(data)
        if count // 2 == 1:
            ParamCount = count // 2 + 1
            i2 = count-1
        else:
            ParamCount = count // 2
            i2 = round(count/2)

#     Writeln(LogFile, '------------------------------------------------------');
#     Writeln(LogFile, 'начальный индекс i1  = ', 0);
#     Writeln(LogFile, 'начальный индекс i2  = ', i2);
#     Writeln(LogFile, 'количество уравнений = ', ParamCount);

        params = []
        for _ in range(ParamCount):
            params.append(TParam(0, 0, 0, 0, 0, 0, 0, 0))
        
        for i in range(len(data)):
            if i < ParamCount:
                params[i].Tetta1 = data.Tetta
                params[i].A1 = data.N
            if i >= i2:
                params[i].Tetta2 = data.Tetta
                params[i].A2 = data.N
            #     Writeln(LogFile, '------------------------------------------------------');
            #     Writeln(LogFile, '№':10, 'Tetta1':10, 'A1':10, 'Tetta2':10, 'A2':10, 'V':10, 'U':10);
            #     Writeln(LogFile, '------------------------------------------------------');
        
        u_mid = 0
        v_mid = 0
        c_mid = 0
        for item in params:
            # Write(LogFile, i:10, Params[i].Tetta1:10:4, Params[i].A1:10:4, Params[i].Tetta2:10:4, Params[i].A2:10:4);
            d1 = det2(
                item.A1**4 + item.A1*sin(item.Tetta1*pi/180)**2,
                item.A2**4 + item.A2*sin(item.Tetta2*pi/180)**2,
                item.A1**2,
                item.A2**2
            )
            d2 = det2(1, 1, item.A1**2, item.A2**2)

            if d1/d2 <0:
                #  Writeln(LogFile, ' невозможно вычислить V, так как V*V = ', FloatToStrF(d1 / d2, ffFixed, 10, 2))
                pass
            else:
                v = sqrt(d1/d2)
                d3 = det2(
                    1, 1,
                    item.A1**4 + item.A1*sin(item.Tetta1*pi/180)**2,
                    item.A2**4 + item.A2*sin(item.Tetta2*pi/180)**2
                )
                d4 = det2(1, 1, item.A1**2, item.A2**2)
                u = d3/d4

            if abs(d2)>1e-3 and abs(d4)>1e-3:
                v_mid += v
                u_mid += u
                c_mid += 1
                # Writeln(LogFile, V:10:4, U:10:4);                
            else:
                pass
                # Writeln(LogFile, ' система уравнений имеет неустойчивое решение!');          
        v_mid /= c_mid
        u_mid /=c_mid

        re = sqrt((u_mid + sqrt(u_mid**2 + 4*v_mid**2))/2)
        coef = complex(re, -v_mid/re)

        #     Writeln(LogFile, '------------------------------------------------------');
        #     Writeln(LogFile, 'Vmid = ', Vmid:10:4);
        #     Writeln(LogFile, 'Umid = ', Umid:10:4);
        #     Writeln(LogFile, '------------------------------------------------------');
        #     Writeln(LogFile, 'Коэффициент преломления:');
        #     Writeln(LogFile, 'Re=', ReCoef:10:4);
        #     Writeln(LogFile, 'Im=', ImCoef:10:4);

    else:
        pass

    if writeLog:
        LogFile.writelines(f'Коэффициент преломления: {coef}') 

    # ищем в массиве материалов

    idx = 0
    length = 1e+38
        #   Writeln(LogFile, '------------------------------------------------------');
        #   Writeln(LogFile, 'Материалы':50, ' ', 'Коэффициент');
    for item in materials:
        item = TMaterial('','',0,0,0,0)
        #     Writeln(LogFile, RefractCoef[i].MaterialName:50, ' ', RefractCoef[i].CoefLabel);
        item.length = len2rect(
            coef.real, coef.imag, 
            item.re_min, item.re_max,
            item.im_min, item.im_max
        )
        if item.length < length:
            idx, length = i, item.length
        idx += 1

#   Writeln(LogFile, '------------------------------------------------------');
#   Writeln(LogFile, 'Наиболее близкий по характеристике материал к ':50, ' ('
#     + FloatToStrF(ReCoef, ffFixed, 10, 2) + ';'
#     + FloatToStrF(ImCoef, ffFixed, 10, 2) +')');
#   Writeln(LogFile, RefractCoef[MinIndex].MaterialName:50, ' ',
#     RefractCoef[MinIndex].CoefLabel);

    LogFile.close()

    return idx, materials[idx]