from math import sin, cos, pi, sqrt

GAMMA = pi / 4
W = 0.77
V = - 0.3

def F(x, y):
    return (cos(2 * x) * cos(2 * y) - cos(GAMMA) * sin(2 * x) * sin(2 * y) - W) ** 2 \
    + (sin(2 * x) * cos(2 * y) + cos(GAMMA) * cos(2 * x) * sin(2 * y) - V) ** 2

def dFdx(x, y):
    return 4 * cos(2 * x) * cos(GAMMA) * sin(2 * y) * W + 4 * cos(GAMMA) * sin(2 * x) * sin(2 * y) * V \
    - 4 * cos(2 * x) * cos(2 * y) * V + 4 * cos(2 * y) * sin(2 * x) * W

def dFdy(x, y):
    return - 4 * cos(2 * x) * cos(2 * y) * cos(GAMMA) * V \
    + 4 * cos(2 * y) * cos(GAMMA) * cos(GAMMA) * sin(2 * y) \
    + 4 * cos(2 * y) * cos(GAMMA) * sin(2 * x) * W + 4 * cos(2 * x) * sin(2 * y) * W \
    + 4 * sin(2 * x) * sin(2 * y) * V - 4 * cos(2 * y) * sin(2 * y)

def GradientMethod(x0, y0, eps):
    t = pi / 8
    x = x0; y = y0
    i = 0; n = 1000    

    while True:
        if i > n:
            x = x0
            y = y0
            return x, y, False            
        xt = x - t * dFdx(x, y)
        yt = y - t * dFdy(x, y)
        if abs(sqrt((x - xt) * (x - xt)) + sqrt((y - yt) * (y - yt))) < eps:
            x = xt
            y = yt
            return x, y, True
        Fx = F(x, y)
        Fxt = F(xt, yt)
        if Fx < Fxt:
            t /= 2
        else:
            x = xt
            y = yt
        i += 1


if __name__ == '__main__':
    a = 2; b = 3; e = 4
    print(f'F({a}, {b}) = {F(a, b)}')
    print(f'dFdx({a}, {b}) = {dFdx(2, 3)}')
    print(f'dFdy({a}, {b}) = {dFdy(2, 3)}')
    print(f'GradientMethod({a}, {b}, {e}) = {GradientMethod(2, 3, 4)}')