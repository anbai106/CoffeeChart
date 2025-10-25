import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("/Users/hao/cubic-home/Reproducibile_paper/LifestyleChart/data/diet_data.csv", sep=',')
df = df[['eid', "cooked_vegetable_intake_f1289_0_0",
         "salad_raw_vegetable_intake_f1299_0_0", "fresh_fruit_intake_f1309_0_0", "dried_fruit_intake_f1319_0_0",
         "oily_fish_intake_f1329_0_0", "nonoily_fish_intake_f1339_0_0", "processed_meat_intake_f1349_0_0",
         "poultry_intake_f1359_0_0", "beef_intake_f1369_0_0", "lambmutton_intake_f1379_0_0", "pork_intake_f1389_0_0",
         "cheese_intake_f1408_0_0", "bread_intake_f1438_0_0", "cereal_intake_f1458_0_0", "tea_intake_f1488_0_0",
         "coffee_intake_f1498_0_0", "water_intake_f1528_0_0", "average_weekly_red_wine_intake_f1568_0_0",
         "average_weekly_champagne_plus_white_wine_intake_f1578_0_0"]]

### remove -1, -3, -10 values for uncertain values
df['cooked_vegetable_intake_f1289_0_0'] = df['cooked_vegetable_intake_f1289_0_0'].replace([-1, -3, -10], np.nan)
df['cooked_vegetable_intake_f1289_0_0'] = df['salad_raw_vegetable_intake_f1299_0_0'].replace([-1, -3, -10], np.nan)
df['fresh_fruit_intake_f1309_0_0'] = df['fresh_fruit_intake_f1309_0_0'].replace([-1, -3, -10], np.nan)
df['dried_fruit_intake_f1319_0_0'] = df['dried_fruit_intake_f1319_0_0'].replace([-1, -3, -10], np.nan)
df['oily_fish_intake_f1329_0_0'] = df['oily_fish_intake_f1329_0_0'].replace([-1, -3], np.nan)
df['nonoily_fish_intake_f1339_0_0'] = df['nonoily_fish_intake_f1339_0_0'].replace([-1, -3], np.nan)
df['processed_meat_intake_f1349_0_0'] = df['processed_meat_intake_f1349_0_0'].replace([-1, -3], np.nan)
df['poultry_intake_f1359_0_0'] = df['poultry_intake_f1359_0_0'].replace([-1, -3], np.nan)
df['beef_intake_f1369_0_0'] = df['beef_intake_f1369_0_0'].replace([-1, -3], np.nan)
df['lambmutton_intake_f1379_0_0'] = df['lambmutton_intake_f1379_0_0'].replace([-1, -3], np.nan)
df['pork_intake_f1389_0_0'] = df['pork_intake_f1389_0_0'].replace([-1, -3], np.nan)
df['cheese_intake_f1408_0_0'] = df['cheese_intake_f1408_0_0'].replace([-1, -3], np.nan)
df['bread_intake_f1438_0_0'] = df['bread_intake_f1438_0_0'].replace([-1, -3, -10], np.nan)
df['cereal_intake_f1458_0_0'] = df['cereal_intake_f1458_0_0'].replace([-1, -3, -10], np.nan)
df['tea_intake_f1488_0_0'] = df['tea_intake_f1488_0_0'].replace([-1, -3, -10], np.nan)
df['coffee_intake_f1498_0_0'] = df['coffee_intake_f1498_0_0'].replace([-1, -3, -10], np.nan)
df['water_intake_f1528_0_0'] = df['water_intake_f1528_0_0'].replace([-1, -3, -10], np.nan)
df['average_weekly_red_wine_intake_f1568_0_0'] = df['average_weekly_red_wine_intake_f1568_0_0'].replace([-1, -3], np.nan)
df['average_weekly_champagne_plus_white_wine_intake_f1578_0_0'] = df['average_weekly_champagne_plus_white_wine_intake_f1578_0_0'].replace([-1, -3], np.nan)

# Replace values above threshold percential with NaN
diet_cols = [col for col in df.columns if col != 'eid']
for col in diet_cols:
    cutoff = np.nanpercentile(df[col], 98)  # 98th percentile
    df.loc[df[col] > cutoff, col] = np.nan

# histogram for distributions
dietary_traits = [
       "cooked_vegetable_intake_f1289_0_0",
       "salad_raw_vegetable_intake_f1299_0_0",
       "fresh_fruit_intake_f1309_0_0",
       "dried_fruit_intake_f1319_0_0",
       "oily_fish_intake_f1329_0_0",
       "nonoily_fish_intake_f1339_0_0",
       "processed_meat_intake_f1349_0_0",
       "poultry_intake_f1359_0_0",
       "beef_intake_f1369_0_0",
       "lambmutton_intake_f1379_0_0",
       "pork_intake_f1389_0_0",
       "cheese_intake_f1408_0_0",
       "bread_intake_f1438_0_0",
       "cereal_intake_f1458_0_0",
       "tea_intake_f1488_0_0",
       "coffee_intake_f1498_0_0",
       "water_intake_f1528_0_0",
       "average_weekly_red_wine_intake_f1568_0_0",
       "average_weekly_champagne_plus_white_wine_intake_f1578_0_0"
]
# Optional: create more readable titles
titles = [
       "Cooked Vegetables", "Salad/Raw Vegetables", "Fresh Fruit", "Dried Fruit",
       "Oily Fish", "Non-Oily Fish", "Processed Meat", "Poultry",
       "Beef", "Lamb/Mutton", "Pork", "Cheese",
       "Bread", "Cereal", "Tea", "Coffee", "Water",
       "Red Wine", "Champagne/White Wine"
]
for col, title in zip(dietary_traits, titles):
       counts = df[col].value_counts().sort_index()

       plt.figure(figsize=(12, 6))
       sns.barplot(x=counts.index, y=counts.values, color="steelblue")
       plt.xticks(rotation=45)
       plt.xlabel(f"{title} Intake")
       plt.ylabel("Number of participants")
       plt.title(f"Distribution of {title} Intake")
       plt.tight_layout()
       plt.show()

print(df.count())

df.rename({'eid': 'participant_id'}, axis=1, inplace=True)
df.to_csv('/Users/hao/cubic-home/Reproducibile_paper/LifestyleChart/data/dietary_data_encoded.tsv', index=False, sep='\t')

print("Stop...")
