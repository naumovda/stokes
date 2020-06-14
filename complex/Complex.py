import math

class TComplex:
    def __init__(self, aRe, aIm):
        self.Re = aRe
        self.Im = aIm

    def Real(self):
        return self.Re

    def Image(self):
        return self.Im
        
    def __add__(self, A):
        return TComplex(self.Re + A.Real(), self.Im + A.Image())

    def __sub__(self, A):
        return TComplex(self.Re - A.Real(), self.Im - A.Image())

    def __mul__(self, A):
        return TComplex(self.Re * A.Real() - self.Im * A.Image(), self.Im * A.Real() + self.Re * A.Image())

    def __truediv__(self, A):
        z = A.Real() ** 2 + A.Image() ** 2
        return TComplex((self.Re * A.Real() + self.Im * A.Image()) / z, (self.Im * A.Real() - self.Re * A.Image()) / z)

    def Covariant(self):
        return TComplex(self.Re, -self.Im)

    def Module(self):
        return math.sqrt(self.Re ** 2 + self.Im ** 2)

    def Angle(self):
        if self.Re < 1e-10:
            if self.Im > 0:
                return math.pi / 2
            else:
                return - math.pi / 2
        else: # ?????
            if self.Re > 0:
                return math.atan(self.Im / self.Re)
            else:
                return math.pi + atan(self.Im / self.Re)

    def SquareRoot(self, Index):
        a = math.sqrt(math.sqrt(self.Re ** 2 + self.Im ** 2))
        phi = math.atan(self.Im / self.Re)
        if self.Re < 0:
            phi += math.pi
        if (Index < 0) or (Index > 1):
            Index = 0
        if Index == 1:
            phi += math.pi
        return TComplex(a * math.cos(phi), a * math.sin(phi))

    def LengthToRectangle(self, ReMin, ReMax, ImMin, ImMax):
        x1 = min(ReMin, ReMax)
        x2 = max(ReMin, ReMax)
        y1 = min(ImMin, ImMax)
        y2 = max(ImMin, ImMax)

        """
        1 | 2 | 3
        4 | - | 5
        6 | 7 | 8
        """

        if (self.Re >= x1) and (self.Re <= x2) and (self.Im >= y1) and (self.Im <= y2):
            return 0
        elif self.Re < x1:
            if self.Im > y2:
                return math.sqrt((self.Re - x1) ** 2 + (self.Im - y2) ** 2)
            elif self.Im < y1:
                return math.sqrt((self.Re - x1) ** 2 + (self.Im - y1) ** 2)
            else:
                return abs(self.Re - x1)
        elif self.Re > x2:
            if self.Im > y2:
                return math.sqrt((self.Re - x2) ** 2 + (self.Im - y2) ** 2)
            elif self.Im < y1:
                return math.sqrt((self.Re - x2) ** 2 + (self.Im - y1) ** 2)
            else:
                return abs(self.Re - x2)
        else:
            return min(abs(self.Im - y1), abs(self.Im - y2))

def Equal(A, B, Eps):
    if abs(A - B) < abs(Eps):
        return True
    else:
        return False

# Test

if __name__ == '__main__':
    complex_num_1 = TComplex(0.1, 0.8)
    complex_num_2 = TComplex(3, -0.4)    
    print(f"Метод Real: {complex_num_1.Real()}, метод Image: {complex_num_1.Image()}")

    complex_num_1 += complex_num_2
    print(f"Атрибуты Re и Im после сложения: {complex_num_1.Real()}, {complex_num_1.Image()}")

    complex_num_1 -= complex_num_2
    complex_num_1.Re = round(complex_num_1.Re, 5)
    # Без округления атрибут приобретает значение вида 0.10000000000000009, почему – не знаю
    print(f"Атрибуты Re и Im после вычитания: {complex_num_1.Real()}, {complex_num_1.Image()}")

    complex_num_1 *= complex_num_2
    complex_num_1.Re = round(complex_num_1.Re, 5)
    complex_num_1.Im = round(complex_num_1.Im, 5)
    print(f"Атрибуты Re и Im после умножения: {complex_num_1.Real()}, {complex_num_1.Image()}")

    complex_num_1 /= complex_num_2
    complex_num_1.Re = round(complex_num_1.Re, 5)
    complex_num_1.Im = round(complex_num_1.Im, 5)
    print(f"Атрибуты Re и Im после деления: {complex_num_1.Real()}, {complex_num_1.Image()}")

    complex_num_1 = complex_num_1.Covariant()
    print(f"Атрибуты Re и Im после вызова метода Ковариант: {complex_num_1.Real()}, {complex_num_1.Image()}")

    module = complex_num_1.Module()
    print("Комплексный модуль: ", module)

    angle = complex_num_1.Angle()
    print("Угол: ", angle)

    complex_root = complex_num_1.SquareRoot(Index = 0)
    print(f"Атрибуты Re и Im после вычисления корня: {complex_root.Real()}, {complex_root.Image()}")

    LtR = complex_num_1.LengthToRectangle(-1, 5, 0.3, 1)
    print("Результат вызова метода LengthToRectangle: ", LtR)