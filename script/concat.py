import pandas as pd
import glob


my_list = []

for i in glob.glob('/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/*.csv'):
    #print(i)
    #print(type(i))
    data = pd.read_csv(i)
    #print(data)
    my_list.append(data)

data= pd.concat(my_list)

data.to_csv('/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/docs/three_years.csv')

#print("world")
