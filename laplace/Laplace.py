from math import exp, sqrt, pi

def Simpson(a, b, eps):
    n = 1; s = 0; s0 = eps + 1
    while abs(s - s0) > eps:
        n *= 2; h = (b - a) / n; s0 = s
        s = Fun(a) + Fun(b)
        for i in range(1, n):
            s += 2 * (1 + i % 2) * Fun(a + i * h)
        s *= (b - a) / (3 * n);
    return s

def Fun(t):
    return exp(-t * t / 2)

def FLaplace(x):
    return Simpson(0, x, 1E-12) / sqrt(2 * pi)

if __name__ == '__main__':
    for i in range(-5, 5):
        print(f'FLaplace({i}) = {FLaplace(i)}')