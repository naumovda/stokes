import os
import csv

from math import sqrt, pi, sin, cos, tan, atan
from cmath import phase

from calculation import TIntensity, TStokesVector, TStokesNaturalVector
from gradient import Gradient

class TTask12:
    def __init__(self, Idx, Alfa, Beta):
        self.Idx = Idx
        self.Alfa = Alfa
        self.Beta = Beta
        self.V = TStokesVector()
        self.N = TStokesNaturalVector()
        self.I = [TIntensity(0, 0, 0) for i in range(4)]

    def load(self, index, dI, Tau, Phi):
        dI = float(dI)
        Tau = float(Tau)
        Phi = float(Phi)
        self.I[index] = TIntensity(dI, Tau, Phi)

    def calcRadiation(self, nju, phi, WriteLog=False):
        self.V = TStokesVector()
        self.V.calculate(self.I[0], self.I[1], self.I[2], self.I[3], WriteLog)
        self.N = TStokesNaturalVector()
        self.N.calculateNatural(self.V, nju, phi, WriteLog)         
        return (self.V, self.N)

    def calcReflection(self, nju, phi, gradient, isAnalitic=True, WriteLog=False):
        # self.V = TStokesVector()
        # self.N = TStokesNaturalVector()

        self.V, self.N = self.calcRadiation(nju, phi, WriteLog)

        J = self.V.J
        Q = self.V.Q
        U = self.V.U
        V = self.V.V

        if Q**2 + V**2 + U**2 < 1e-5:
            gradient.W = 0
            gradient.V = 0
        else:
            gradient.W = Q / sqrt(Q ** 2 + V **2 + U ** 2)
            gradient.V = U / sqrt(Q ** 2 + V **2 + U ** 2)
        
        x = x0 = 0 
        y = y0 = 0
        x1 = x2 = 0
    
        if WriteLog:        
            LogFile = open('LogPart03.txt', 'w', encoding="utf-8")

            LogFile.writelines(
                ('Расчет параметров поляризации\n',
                '------------------------------------------------------\n',
                f'J = {J:9.4f}\n',
                f'Q = {Q:9.4f}\n',
                f'U = {U:9.4f}\n',
                f'V = {V:9.4f}\n',
                '------------------------------------------------------\n',
                f'Gamma = {gradient.GAMMA:9.4f}\n',
                f'Q / sqrt(Q*Q + V*V + U*U) = {gradient.W:9.4f}\n',
                f'U / sqrt(Q*Q + V*V + U*U) = {gradient.V:9.4f}\n',
                '------------------------------------------------------\n',
                'Начальное приближение\n',
                f'x0 = {x0:9.4f}\n',
                f'y0 = {y0:9.4f}\n')
            )
            
        if isAnalitic:
            isDone = True
            Beta = abs(atan(V/sqrt(Q**2+U**2+(cos(gradient.GAMMA)**2)*(Q**2+V**2+U**2))))

            if gradient.GAMMA * V > 0:
                Beta *= -1
            
            Alpha = abs(atan(sin(2*Beta)/cos(2*Beta)*cos(gradient.GAMMA)))

            if abs(U) < 1e-5:
                Alpha = 0
            elif U < 0:
                Alpha *= -1

            if WriteLog:        
                LogFile.writelines( 
                    ('------------------------------------------------------\n',
                    'Найдено аналитическим методом:\n',
                    f'alpha = {Alpha:9.4f}\n',
                    f'beta  = {Beta:9.4f}\n',
                    '------------------------------------------------------\n')
                    )
        else: 
            x, y, isDone = gradient.GradientMethod(x0, y0, 1e-5)

            if not isDone:
                if WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        'Метод градиента не смог найти минимум функции\n',
                        '------------------------------------------------------\n')
                    )
                    LogFile.close()                    
                return
            
            if abs(gradient.Fxy(x, y) > 1e-5):
                if WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        'Ошибка: система не имеет решения\n',
                        f'cos(2a)cos(2b) - cos(gamma)sin(2a)sin(2b) = {gradient.W:9.4f}\n',
                        f'sin(2a)cos(2b) + cos(gamma)sin(2a)sin(2b) = {gradient.V:9.4f}\n',
                        '------------------------------------------------------\n')
                    )
                    LogFile.close()
                return
            
            if WriteLog:
                LogFile.writelines(
                    ('------------------------------------------------------\n',
                    'Найдено решение методом градиента\n',
                    f'alpha1 = {x:9.4f}\n',
                    f'beta1  = {y:9.4f}\n',
                    '------------------------------------------------------\n')
                )
            
            a = cos(-2 * y) + gradient.W 
            b = sqrt(2) * sin(-2 * y)
            c = gradient.w - cos(-2 * y)
            d = b ** 2 - 4 * c * a

            if d < 0:
                if WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        f'Ошибка: не найдено второе решение alpha 2 для beta2 = {-y:9.4f}\n',
                        '------------------------------------------------------\n')
                    )
                    LogFile.close()
                return
            
            x1 = atan((-b + sqrt(d)) / 2 / a)
            x2 = atan((-b - sqrt(d)) / 2 / a)
            if abs(x1 - x) > abs(x2 - x):
                x2 = x1
            Alpha = (x + x2) / 2
            if V > 0:
                Beta = -abs(y)
            else:
                Beta = abs(y)
            
        res = complex(tan(Alpha), tan(Beta)) / complex(1, -tan(Alpha)*tan(Beta))
        
        if WriteLog:
            LogFile.writelines(
                (f'alpha1 = {x:9.4f}\n', 
                f'beta1   = {y:9.4f}\n',
                f'alpha2  = {x2:9.4f}\n',
                f'beta2   = {-y:9.4f}\n',
                '------------------------------------------------------\n',
                f'alpha = (alpha1+alpha2)/2 = {Alpha:9.4f}\n', 
                f'beta = {Beta:9.4f}\n',
                '------------------------------------------------------\n',
                f'Re(Hi) = {res.real:9.4f}\n',
                f'Im(Hi) = {res.imag:9.4f}\n',
                f'|Hi|   = {abs(res):9.4f}\n',
                f'/_Hi   = {phase(res):9.4f}, рад. = {phase(res)/pi*180:9.4f} град.\n',
                '------------------------------------------------------\n',
                'Расчет завершен\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()

def loadTask12(filename):
    """
    Read a CSV file using csv.DictReader
    """
    data = []
    with open(filename) as f_obj:
        reader = csv.DictReader(f_obj, delimiter=';')
        for line in reader:
            item = TTask12(int(line['ObjectId']), line['Alfa'], line['Beta'])
            item.load(0, line['I1'], line['Tau1'], line['Phi1'])
            item.load(1, line['I2'], line['Tau2'], line['Phi2'])
            item.load(2, line['I3'], line['Tau3'], line['Phi3'])
            item.load(3, line['I4'], line['Tau4'], line['Phi4'])            
            data.append(item)
    return data

def calcTask1(data, nju, phi, WriteLog=False):
    for item in data:
        if item.Idx == 174:
            item.calcRadiation(nju, phi, WriteLog)
        # break

def calcTask2(data, nju, phi, gradient, isAnalitic=True, WriteLog=False):
    for item in data:
        if item.Idx == 174:
            item.calcReflection(nju, phi, gradient, isAnalitic, WriteLog)
        # break

if __name__ == '__main__':  
    os.chdir(os.path.dirname(__file__))     
    data = loadTask12('../data/csv/calculation.csv')

    nju = 1.4 - 4.53j
    phi = 52
    g = Gradient()

    calcTask1(data, nju, phi, True) 
    calcTask2(data, nju, phi, g, WriteLog=True)
