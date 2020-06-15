# МОДУЛЬ НЕ ЗАКОНЧЕН И НЕ ПРОТЕСТИРОВАН

from statistics import fsum, sqrt, mean, stdev
import Laplace

def CalcStat(Array, FieldName, LabelName, F1Name, F2Name, F3Name):
    midP = mean([value[FieldName] for value in Array if value['IsCalc']])
    sdP = stdev([value[FieldName] for value in Array]) # в исходнике СКО считается по всему массиву, а не только по IsCalc (или нет?)

    dictArray = ([value for value in Array if value['IsCalc']])
    for i in range(len(dictArray)):
        if abs(dictArray[i][FieldName] - midP) >= sdP:
            del dictArray[i]
    
    FieldNameArray = ([value[FieldName] for value in dictArray])
    mid = mean(fieldNameArray)

    Min = 1e+5
    Max = -1e+5

    if Min > min(FieldNameArray):
        Min = min(FieldNameArray)
    
    if Max < max(FieldNameArray):
        Max = max(FieldNameArray)
    
    sd = stdev(FieldNameArray)

    for i in range(len(dictArray)):
        dictArray[i][F1Name] = dictArray[i][FieldName] - mid
        dictArray[i][F2Name] = (dictArray[i][FieldName] - mid) ** 2
        dictArray[i][F3Name] = (dictArray[i][FieldName] - mid) / sd
    
    # some database stuff

    Min = 1e+5
    Max = -1e+5
    Ek = 0

    F3NameArray = [value[F3Name] for value in dictArray]

    if Min > min(F3NameArray):
        Min = min(F3NameArray)
    if Max < max(F3NameArray):
        Max = max(F3NameArray)
    
    if Ek < max([abs(value) for value in F3NameArray]):
        Ek = max([abs(value) for value in F3NameArray])
    
    # --------------------------------------------------------------

    INTERVALCOUNT = 5
    class TInterval:
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
    
    SumProb = 0
    IntervalLength = (Max - Min) / INTERVALCOUNT

    Intervals = [TInterval() for _ in range(INTERVALCOUNT)]
    for i in range(INTERVALCOUNT):
        Intervals[i].Number = i
        Intervals[i].ValueCount = 0
        Intervals[i].Low = Min + i * IntervalLength
        Intervals[i].High = Min + (i + 1) * IntervalLength
        Intervals[i].LaplaceValueLow = Laplace.FLaplace(Intervals[i].Low)
        Intervals[i].LaplaceValueHigh = Laplace.FLaplace(Intervals[i].High)
        Intervals[i].Pi = Intervals[i].LaplaceValueHigh - Intervals[i].LaplaceValueLow
        SumProb += Intervals[i].Pi
    
    for i in range(len(F3NameArray)):
        aValue = round(F3NameArray[i], 2)
        index_f = -1
        for j in range(INTERVALCOUNT):
            if abs(aValue - Intervals[j].High) < 1e-3:
                if j < INTERVALCOUNT // 2:
                    index_f = j + 1
                else:
                    index_f = j
                break
            if abs(aValue - Intervals[j].Low) < 1e-3:
                if j < INTERVALCOUNT // 2:
                    index_f = j
                else:
                    index_f = j - 1
                break
            if (aValue > Intervals[j].Low) and (aValue < Intervals[j].High + 1e-3):
                index_f = j
                break
        if index_f == -1:
            if aValue <= Min + 1e-2:
                index_f = 0
            else:
                index_f = INTERVALCOUNT - 1
        index = int(index_f)
        if index > INTERVALCOUNT - 1:
            index = INTERVALCOUNT - 1
        elif index < 0:
            index = 0
        Intervals[index].ValueCount += 1

    SumHi = 0
    for i in range(INTERVALCOUNT):
        Intervals[i].NPi = len(FieldNameArray) * Intervals[i].Pi
        Intervals[i].Ni_NPi = (Intervals[i].ValueCount - Intervals[i].NPi) ** 2
        Intervals[i].Ni_NPi_Norm = Intervals[i].Ni_NPi / Intervals[i].NPi
        SumHi += Intervals[i].Ni_NPi_Norm
    
    # SumHiTeor := InvChiSquareDistribution(IntervalCount - 3, 0.05); ???????????

    eMid = mean(FieldNameArray)
    eDisp = (fsum([value ** 2 for value in FieldNameArray]) / len(FieldNameArray) - eMid ** 2) * len(FieldNameArray) / (len(FieldNameArray) - 1)
    esd = sqrt(eDisp)

    eMax = 0
    if max([abs(value - eMid) for value in FieldNameArray]) > eMax:
        eMax = max([abs(value - eMid) for value in FieldNameArray])
    
    Ek = eMax
    Tk = Ek / esd
    FTk = 2 * Laplace.FLaplace(Tk)

    return FTk