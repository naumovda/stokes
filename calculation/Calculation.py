from math import *
# sqrt, sin, cos
import os

class TIntensity:
    def __init__(self, i, tau, phi):
        self._i = i
        self._tau = tau
        self._phi = phi
    
    @property
    def i(self):
        return self._i

    @property
    def tau(self):
        return self._tau

    @property
    def phi(self):
        return self._phi
    
    @i.setter
    def set_i(self, value):
        self._i = value
    
    @tau.setter
    def set_tau(self, value):
        self._tau = value

    @phi.setter
    def set_phi(self, value):
        self._phi = value

    def __repr__(self):
        return f'{self.i}, {self.tau}, {self.phi}'

class TStokesVector:
    def __init__(self, j=0, q=0, u=0, v=0):
        self._j = 0.0
        self._q = 0.0
        self._u = 0.0
        self._v = 0.0
        self.error_code = -1
    
    @property
    def j(self):
        return self._j

    @j.setter
    def set_j(self, value):
        self._j = value

    @property
    def q(self):
        return self._q

    @q.setter
    def set_q(self, value):
        self._q = value

    @property
    def u(self):
        return self._u

    @u.setter
    def set_u(self, value):
        self._u = value

    @property
    def v(self):
        return self._v

    @v.setter
    def set_v(self, value):
        self._v = value

    @property
    def p(self):
        if abs(self.j) < 1e-8:
            return 0.0
        else:
            result = sqrt(self.q**2 + self.u**2 + self.v**2) / self.j
            if result > 1:
                result = 1
            return result
    
    def calculate(self, I1, I2, I3, I4, WriteLog):
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
        self.j = 0
        self.q = 0
        self.u = 0
        self.v = 0

        if WriteLog:
            LogFile = open('LogPart01.txt', 'w')
            LogFile.writelines(
                ('Расчет параметров вектора Стокса рассеянного излучения\n',
                '------------------------------------------------------\n',
                f'I1 = {I1.i}\n',
                f'    tau1 = {I1.tau}\n',
                f'    phi1 = {I1.phi}\n',
                f'I2 = {I2.i}\n',
                f'    tau2 = {I2.tau}\n',
                f'    phi2 = {I2.phi}\n',
                f'I3 = {I3.GetI()}\n',
                f'    tau3 = {I3.tau}\n',
                f'    phi3 = {I3.phi}\n',
                f'I4 = {I4.i}\n',
                f'    tau4 = {I4.tau}\n',
                f'    phi4 = {I4.phi}\n')
            )

        B[0] = 2 * I1.i
        B[1] = 2 * I2.i
        B[2] = 2 * I3.i
        B[3] = 2 * I4.i

        A[0][0] = 1
        A[1][0] = 1
        A[2][0] = 1
        A[3][0] = 1

        A[0][1] = cos(2 * I1.phi)
        A[1][1] = cos(2 * I2.phi)
        A[2][1] = cos(2 * I3.phi)
        A[3][1] = cos(2 * I4.phi)

        A[0][2] = sin(2 * I1.phi) * cos(I1.tau)
        A[1][2] = sin(2 * I2.phi) * cos(I2.tau)
        A[2][2] = sin(2 * I3.phi) * cos(I3.tau)
        A[3][2] = sin(2 * I4.phi) * cos(I4.tau)

        A[0][3] = sin(2 * I1.phi) * sin(I1.tau)
        A[1][3] = sin(2 * I2.phi) * sin(I2.tau)
        A[2][3] = sin(2 * I3.phi) * sin(I3.tau)
        A[3][3] = sin(2 * I4.phi) * sin(I4.tau)

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
        
        self.j = X[0]
        self.q = X[1]
        self.u = X[2]
        self.v = X[3]

        if WriteLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                f'J = {X[0]}\n',
                f'Q = {X[1]}\n',
                f'U = {X[2]}\n',
                f'V = {X[3]}\n',
                '------------------------------------------------------\n',
                f'P = {self.p}\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()
        
        self.ErrorCode = 0

def SquareRoot(v, index):
    a = sqrt(v.real**2 + v.imag**2)
    phi = atan(v.imag/v.real)
    if v.real < 0:
        phi += pi
    if (index < 0) or (index > 1):
        index = 0
    if index == 1:
        phi += pi
    return complex(a*cos(phi), a*sin(phi))

class TStokesNaturalVector(TStokesVector):
    def __init__(self, j=0, q=0, u=0, v=0):
        super.__init__(self, j, q, u, v)

    def calculateNatural(self, vector, nju, phi, WriteLog):
        if WriteLog:            
            LogFile = open('LogPart02.txt', 'w')            
            LogFile.writelines(
                ('Расчет параметров вектора Стокса естественного излучения\n',
                '------------------------------------------------------\n',
                'Вектор Стокса рассеянного излучения\n',
                f'    J = {vector.j}\n',
                f'    Q = {vector.q}\n',
                f'    U = {vector.u}\n',
                f'    V = {vector.v}\n',
                f'    P = {vector.p}\n')
            )
        
        nju2 = nju**2
        
        cphi = cos(phi/180.0)
        sphi = sin(phi/180.0)
        cosphi = complex(cphi, 0)
        sinphi = complex(sphi, 0)             

        sinphi2 = sinphi * sinphi
        sn = nju2 - sinphi2

        sq = SquareRoot(sn, 0)        
        if sq.imag > 0:
            sq = SquareRoot(sn, 1)

        ch1 = cosphi - sq
        zn1 = cosphi + sq
        nju2cosphi = nju2 * cosphi
        ch2 = nju2cosphi - sq
        zn2 = nju2cosphi + sq
        r1 = ch1 / zn1
        r2 = ch2 / zn2

        r1_2 = abs(r1) ** 2
        r2_2 = abs(r2) ** 2
        r1r2_ = r1 * r2.conjugate()
        r1r2_2 = abs(r1r2_) ** 2

        self.j = (vector.GetJ() * (r1_2 + r2_2) - vector.GetQ() * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.q = (vector.GetQ() * (r1_2 + r2_2) - vector.GetJ * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.u = (vector.GetU() * r1r2_.Real() + vector.GetV() * r1r2_.Image()) / r1r2_2
        self.v = (vector.GetV() * r1r2_.Real() - vector.GetU() * r1r2_.Image()) / r1r2_2
        
        if WriteLog:
            LogFile.writelines(
            ('Исходные параметры\n',
            '------------------------------------------------------\n',
            f' Phi                    = {phi} град.\n',
            f' Nju                    = ({nju.real}, {nju.imag})\n',
            '------------------------------------------------------\n',
            'Промежуточные переменные\n',
            '------------------------------------------------------\n',
            f' Nju^2                  = ({nju2.real}, {nju2.imag})\n',
            f' Nju^2-sin(Phi)^2       = ({sn.real}, {sn.imag})\n',
            f' SQRT(Nju^2-sin(Phi)^2) = ({sq.real}, {sq.imag})\n',
            f' r1                     = ({r1.real}, {r1.imag})\n',
            f' r2                     = ({r2.real}, {r2.imag})\n',

            f' |r1|^2                 = {r1_2}\n',
            f' |r2|^2                 = {r2_2}\n',

            f' r1*_r2                 = {r1r2_.real}, {r1r2_.imag})\n',
            f' |r1*_r2|^2             = {r1r2_2}\n',
            '------------------------------------------------------\n',
            'Вектор Стокса естественного излучения\n',
            f'  J0                    = {self.j}\n',
            f'  Q0                    = {self.q}\n',
            f'  U0                    = {self.u}\n',
            f'  V0                    = {self.v}\n',
            f'  P0                    = {self.p}\n')
            )
            LogFile.close()

if __name__ == '__main__':
    pass