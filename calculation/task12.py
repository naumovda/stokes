from math import sqrt, pi, sin, cos, atan
from cmath import phase
import os
from calculation import TIntensity, TStokesVector, TStokesNaturalVector
from gradient import Gradient

class TTask12:
    def __init__(self, WriteLog=False, isAnalitic=True):
        self.WriteLog = WriteLog
        self.isAnalitic = isAnalitic
        self.V = TStokesVector()
        self.N = TStokesNaturalVector()
        self.I = [TIntensity(0, 0, 0) for i in range(4)]

    def load(self, index, dI, Tau, Phi):
        self.I[index] = TIntensity(dI, Tau, Phi)

    def calcRadiation(self, nju, phi):
        self.V = TStokesVector()
        self.V.calculate(self.I[0], self.I[1], self.I[2], self.I[3], self.WriteLog)
        self.N = TStokesNaturalVector()
        self.N.calculateNatural(self.V, nju, phi, self.WriteLog)         
        return (self.V, self.N)

    def calcReflection(self, nju, phi, gradient, isAnalitic=True):
        self.V = TStokesVector()
        self.N = TStokesNaturalVector()

        self.V, self.N = self.calcRadiation(nju, phi)

        J = self.V.j
        Q = self.V.q
        U = self.V.u
        V = self.V.v
        # P = self.V.p

        if Q ** 2 + V ** 2 + U ** 2 < 1e-5:
            gradient.W = 0
            gradient.V = 0
        else:
            gradient.W = Q / sqrt(Q ** 2 + V **2 + U ** 2)
            gradient.V = U / sqrt(Q ** 2 + V **2 + U ** 2)
        
        x = x0 = 0 # в исходнике не задаётся начальное значение, в паскале в таком случае её исходное значение равно 0, здесь же будет ошибка
        y = y0 = 0
        x1 = x2 = 0
    
        if self.WriteLog:        
            # os.chdir(os.path.dirname(__file__)) 
            LogFile = open('LogPart03.txt', 'w')

            LogFile.writelines(
                ('Расчет параметров поляризации\n',
                '------------------------------------------------------\n',
                f'J = {J}\n',
                f'Q = {Q}\n',
                f'U = {U}\n',
                f'V = {V}\n',
                '------------------------------------------------------\n',
                f'Gamma = {gradient.GAMMA}\n',
                f'Q / sqrt(Q*Q + V*V + U*U) = {gradient.W}\n',
                f'U / sqrt(Q*Q + V*V + U*U) = {gradient.V}\n',
                '------------------------------------------------------\n',
                'Начальное приближение\n',
                f'x0 = {x0}\n',
                f'y0 = {y0}\n')
            )
            
        if self.isAnalitic:
            isDone = True
            Beta = abs(atan(V/sqrt(Q**2+U**2+(cos(gradient.GAMMA)**2)*(Q**2+V**2+U**2))))

            if gradient.GAMMA * V > 0:
                Beta *= -1
            
            Alpha = abs(atan(sin(2*Beta)/cos(2*Beta)*cos(gradient.GAMMA)))

            if abs(U) < 1e-5:
                Alpha = 0
            elif U < 0:
                Alpha *= -1

            if self.WriteLog:        
                LogFile.writelines( 
                    ('------------------------------------------------------\n',
                    'Найдено аналитическим методом:\n',
                    f'alpha = {Alpha}\n',
                    f'beta = {Beta}\n',
                    '------------------------------------------------------\n')
                    )
        else: 
            x, y, isDone = gradient.GradientMethod(x0, y0, 1e-5)

            if not isDone:
                # Редактирование БД (фрагмент кода опущен)
                if self.WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        'Метод градиента не смог найти минимум функции\n',
                        '------------------------------------------------------\n')
                    )
                    LogFile.close()                    
                return
            
            if abs(gradient.Fxy(x, y) > 1e-5):
                # Редактирование БД (фрагмент кода опущен)
                if self.WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        'Ошибка: система не имеет решения\n',
                        f'cos(2a)cos(2b) - cos(gamma)sin(2a)sin(2b) = {gradient.W}\n',
                        f'sin(2a)cos(2b) + cos(gamma)sin(2a)sin(2b) = {gradient.V}\n',
                        '------------------------------------------------------\n')
                    )
                    LogFile.close()
                return
            
            if self.WriteLog:
                LogFile.writelines(
                    ('------------------------------------------------------\n',
                    'Найдено решение методом градиента\n',
                    f'alpha1 = {x}\n',
                    f'beta1 = {y}\n',
                    '------------------------------------------------------\n')
                )
            
            a = cos(-2 * y) + gradient.W 
            b = sqrt(2) * sin(-2 * y)
            c = gradient.w - cos(-2 * y)
            d = b ** 2 - 4 * c * a

            if d < 0:
                # Редактирование БД (фрагмент кода опущен)
                if self.WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        f'Ошибка: не найдено второе решение alpha 2 для beta2 = {-y}\n',
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
            
        hi = complex(sin(Alpha)/cos(Alpha), sin(Beta)/cos(Beta))
        down = complex(1, -sin(Alpha)*sin(Beta)/cos(Alpha)/cos(Beta))
        hi = hi/down
        
        # Редактирование БД (фрагмент кода опущен)
        if self.WriteLog:
            LogFile.writelines(
                (f'alpha1 = {x}\n', # UnboundLocalError: local variable 'x' referenced before assignment, поэтому задаю начальное значение x = 0
                f'beta1 = {y}\n',
                f'alpha2 = {x2}\n',
                f'beta2 = {-y}\n',
                '------------------------------------------------------\n',
                f'alpha = (alpha1+alpha2)/2 = {round(Alpha, 2)}\n', # нужно ли округлять?
                f'beta = {round(Beta, 2)}\n',
                '------------------------------------------------------\n',
                f'Re(Hi) = {hi.real}\n',
                f'Im(Hi) = {hi.imag}\n',
                f'|Hi|   = {abs(hi)}\n',
                f'/_Hi   = {phase(hi)}, рад. = {phase(hi)/pi*180} град.\n',
                '------------------------------------------------------\n',
                'Расчет завершен\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()
    
if __name__ == '__main__':
    # from random import randrange
    # SourceData = TSourceData(WriteLog = True, isAnalitic = True) # для проверки всего кода следует тестировать с isAnalitic = True / False
    # SourceData.acCaclReflectionExecute()
    # SourceData.acCalcRadiationExecute()
    # if SourceData.WriteLog:
    #     os.startfile('LogPart01.txt')
    #     os.startfile('LogPart03.txt')
    pass