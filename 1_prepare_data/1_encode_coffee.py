import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/coffee_data.csv", sep=',')
df = df[['eid', 'tea_intake_f1488_0_0',
       'coffee_intake_f1498_0_0']]

### remove -1 represents "Do not know"
### -3 represents "Prefer not to answer"
df = df[~df['tea_intake_f1488_0_0'].isin([-1, -3, -10])]
df = df[~df['coffee_intake_f1498_0_0'].isin([-1, -3, -10])]

### Let's remove the outliers
df.loc[df["coffee_intake_f1498_0_0"] > 15, "coffee_intake_f1498_0_0"] = np.nan
df.loc[df["tea_intake_f1488_0_0"] > 25, "tea_intake_f1488_0_0"] = np.nan

### Coffee
counts = df['coffee_intake_f1498_0_0'].value_counts().sort_index()
plt.figure(figsize=(12,6))
sns.barplot(x=counts.index, y=counts.values, color="steelblue")
plt.xticks(rotation=45)
plt.xlabel("Cups of coffee per day")
plt.ylabel("Number of participants")
plt.title("Distribution of Daily Coffee Intake")
plt.tight_layout()
plt.show()

### Tea
counts = df['tea_intake_f1488_0_0'].value_counts().sort_index()
plt.figure(figsize=(12,6))
sns.barplot(x=counts.index, y=counts.values, color="steelblue")
plt.xticks(rotation=45)
plt.xlabel("Cups of tea per day")
plt.ylabel("Number of participants")
plt.title("Distribution of Daily Coffee Intake")
plt.tight_layout()
plt.show()

print(df.count())

df.rename({'eid': 'participant_id'}, axis=1, inplace=True)
df.to_csv('/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/coffee_data_encoded.tsv', index=False, sep='\t')

print("Stop...")
