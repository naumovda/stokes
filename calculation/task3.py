import os
import csv

from math import pi, sin, cos, tan, exp, sqrt
from statistics import mean, stdev
from laplace import Laplace

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

    def calc(self):
        if self.V != 0:
            self.value = (self.Q*sin(2*self.dTetta*pi/180) \
                + self.U*cos(2*self.dTetta*pi/180))/self.V
            self.is_calc = True
        else:
            self.value = None
            self.is_calc = False
        return self.value

class itemC2:
    def __init__(self, dGamma, Q, U, V):
        super().__init__()
        self.dGamma = dGamma
        self.Q = Q
        self.U = U
        self.V = V

    def calc(self):
        if self.V != 0:
            self.value = self.U/self.V
            self.is_calc = True
        else:
            self.value = None
            self.is_calc = False

class itemC3:
    def __init__(self, dGamma, Alfa, Beta):
        super().__init__()        
        self.dGamma = dGamma
        self.Alfa = Alfa
        self.Beta = Beta
        self.is_calc = False
    
    def calc(self):
        self.value = self.Alfa*self.Beta        
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
    intervals = [] #[TInterval() for _ in range(icount)]
    for i in range(icount):
        item = TInterval()
        item.Number = i
        item.ValueCount = 0
        item.Low = imin + i * length
        item.High = imin + (i + 1) * length
        item.LaplaceValueLow = Laplace(item.Low)
        item.LaplaceValueHigh = Laplace(item.High)
        item.Pi = item.LaplaceValueHigh - item.LaplaceValueLow
        intervals.append(item)
    return intervals

def calcStat(data):
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
    # for item in intervals:
    #     print(item.Number, item.Low, item.High)

    SumProb = sum([item.Pi for item in intervals])
    
    for item in data_n:
        value = round(item.value_norm, 2)
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
    
    i = 0
    for item in intervals:
        item.NPi = count_n*item.Pi/SumProb
        item.Ni_NPi = (item.ValueCount - item.NPi) ** 2
        item.Ni_NPi_Norm = item.Ni_NPi / item.NPi    

        stat[10+2*i] = (f'Pi[{i}]', item.Pi)
        stat[10+2*i+1] = (f'N[{i}]', item.ValueCount)
        i += 2
    
    SumHi = sum([item.Ni_NPi_Norm for item in intervals])

    # InvChiSquareDistribution(IntervalCount - 3, 0.05);
    SumHiTeor = chi2P(0.05, TInterval.INTERVAL_COUNT-3)

    stat[i] = (f'Хи-квадрат (эмп.)', SumHi)
    stat[i+1] = (f'Хи-квадрат (теор.)', SumHiTeor)
    i += 2

    midE = mean([item.value for item in data if item.is_calc])
    sdE = stdev([item.value for item in data if item.is_calc])    
    Ek = max([abs(item.value - midE) for item in data if item.is_calc])
    Tk = Ek / sdE
    FTk = 2*Laplace(Tk)

    stat[i] = ('Ek', Ek)
    stat[i+1] = ('Tk', Tk)
    stat[i+2] = ('Ф(Tk)', FTk)
    # i += 3
    
    return FTk, stat

IS_DIELECTRIC = 0
IS_METALLIC = 1

class TSample:
    def __init__(self, Tetta, Lambda):
        self.Tetta = Tetta
        self.Lambda = Lambda
        self.N = None

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

def calcPlaneMaterial(data, materials, planeType, writeLog=True, logFileName='LogPart05.txt'):
    if writeLog:
        LogFile = open(logFileName, 'w', encoding="utf-8")
        LogFile.writelines(
            ('Определение материала покрытия\n',
            '------------------------------------------------------\n')            
        )

        if planeType == IS_DIELECTRIC:
            LogFile.writelines('  Расчет коэффициента преломления диэлектрического покрытия\n')
        elif planeType == IS_METALLIC:
            LogFile.writelines('  Расчет коэффициента преломления металлического покрытия\n')
        else:
            pass

    i = 0
    idx = 0
    val = data[0].Lambda
    for item in data:
        if item.Lambda < val:            
            idx = i
            val = item.Lambda
        i += 1

    if writeLog:
        LogFile.writelines(
            (f'  индекс точки минимума = {idx}\n',
            '------------------------------------------------------\n'
            'Исходные данные для расчета\n')
        )

    if writeLog:
        if planeType == IS_DIELECTRIC:
            LogFile.writelines('Tetta Lambda N\n')
        elif planeType == IS_METALLIC:
            LogFile.writelines('Tetta Lambda A\n')
        else:
            pass
    
    # вычисляем значение n
    i = 0    
    for item in data:
        Tetta = pi*item.Tetta/180.0
        Lambda = item.Lambda

        if planeType == IS_DIELECTRIC:

            if i <= idx:
                item.N = sin(Tetta)/cos(Tetta)\
                    *sqrt(1+Lambda**2-2*Lambda*cos(2*Tetta))\
                        /(1-Lambda)
            else:
                item.N = sin(Tetta)/cos(Tetta)\
                    *sqrt(1+Lambda**2+2*Lambda*cos(2*Tetta))\
                        /(1+Lambda)
        elif planeType == IS_METALLIC:
            if i <= idx:
                item.N = sin(Tetta)**2/cos(Tetta)*(1+Lambda)/(1-Lambda)
            else:
                item.N = sin(Tetta)**2/cos(Tetta)*(1-Lambda)/(1+Lambda)
        else:
            pass
        i += 1

    nmid = sum([item.N for item in data])/(len(data)-1)

    if writeLog:
        for item in data:
            LogFile.writelines(f'{item.Tetta:0.4f}\t{item.Lambda:0.4f}\t{item.N:0.4f}\n') 

    if planeType == IS_DIELECTRIC:
        coef = complex(nmid, 0)
    elif planeType == IS_METALLIC:
        count = len(data)-1
        if count // 2 == 1:
            ParamCount = count // 2 + 1
            i2 = count-1
        else:
            ParamCount = count // 2
            i2 = round(count/2)

        if writeLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                'начальный индекс i1  = 0\n',
                f'начальный индекс i2  = {i2}\n',
                f'количество уравнений = {ParamCount}\n')
            )

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

        if writeLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                'Tetta1, A1, Tetta2, A2, V, U\n',
                '------------------------------------------------------\n')  
            )
        
        u_mid = 0
        v_mid = 0
        c_mid = 0
        for item in params:
            if writeLog:
                LogFile.writelines(
                    f'{item.Tetta1}, {item.A1}, {item.Tetta2}, {item.A2}\n'
                )            
            d1 = det2(
                item.A1**4 + item.A1*sin(item.Tetta1*pi/180)**2,
                item.A2**4 + item.A2*sin(item.Tetta2*pi/180)**2,
                item.A1**2,
                item.A2**2
            )
            d2 = det2(1, 1, item.A1**2, item.A2**2)

            if d1/d2 <0:
                if writeLog:
                    LogFile.writelines(
                        f' невозможно вычислить V, так как V*V = {d1/d2}\n'
                    )                   
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
                if writeLog:
                    LogFile.writelines(f'V={v}, U={u}\n')                   
            else:
                if writeLog:
                    LogFile.writelines(f'система уравнений имеет неустойчивое решение!\n')
        v_mid /= c_mid
        u_mid /=c_mid

        re = sqrt((u_mid + sqrt(u_mid**2 + 4*v_mid**2))/2)
        coef = complex(re, -v_mid/re)

        if writeLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                ' Vmid = {Vmid}\n',
                ' Umid = {Umid}\n', 
                '------------------------------------------------------\n', 
                'Коэффициент преломления:\n',
                'Re={coef.real}:\n',
                'Im={coef.imag}:\n',
                '------------------------------------------------------\n')
            )

    if writeLog:
        LogFile.writelines(f'Коэффициент преломления: ({coef.real:0.4f}+{coef.imag:0.4f}j)\n') 

    if writeLog:
        LogFile.writelines(
            ('------------------------------------------------------\n',
            'Материалы, Коэффициент\n')
        ) 

    i = 0
    idx = 0
    length = 1e+38
    for item in materials:
        if writeLog:
            LogFile.writelines(f'{item.name}, {item.label}\n') 

        item.length = len2rect(
            coef.real, coef.imag, 
            item.re_min, item.re_max,
            item.im_min, item.im_max
        )
        if item.length < length:
            idx, length = i, item.length
        i += 1

    if writeLog:
        LogFile.writelines(
            ('------------------------------------------------------\n',
            f'Наиболее близкий по характеристике материал к Re={coef.real}, Im={coef.imag}:\n',
            f'{materials[idx].name}\n',
            f'{materials[idx].label}\n')
        ) 

    LogFile.close()

    return idx, materials[idx]

def loadC1(filename):
    """
    Read a C1.CSV file using csv.DictReader
    """
    data = []
    with open(filename) as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            dTetta = float(line['dTetta'])
            Q = float(line['Q'])
            U = float(line['U'])
            V = float(line['V'])
            item = itemC1(dTetta, Q, U, V)
            item.calc()
            data.append(item)
    return data

def loadC2(filename):
    """
    Read a C2.CSV file using csv.DictReader
    """
    data = []
    with open(filename) as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            # dGamma, Q, U, V
            dGamma = float(line['dGamma'])
            Q = float(line['Q'])
            U = float(line['U'])
            V = float(line['V'])
            item = itemC2(dGamma, Q, U, V)
            item.calc()
            data.append(item)
    return data

def loadC3(filename):
    """
    Read a C3.CSV file using csv.DictReader
    """
    data = []
    with open(filename) as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            # dGamma, Alfa, Beta
            dGamma = float(line['dGamma'])
            Alfa = float(line['Alfa'])
            Beta = float(line['Beta'])
            item = itemC3(dGamma, Alfa, Beta)
            item.calc()
            data.append(item)
    return data    

def loadMaterial(filename):
    """
    Read a MaterialRefraction.CSV file using csv.DictReader
    """
    data = []
    with open(filename, encoding="utf-8") as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            name = line['MaterialName'] 
            re_min = float(line['ReValueMin'])
            re_max = float(line['ReValueMax'])
            im_min = float(line['ImValueMin'])
            im_max = float(line['ImValueMax'])
            label = f'({re_min:0.2f}..{re_max:0.2f})+({im_min:0.2f}..{im_max:0.2f})j'
            item = TMaterial(name, label, re_min, re_max, im_min, im_max)
            data.append(item)
    return data 

def loadSamples(filename):
    """
    Read a samples file for plane type calculation
    """
    data = []
    with open(filename, encoding="utf-8") as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            Tetta = float(line['dTetta'])
            Lambda = float(line['Lambda'])
            item = TSample(Tetta, Lambda)
            data.append(item)
    return data 

def printStat(stat, filename, mode='w', title=None):
    LogFile = open(filename, mode, encoding="utf-8")   
    if title != None:
        LogFile.writelines(f'{title}\n')
    for key in sorted(stat.keys()):
        LogFile.writelines(f'{stat[key][0]}:\t{stat[key][1]:0.4f}\n')
    LogFile.writelines('-'*60+'\n')        
    LogFile.close()

def calcTask3(data, nju, phi, WriteLog=False, Idx=None):
    for item in data:
        if (Idx == None) or (item.Idx == Idx):
            pass
            # item.calcRadiation(nju, phi, WriteLog)

def test_Task03():
    os.chdir(os.path.dirname(__file__))     

    c1 = loadC1('../data/csv/C1.csv')
    c2 = loadC2('../data/csv/C2.csv')
    c3 = loadC3('../data/csv/C3.csv')

    p1, s1 = calcStat([item for item in c1 if item.value != None])
    p2, s2 = calcStat([item for item in c2 if item.value != None])
    p3, s3 = calcStat([item for item in c3 if item.value != None])

    filename = 'LogPart04.txt'
    
    printStat(s1, filename, 'w', 'Расчет признака С1')
    printStat(s2, filename, 'a', 'Расчет признака С2')
    printStat(s3, filename, 'a', 'Расчет признака С3')

    LogFile = open(filename, 'a', encoding="utf-8")   
    LogFile.writelines(f'Вероятность попадания объекта в класс = {p1*p2*p3:0.4f}')
    LogFile.close()

def test_Task04():
    os.chdir(os.path.dirname(__file__))     
    
    materials = loadMaterial('../data/csv/MaterialRefraction.csv')   
    
    data = loadSamples('../data/csv/task03_test01_diel.csv')
    planeType = IS_DIELECTRIC
    _, _ = calcPlaneMaterial(data, materials, planeType, \
        writeLog=True, logFileName='LogPart05_test01.txt')    
    # print(idx, material)

if __name__ == "__main__":   
    # test_Task03() 
    test_Task04() 
