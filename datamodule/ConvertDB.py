import sqlite3
import os

os.chdir(os.path.dirname(__file__))

tables = ('C1.csv', 'C2.csv', 'C3.csv', 'Calculation.csv', 'CalculationTask3.csv', 'CalculationTask3_1.csv',
          'Constant.csv', 'Intervals.csv', 'MaterialRefraction.csv')

connection = sqlite3.connect('database.db')
cursor = connection.cursor()

for table_name in tables:
    table = open(table_name)
    table = table.readlines()
    table[0] = table[0].strip().replace(';', ', ')
    for row in range(1, len(table)):
        table[row] = tuple(table[row].strip().split(';'))

    cursor.execute(f"CREATE TABLE {table_name.replace('.csv', '')} ({table[0]})")

    for row in table[1:]:
        cursor.execute(f"INSERT INTO {table_name.replace('.csv', '')} VALUES ({'?, ' * (len(row) - 1) + '?'})", row)

    connection.commit()

cursor.close()
connection.close()