from math import sqrt, sin, cos, pi, atan
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
        self.J = j
        self.Q = q
        self.U = u
        self.V = v
        self.error_code = -1  

    @property
    def P(self):
        if abs(self.J) < 1e-8:
            return 0.0
        else:
            result = sqrt(self.Q**2 + self.U**2 + self.V**2) / self.J
            if result > 1:
                result = 1
            return result
    
    def calculate(self, I1, I2, I3, I4, WriteLog):
        A = [([0] * 5) for _ in range(4)]
        X = [0] * 4

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
        
        def LogMatrix():
            if not WriteLog:
                return
            LogFile.write('------------------------------------------------------\n')
            for i in range(4):
                for j in range(4):
                    LogFile.write(f'{A[i][j]:9.4f}')
                LogFile.write(f' | {A[i][4]:9.4f}\n')
        
        self.ErrorCode = -1
        self.J = 0
        self.Q = 0
        self.U = 0
        self.V = 0

        if WriteLog:
            LogFile = open('LogPart01.txt', 'w', encoding="utf-8")
            LogFile.writelines(
                ('Расчет параметров вектора Стокса рассеянного излучения\n',
                '------------------------------------------------------\n',
                f'I1 = {I1.i:9.4f}\n',
                f'    tau1 = {I1.tau:9.4f}\n',
                f'    phi1 = {I1.phi:9.4f}\n',
                f'I2 = {I2.i:9.4f}\n',
                f'    tau2 = {I2.tau:9.4f}\n',
                f'    phi2 = {I2.phi:9.4f}\n',
                f'I3 = {I3.i:9.4f}\n',
                f'    tau3 = {I3.tau:9.4f}\n',
                f'    phi3 = {I3.phi:9.4f}\n',
                f'I4 = {I4.i:9.4f}\n',
                f'    tau4 = {I4.tau:9.4f}\n',
                f'    phi4 = {I4.phi:9.4f}\n')
            )

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

        A[0][4] = 2 * I1.i
        A[1][4] = 2 * I2.i
        A[2][4] = 2 * I3.i
        A[3][4] = 2 * I4.i

        n = 4
        LogMatrix()

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
                # B[j] -= r * B[k]

            LogMatrix()
    
        for k in reversed(range(n)):
            r = 0
            for j in range(k + 1, n):
                g = A[k][j] * X[j]
                r += g
            if A[k][k] == 0:
                self.error_code = -1
                LogFile.close()
                return
            X[k] = (A[k][4] - r) / A[k][k]
        
        self.J = X[0]
        self.Q = X[1]
        self.U = X[2]
        self.V = X[3]

        if WriteLog:
            LogFile.writelines(
                ('------------------------------------------------------\n',
                f'J = {X[0]:9.4f}\n',
                f'Q = {X[1]:9.4f}\n',
                f'U = {X[2]:9.4f}\n',
                f'V = {X[3]:9.4f}\n',
                '------------------------------------------------------\n',
                f'P = {self.P:9.4f}\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()
        
        self.error_code = 0

def SquareRoot(v, index):
    a = sqrt(sqrt(v.real**2 + v.imag**2))
    phi = atan(v.imag/v.real)
    if v.real < 0:
        phi += pi
    if (index < 0) or (index > 1):
        index = 0
    if index == 1:
        phi += pi
    return complex(a*cos(phi), a*sin(phi))

class TStokesNaturalVector(TStokesVector):
    def __init__(self, J=0, Q=0, U=0, V=0):
        super().__init__(J, Q, U, V)

    def calculateNatural(self, vector, nju, phi, WriteLog):
        if WriteLog:            
            LogFile = open('LogPart02.txt', 'w', encoding="utf-8")            
            LogFile.writelines(
                ('Расчет параметров вектора Стокса естественного излучения\n',
                '------------------------------------------------------\n',
                'Вектор Стокса рассеянного излучения\n',
                f'    J = {vector.J:9.4f}\n',
                f'    Q = {vector.Q:9.4f}\n',
                f'    U = {vector.U:9.4f}\n',
                f'    V = {vector.V:9.4f}\n',
                f'    P = {vector.P:9.4f}\n')
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

        self.J = (vector.J * (r1_2 + r2_2) - vector.Q * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.Q = (vector.Q * (r1_2 + r2_2) - vector.J * (r1_2 - r2_2)) / (2 * r1_2 * r2_2)
        self.U = (vector.U * r1r2_.real + vector.V * r1r2_.imag) / r1r2_2
        self.V = (vector.V * r1r2_.real - vector.U * r1r2_.imag) / r1r2_2
        
        if WriteLog:
            LogFile.writelines(
            ('Исходные параметры\n',
            '------------------------------------------------------\n',
            f' Phi                    = {phi:9.4f} град.\n',
            f' Nju                    = ({nju.real:9.4f}, {nju.imag:9.4f})\n',
            '------------------------------------------------------\n',
            'Промежуточные переменные\n',
            '------------------------------------------------------\n',
            f' Nju^2                  = ({nju2.real:9.4f}, {nju2.imag:9.4f})\n',
            f' Nju^2-sin(Phi)^2       = ({sn.real:9.4f}, {sn.imag:9.4f})\n',
            f' SQRT(Nju^2-sin(Phi)^2) = ({sq.real:9.4f}, {sq.imag:9.4f})\n',
            f' r1                     = ({r1.real:9.4f}, {r1.imag:9.4f})\n',
            f' r2                     = ({r2.real:9.4f}, {r2.imag:9.4f})\n',

            f' |r1|^2                 = {r1_2:9.4f}\n',
            f' |r2|^2                 = {r2_2:9.4f}\n',

            f' r1*_r2                 = {r1r2_.real:9.4f}, {r1r2_.imag:9.4f})\n',
            f' |r1*_r2|^2             = {r1r2_2:9.4f}\n',
            '------------------------------------------------------\n',
            'Вектор Стокса естественного излучения\n',
            f'  J0                    = {self.J:9.4f}\n',
            f'  Q0                    = {self.Q:9.4f}\n',
            f'  U0                    = {self.U:9.4f}\n',
            f'  V0                    = {self.V:9.4f}\n',
            f'  P0                    = {self.P:9.4f}\n')
            )
            LogFile.close()

if __name__ == '__main__':
    pass