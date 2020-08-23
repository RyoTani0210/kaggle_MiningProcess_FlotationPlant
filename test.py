import pandas as pd
import os
import math
os.getcwd()

data = pd.read_csv("Data/data_fixTimestamp.csv")
del data["Unnamed: 0"]
data["date"] = pd.to_datetime(data["date"])

import batch_graph

df_dropdate = data.drop("date", axis=1)
batch_graph.writeValueHists(df_dropdate)

