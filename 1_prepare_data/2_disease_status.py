import pandas as pd
import numpy as np

### ICD10 disease for Brain, Heart, and Eye disease categories
icd10_csv = '/Users/hao/cubic-home/Reproducibile_paper/BrainEye/data/UKBB_fullsample_ICD10.csv'
df_icd = pd.read_csv(icd10_csv, sep=",")
df_icd.rename({'eid': 'participant_id'}, axis=1, inplace=True)

### merge with the brain-eye-heart population
df_icd_data = df_icd.iloc[:, 1:]
cn_boolean = df_icd_data.isnull().all(1)
df_icd_cn = df_icd[cn_boolean.values]
df_icd_pt = df_icd[~cn_boolean.values][['participant_id']]
df_icd_pt['diagnosis'] = 1
df_icd_cn.replace(np.nan, 1, inplace=True)
df_icd_cn = df_icd_cn[['participant_id', 'diagnoses_icd10_f41270_0_0']]
df_icd_cn.rename({'diagnoses_icd10_f41270_0_0': 'diagnosis'}, axis=1, inplace=True)
df_icd_cn['diagnosis'] = 0

df = pd.concat([df_icd_cn, df_icd_pt], ignore_index=True)

df.to_csv('/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/icd_disease_diagnosis.tsv', index=False, sep='\t')
