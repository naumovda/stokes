# Загрузка базы данных в структуру формата
# {Имя_таблицы: {Имя_поля: [Значения], Имя_поля: [Значения], ...}, Имя_таблицы: {...}, ...}
# имена таблиц передаются в виде кортежа
#
# Обновление базы данных, если она предварительно загружалась,
# поскольку иначе массив может быть неполным, и данные обновлятся некорректно (если обновлятся)

import sqlite3
import os

PATH = 'database.db'

class dmPublic:
    def loadData(self, names):
        self.loaded = True

        connection = sqlite3.connect(PATH)
        cursor = connection.cursor()

        self.tables = {}

        for name in names:            
            cursor.execute(f"SELECT name FROM PRAGMA_TABLE_INFO('{name}')")
            self.tables[name] = {column[0]: [] for column in cursor.fetchall()}
            
            cursor.execute(f"SELECT * FROM {name}")
            
            for row in cursor.fetchall():                
                for column in range(len(row)):
                    self.tables[name][tuple(self.tables[name].keys())[column]].append(row[column])
        
        cursor.close()
        connection.close()
    
    def update(self, names):
        if self.loaded:
            connection = sqlite3.connect(PATH)
            cursor = connection.cursor()

            for name in names:
                cursor.execute(f"DELETE FROM {name}")            
                row = []            
                for row_id in range(len(self.tables[name][tuple(self.tables[name].keys())[0]])):
                    for column in self.tables[name]:
                        row.append(self.tables[name][column][row_id])
                    cursor.execute(f"INSERT INTO {name} VALUES ({'?, ' * (len(row) - 1) + '?'})", tuple(row))
                    row.clear()
            
            connection.commit()
            cursor.close()
            connection.close()


if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))
    data = dmPublic()
    data.loadData(('Constant', 'Intervals'))
    data.update(('Constant', 'Intervals'))
    data.loadData(('Constant', 'Intervals'))
    print(data.tables)