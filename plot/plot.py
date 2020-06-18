from mpl_toolkits import mplot3d
from matplotlib import cm
import matplotlib.pyplot as plt
import pandas as pd


def plot_3d(data, x, y, z):
    ax = plt.axes(projection="3d")

    ax.plot_trisurf(df[x], df[y], df[z], cmap=cm.Blues)
    ax.set_xticks(df[x].values)
    ax.set_yticks(df[y].values)
    ax.set_xlabel(x)
    ax.set_ylabel(y)

    return ax


if __name__ == "__main__":
    df = pd.read_csv("Calculation.csv", sep=";")
    fig = plt.figure(figsize=(14, 8))
    ax = plot_3d(df, x="Beta", y="Alfa", z="J")
    plt.show()
