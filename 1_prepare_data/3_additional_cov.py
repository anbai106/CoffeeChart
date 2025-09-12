import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/diet_data.csv", sep=',')
df = df[['eid', "average_total_household_income_before_tax_f738_0_0"]]
df['average_total_household_income_before_tax_f738_0_0'] = df['average_total_household_income_before_tax_f738_0_0'].replace([-1, -3], np.nan)
df.rename({'eid': 'participant_id'}, axis=1, inplace=True)
df.to_csv('/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/additional_cov.tsv', index=False, sep='\t')

print("Stop...")
