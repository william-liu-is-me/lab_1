import pandas as pd
import glob

my_list = []

for i in glob.glob('*.csv'):
    data = pd.read_csv(i)
    my_list.append(data)

final = pd.concat(my_list)

final.to_csv('docs/all_years.csv')
