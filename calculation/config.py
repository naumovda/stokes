import configparser
import argparse
import textwrap

class Config:
    def __init__(self):
        parser = argparse.ArgumentParser(description='Stokes parameters calculation',
                                         formatter_class=argparse.RawDescriptionHelpFormatter,
                                         epilog=textwrap.dedent('''\
                Keys used:
                    q or ESC     = Exit
            '''))

        parser.add_argument('-f', '--file',
                            dest='file',
                            default='config/basic.ini',
                            help='configuration file')

        args = parser.parse_args()

        self.config = configparser.ConfigParser()
        self.config.read(args.file)

        sys = self.config['Common']      
        self.fi = float(sys.get("Fi", 52)) # Угол падения, град
        re = float(sys.get("Nju_Re", 1.4)) # Действительная часть показателя преломления
        im = float(sys.get("Nju_Im", -4.53))  #Мнимая часть показателя преломления
        self.nju = complex(re, im) #показатель преломления
        self.gamma = float(sys.get("Gamma", 45)) # Угол, град

        ivl = self.config['Intervals']
        # Интервалы для контроля параметров
        self.intervals = {}
        self.intervals["U"] = self.parse_interval(ivl.get("U"))
        self.intervals["V"] = self.parse_interval(ivl.get("V"))
        self.intervals["U0"] = self.parse_interval(ivl.get("U0"))
        self.intervals["V0"] = self.parse_interval(ivl.get("V0"))
        self.intervals["J"] = self.parse_interval(ivl.get("J"))
        self.intervals["P"] = self.parse_interval(ivl.get("P"))
        self.intervals["Q"] = self.parse_interval(ivl.get("Q"))
        self.intervals["J0"] = self.parse_interval(ivl.get("J0"))
        self.intervals["P0"] = self.parse_interval(ivl.get("P0"))
        self.intervals["Q0"] = self.parse_interval(ivl.get("Q0"))

    def parse_interval(self, str_value):
        values = str_value.split(',')
        return {"min":values[0], "max":values[1]}

    def print(self):
        print("Fi = ", self.fi)
        print("Gamma = ", self.gamma)
        print("Nju = ", self.nju)
        print("Intervals: ", self.intervals)
