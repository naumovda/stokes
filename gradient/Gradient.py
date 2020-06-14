from math import sin, cos, pi, sqrt

class Gradient:
    def __init__(self, GAMMA=Pi/4, W=0.77, V=-0.3):
        self.GAMMA = GAMMA
        self.W = W
        self.V = V

    def Fxy(self, x, y):
        return (cos(2 * x) * cos(2 * y) - cos(self.GAMMA) * sin(2 * x) * sin(2 * y) - self.W) ** 2 \
        + (sin(2 * x) * cos(2 * y) + cos(self.GAMMA) * cos(2 * x) * sin(2 * y) - self.V) ** 2

    def dFdx(self, x, y):
        return 4 * cos(2 * x) * cos(self.GAMMA) * sin(2 * y) * W + 4 * cos(self.GAMMA) \
            * sin(2 * x) * sin(2 * y) * self.V \
        - 4 * cos(2 * x) * cos(2 * y) * self.V + 4 * cos(2 * y) * sin(2 * x) * self.W

    def dFdy(self, x, y):
        return - 4 * cos(2 * x) * cos(2 * y) * cos(self.GAMMA) * self.V \
        + 4 * cos(2 * y) * cos(self.GAMMA) * cos(self.GAMMA) * sin(2 * y) \
        + 4 * cos(2 * y) * cos(self.GAMMA) * sin(2 * x) * self.W 
        + 4 * cos(2 * x) * sin(2 * y) * self.W \
        + 4 * sin(2 * x) * sin(2 * y) * self.V - 4 * cos(2 * y) * sin(2 * y)

    def GradientMethod(self, x0, y0, eps):
        t = pi / 8
        x = x0; y = y0
        i = 0; n = 1000    

        while True:
            if i > n:
                x = x0
                y = y0
                return (x, y, False)
            xt = x - t * self.dFdx(x, y)
            yt = y - t * self.dFdy(x, y)
            if abs(sqrt((x - xt) * (x - xt)) + sqrt((y - yt) * (y - yt))) < eps:
                x = xt
                y = yt
                return (x, y, True)
            Fx = self.Fxy(x, y)
            Fxt = self.Fxy(xt, yt)
            if Fx < Fxt:
                t /= 2
            else:
                x = xt
                y = yt
            i += 1

if __name__ == '__main__':
    g = Gradient()
    a = 2; b = 3; e = 4
    print(f'F({a}, {b}) = {g.F(a, b)}')
    print(f'dFdx({a}, {b}) = {g.dFdx(2, 3)}')
    print(f'dFdy({a}, {b}) = {g.dFdy(2, 3)}')
    print(f'GradientMethod({a}, {b}, {e}) = {g.GradientMethod(2, 3, 4)}')