import pandas as pd
import matplotlib.pyplot as plt
import pickle
from gensim.models.ldamodel import LdaModel

df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/075Data/English_LA.csv")

print(df['top_topic'].value_counts())

plt.hist(df.top_topic)

LdaModel.load(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/075Data/en_lda.model")
