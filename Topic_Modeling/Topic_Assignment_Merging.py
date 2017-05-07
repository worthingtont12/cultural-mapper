"""Merging Different Language Topic Assignments"""
import pandas as pd
import matplotlib.pyplot as plt

english = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Istanbul/English/035Data/English_Istanbul.csv")
turkish = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Istanbul/Turkish/035Data/Turkish_Istanbul.csv")

# formatting turkish
turkish.top_topic = turkish.top_topic.apply(str)
turkish.top_topic = turkish.top_topic.apply(lambda row: "Turkish_" + row)

# formatting english
english.top_topic = english.top_topic.apply(str)
english.top_topic = english.top_topic.apply(lambda row: "English_" + row)

# concatenate the two dfs
Istanbul = pd.concat([english, turkish])
Istanbul.tail()

Istanbul.to_csv(
    '/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Istanbul/Combined_Istanbul_035.csv')
