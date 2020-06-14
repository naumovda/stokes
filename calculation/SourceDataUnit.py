from math import sqrt, pi, sin, cos, atan
import os
import Calculation, Gradient, Complex

class TSourceData:
    if __name__ == '__main__': # в тестовых целях
        def __init__(self, WriteLog, isAnalitic):
            self.WriteLog = WriteLog
            self.isAnalitic = isAnalitic

    def acCalcRadiationExecute(self):
        Tau1 = randrange(5) # dmPublic.tCalculationTau1.Value
        Tau2 = randrange(5) # dmPublic.tCalculationTau2.Value
        Tau3 = randrange(5) # dmPublic.tCalculationTau3.Value
        Tau4 = randrange(5) # dmPublic.tCalculationTau4.Value

        Phi1 = randrange(5) # dmPublic.tCalculationPhi1.Value
        Phi2 = randrange(5) # dmPublic.tCalculationPhi2.Value
        Phi3 = randrange(5) # dmPublic.tCalculationPhi3.Value
        Phi4 = randrange(5) # dmPublic.tCalculationPhi4.Value

        dI1  = randrange(5) # dmPublic.tCalculationI1.Value
        dI2  = randrange(5) # dmPublic.tCalculationI2.Value
        dI3  = randrange(5) # dmPublic.tCalculationI3.Value
        dI4  = randrange(5) # dmPublic.tCalculationI4.Value

        I1 = Calculation.TIntensity(dI1, Tau1, Phi1)
        I2 = Calculation.TIntensity(dI2, Tau2, Phi2)
        I3 = Calculation.TIntensity(dI3, Tau3, Phi3)
        I4 = Calculation.TIntensity(dI4, Tau4, Phi4)

        V = Calculation.TStokesVector()

        V.Calculate(I1, I2, I3, I4, self.WriteLog)

        N = Calculation.TStokesNaturalVector()

        # N.CalculateNatural(V, self.WriteLog) # не работает, т.к. привязан к БД
        
        # Всё остальное в исходнике, как я понял,
        # связано либо с интерфейсом, либо с БД (фрагмент кода опущен)

    def acCaclReflectionExecute(self):
        J = randrange(5) # dmPublic.tCalculationJ.Value
        Q = randrange(5) # dmPublic.tCalculationQ.Value
        U = randrange(5) # dmPublic.tCalculationU.Value
        V = randrange(5) # dmPublic.tCalculationV.Value

        Gradient.GAMMA = randrange(5) # dmPublic.Gamma

        isAnalitic = True # = cxCalcType.ItemIndex – это что?

        if Q ** 2 + V ** 2 + U ** 2 < 1e-5:
            Gradient.W = 0
            Gradient.V = 0
        else:
            Gradient.W = Q / sqrt(Q ** 2 + V **2 + U ** 2)
            Gradient.V = U / sqrt(Q ** 2 + V **2 + U ** 2)
        
        x = x0 = 0 # в исходнике не задаётся начальное значение, в паскале в таком случае её исходное значение равно 0, здесь же будет ошибка
        y = y0 = 0
        x1 = x2 = 0
    
        if self.WriteLog:        
            os.chdir(os.path.dirname(__file__)) # достаточно ли прописать это только в одном из модулей?
            LogFile = open('LogPart03.txt', 'w')

            LogFile.writelines(
                ('Расчет параметров поляризации\n',
                '------------------------------------------------------\n',
                f'J = {J}\n',
                f'Q = {Q}\n',
                f'U = {U}\n',
                f'V = {V}\n',
                '------------------------------------------------------\n',
                f'Gamma = {Gradient.GAMMA}\n',
                f'Q / sqrt(Q*Q + V*V + U*U) = {Gradient.W}\n',
                f'U / sqrt(Q*Q + V*V + U*U) = {Gradient.V}\n',
                '------------------------------------------------------\n',
                'Начальное приближение\n',
                f'x0 = {x0}\n',
                f'y0 = {y0}\n')
            )
            
        if self.isAnalitic:
            isDone = True
            Beta = abs(atan(V / sqrt(Q ** 2 + U ** 2 + (cos(Gradient.GAMMA)) ** 2 * (Q ** 2 + V ** 2 + U ** 2))))

            if Gradient.GAMMA * V > 0:
                Beta *= -1
            
            Alpha = abs(atan(sin(2 * Beta) / cos(2 * Beta) * cos(Gradient.GAMMA)))

            if abs(U) < 1e-5:
                Alpha = 0
            elif U < 0:
                Alpha *= -1

            LogFile.writelines( # в исходнике не проверяется условие Writelog, в случае если False будет NameError (?)
                ('------------------------------------------------------\n',
                'Найдено аналитическим методом:\n',
                f'alpha = {Alpha}\n',
                f'beta = {Beta}\n',
                '------------------------------------------------------\n')
            )

        else: # не всегда работает, т.к. NameError: name 'w' is not defined (я не понял, откуда w, возможно Gradient.W)
            isDone = Gradient.GradientMethod(Gradient.F, Gradient.dFdx, Gradient.dFdy, x0, y0, 1e-5)
            x = isDone[0]; y = isDone[1]; isDone = isDone[2]
            # т.к. вместо одной переменной как в исходнике функция возвращает кортеж из 3 разнотипных

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
            
            if abs(Gradient.F(x, y) > 1e-5):

                # Редактирование БД (фрагмент кода опущен)

                if self.WriteLog:
                    LogFile.writelines(
                        ('------------------------------------------------------\n',
                        'Ошибка: система не имеет решения\n',
                        f'cos(2a)cos(2b) - cos(gamma)sin(2a)sin(2b) = {Gradient.W}\n',
                        f'sin(2a)cos(2b) + cos(gamma)sin(2a)sin(2b) = {Gradient.V}\n',
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
            
            a = cos(-2 * y) + w # откуда w?
            b = sqrt(2) * sin(-2 * y)
            c = w - cos(-2 * y)
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
            
        Hi = Complex.TComplex(sin(Alpha) / cos(Alpha), sin(Beta) / cos(Beta))
        Down = Complex.TComplex(1, -1 * sin(Alpha) * sin(Beta) / cos(Alpha) / cos(Beta))
        Hi / Down # в исходнике Hi.Divide(Down),
                  # при этом результат деления нигде не записывается,
                  # не понял смысла
        
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
                f'Re(Hi) = {Hi.Re}\n',
                f'Im(Hi) = {Hi.Im}\n',
                f'|Hi|   = {Hi.Module()}\n',
                f'/_Hi   = {Hi.Angle()}, рад. = {Hi.Angle()/pi*180} град.\n',
                '------------------------------------------------------\n',
                'Расчет завершен\n',
                '------------------------------------------------------\n')
            )
            LogFile.close()
    
    # Далее в исходнике описано взаимодействие с интерфейсом

if __name__ == '__main__':
    from random import randrange

    SourceData = TSourceData(WriteLog = True, isAnalitic = True) # для проверки всего кода следует тестировать с isAnalitic = True / False
    SourceData.acCaclReflectionExecute()
    SourceData.acCalcRadiationExecute()
    if SourceData.WriteLog:
        os.startfile('LogPart01.txt')
        os.startfile('LogPart03.txt')