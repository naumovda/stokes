import sqlite3
import os

os.chdir(os.path.dirname(__file__))

# tables = ('C1.csv', 'C2.csv', 'C3.csv', 'Calculation.csv', 'CalculationTask3.csv', 'CalculationTask3_1.csv',
#           'Constant.csv', 'Intervals.csv', 'MaterialRefraction.csv')

run = True
while run:
    ErrorFlag = False
    tables = input('Введите имена файлов таблиц базы данных через пробел: ')
    tables = tuple(tables.split())
    for filename in tables:
        if not os.path.isfile(filename):
            print(f'Файл {filename} не существует')
            if not ErrorFlag:
                ErrorFlag = True
    if not ErrorFlag:
        run = False

connection = sqlite3.connect('database.db')
cursor = connection.cursor()

for table_name in tables:
    table = open(table_name)
    table = table.readlines()    
    for row in range(1, len(table)):
        table[row] = tuple(table[row].strip().split(';'))

    try:
        cursor.execute(f"DELETE FROM {table_name.replace('.csv', '')}")
    except sqlite3.OperationalError:
        table[0] = table[0].strip().replace(';', ', ')
        cursor.execute(f"CREATE TABLE {table_name.replace('.csv', '')} ({table[0]})")

    for row in table[1:]:
        cursor.execute(f"INSERT INTO {table_name.replace('.csv', '')} VALUES ({'?, ' * (len(row) - 1) + '?'})", row)

    connection.commit()

cursor.close()
connection.close()