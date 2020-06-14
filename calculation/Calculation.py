from math import sqrt, sin, cos
import os
import Complex # DataModuleUnit

class TStokesVector:
    def __init__(self):
        self.ValueJ = 0.0
        self.ValueQ = 0.0
        self.ValueU = 0.0
        self.ValueV = 0.0
        # self.ValueP
        self.ErrorCode = -1
    
    def GetJ(self):
        return self.ValueJ

    def GetQ(self):
        return self.ValueQ

    def GetU(self):
        return self.ValueU

    def GetV(self):
        return self.ValueV

    def GetP(self):
        if abs(self.GetJ()) < 1e-8:
            return 0.0
        else:
            result = sqrt(self.GetQ() * self.GetQ() + self.GetU() * self.GetU() + self.GetV() * self.GetV()) / self.GetJ()
            if result > 1:
                result = 1
            return result
    
    def Calculate(self, I1, I2, I3, I4, WriteLog):
        A = [([None] * 5) for _ in range(4)]
        B = X = [None] * 4

        def Swap(k, n):
            z = A[k][k]
            i = k
            for j in range(k + 1, n):
                if abs(A[j][k]) > z:
                    z = A[j][k]
                    i = j
            if i > k:
                for j in range(k, n):
                    A[i][j], A[k][j] = A[k][j], A[i][j]
                B[i], B[k] = B[k], B[i]
        
        def LogMatrix():
            if not WriteLog:
                return
            LogFile.write('------------------------------------------------------\n')
            for i in range(4):
                for j in range(4):
                    LogFile.write(f'{round(A[i][j], 2)}'.ljust(12))
                LogFile.write(f' | {B[i]}\n')
        
        self.ErrorCode = -1
        self.ValueJ = 0
        self.ValueQ = 0
        self.ValueU = 0
        self.ValueV = 0

        if WriteLog:
            LogFile = open('LogPart01.txt', 'w')
            LogFile.writelines(
                ('Расчет параметров вектора Стокса рассеянного излучения\n',
                '------------------------------------------------------\n',
                f'I1 = {I1.GetI()}\n',
                f'    tau1 = {I1.GetTau()}\n',
                f'    phi1 = {I1.GetPhi()}\n',
                f'I2 = {I2.GetI()}\n',
                f'    tau2 = {I2.GetTau()}\n',
                f'    phi2 = {I2.GetPhi()}\n',
                f'I3 = {I3.GetI()}\n',
                f'    tau3 = {I3.GetTau()}\n',
                f'    phi3 = {I3.GetPhi()}\n',
                f'I4 = {I4.GetI()}\n',
                f'    tau4 = {I4.GetTau()}\n',
                f'    phi4 = {I4.GetPhi()}\n')
            )

        B[0] = 2 * I1.GetI()
        B[1] = 2 * I2.GetI()
        B[2] = 2 * I3.GetI()
        B[3] = 2 * I4.GetI()

        A[0][0] = 1
        A[1][0] = 1
        A[2][0] = 1
        A[3][0] = 1

        A[0][1] = cos(2 * I1.GetPhi())
        A[1][1] = cos(2 * I2.GetPhi())
        A[2][1] = cos(2 * I3.GetPhi())
        A[3][1] = cos(2 * I4.GetPhi())

        A[0][2] = sin(2 * I1.GetPhi()) * cos(I1.GetTau())
        A[1][2] = sin(2 * I2.GetPhi()) * cos(I2.GetTau())
        A[2][2] = sin(2 * I3.GetPhi()) * cos(I3.GetTau())
        A[3][2] = sin(2 * I4.GetPhi()) * cos(I4.GetTau())

        A[0][3] = sin(2 * I1.GetPhi()) * sin(I1.GetTau())
        A[1][3] = sin(2 * I2.GetPhi()) * sin(I2.GetTau())
        A[2][3] = sin(2 * I3.GetPhi()) * sin(I3.GetTau())
        A[3][3] = sin(2 * I4.GetPhi()) * sin(I4.GetTau())

        LogMatrix()

        n = 4

        for i in range(n):  
            A[i][n] = B[i]
            X[i] = 0

        for k in range(n):
            if abs(A[k][k]) < 1e-10:
                List = [abs(value) for value in A[k]]
                idx = List.index(max(List[k:]))
                del List
                if idx != k:
                    Swap(k, idx)
                else:
                    if abs(A[k][n]) > 1e-8:
                        self.ErrorCode = 2
                    else:
                        self.ErrorCode = 1
                    return I1, I2, I3, I4

            for j in range(k + 1, n):
                r = A[j][k] / A[k][k]
                for i in range(n + 1):
                    A[j][i] -= r * A[k][i]
                B[j] -= r * B[k]

            LogMatrix()
    
        for k in reversed(range(n)):
            r = 0
            for j in range(k + 1, n):
                g = A[k][j] * X[j]
                r += g
            X[k] = (B[k] - r) / A[k][k]
        
        self.ValueJ = X[0]
        self.ValueQ = X[1]
        self.ValueU = X[2]
        self.ValueV = X[3]

        if WriteLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                f'J = {X[0]}\n',
                f'Q = {X[1]}\n',
                f'U = {X[2]}\n',
                f'V = {X[3]}\n',
                '------------------------------------------------------\n',
                f'P = {self.GetP()}\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()
        
        self.ErrorCode = 0

        return I1, I2, I3, I4


class TStokesNaturalVector(TStokesVector):
    def CalculateNatural(StokesVector, WriteLog):
        if WriteLog:            
            LogFile = open('LogPart02.txt', 'w')            
            LogFile.writelines(
                ('Расчет параметров вектора Стокса естественного излучения\n',
                '------------------------------------------------------\n',
                'Вектор Стокса рассеянного излучения\n',
                f'    J = {StokesVector.GetJ()}\n',
                f'    Q = {StokesVector.GetQ()}\n',
                f'    U = {StokesVector.GetU()}\n',
                f'    V = {StokesVector.GetV()}\n',
                f'    P = {StokesVector.GetP()}\n')
            )
        
        nju = DataModuleUnit.dmPublic.Nju
        nju2 = nju * nju
        cosphi = Complex.TComplex(cos(DataModuleUnit.dmPublic.Phi / 180 ), 0)
        sinphi = Complex.TComplex(sin(DataModuleUnit.dmPublic.Phi / 180 ), 0)
        sinphi2 = sinphi * sinphi
        sn = nju2 - sinphi2
        sq = sn.SquareRoot(0)
        if sq.Image > 0:
            sq = sn.SquareRoot(1)
        ch1 = cosphi - sq
        zn1 = cosphi + sq
        nju2cosphi = nju2 * cosphi
        ch2 = nju2cosphi - sq
        zn2 = nju2cosphi + sq
        r1 = ch1 / zn1
        r2 = ch2 / zn2

        r1_2 = r1.Module() ** 2
        r2_2 = r2.Module() ** 2
        r1r2_ = r1 * r2.Covariant()
        r1r2_2 = r1r2_.Module() ** 2

        self.ValueJ = (StokesVector.GetJ() * (r1_2 + r2_2) - StokesVector.GetQ() * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.ValueQ = (StokesVector.GetQ() * (r1_2 + r2_2) - StokesVector.GetJ * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.ValueU = (StokesVector.GetU() * r1r2_.Real() + StokesVector.GetV() * r1r2_.Image()) / r1r2_2
        self.ValueV = (StokesVector.GetV() * r1r2_.Real() - StokesVector.GetU() * r1r2_.Image()) / r1r2_2
        
        if WriteLog:
            LogFile.writelines(
            ('Исходные параметры\n',
            '------------------------------------------------------\n',
            f' Phi                    = {DataModuleUnit.dmPublic.Phi} град.\n',
            f' Nju                    = ({nju.Real()}, {nju.Image()})\n',
            '------------------------------------------------------\n',
            'Промежуточные переменные\n',
            '------------------------------------------------------\n',
            f' Nju^2                  = ({nju2.Real()}, {nju2.Image()})\n',
            f' Nju^2-sin(Phi)^2       = ({sn.Real()}, {sn.Image()})\n',
            f' SQRT(Nju^2-sin(Phi)^2) = ({sq.Real()}, {sq.Image()})\n',
            f' r1                     = ({r1.Real()}, {r1.Image()})\n',
            f' r2                     = ({r2.Real()}, {r2.Image()})\n',

            f' |r1|^2                 = {r1_2}\n',
            f' |r2|^2                 = {r2_2}\n',

            f' r1*_r2                 = {r1r2_.Real()}, {r1r2_.Image()})\n',
            f' |r1*_r2|^2             = {r1r2_2}\n',
            '------------------------------------------------------\n',
            'Вектор Стокса естественного излучения\n',
            f'  J0                    = {GetJ()}\n',
            f'  Q0                    = {GetQ()}\n',
            f'  U0                    = {GetU()}\n',
            f'  V0                    = {GetV()}\n',
            f'  P0                    = {GetP()}\n')
            )
            LogFile.close()


class TIntensity:
    def __init__(self, aI, aTau, aPhi):
        self.SetI(aI)
        self.SetTau(aTau)
        self.SetPhi(aPhi)
        os.chdir(os.path.dirname(__file__))
    
    def GetI(self):
        return self.ValueI
    
    def GetTau(self):
        return self.ValueTau
    
    def GetPhi(self):
        return self.ValuePhi
    
    def SetI(self, aValue):
        self.ValueI = aValue
    
    def SetTau(self, aValue):
        self.ValueTau = aValue
    
    def SetPhi(self, aValue):
        self.ValuePhi = aValue
    
    if __name__ == '__main__':
        def __repr__(self):
            return f'{self.GetI()}, {self.GetTau()}, {self.GetPhi()}'


if __name__ == '__main__':
    from random import randrange

    def getRandom():
        return tuple([randrange(-5, 5) for _ in range(3)])
    
    I = []

    for _ in range(4):
        I.append(TIntensity(*getRandom()))
    
    print(TStokesVector().Calculate(*I, True))