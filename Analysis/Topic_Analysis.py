"""Analyzing Topic Activity Through Time."""
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from datetime import datetime, date
import numpy as np
import seaborn as sns
from Cleaning import fulldf

#################### Daily plots ######################
"""
Plot Distribution of Activity Throughout Entire Series.
"""
dailyplot = sns.factorplot(x="Date", y="count", hue="top_topic",
                           estimator=np.sum, data=fulldf, size=15, aspect=10)
dailyplot.set_xticklabels(rotation=90)
dailyplot.savefig("Graphs/Istanbul/Turkish_Daily_Plot.png")
# Daily Plot as Percentage
dailyplot_percentage = sns.factorplot(x="Date", y="topic_percentage", hue="top_topic",
                                      estimator=np.sum, data=fulldf, size=10, aspect=6)
dailyplot_percentage.set_xticklabels(rotation=90)
dailyplot_percentage.savefig("Graphs/Istanbul/Turkish_Daily_Plot_Percentage.png")

# removing Election aftermath
fulldf_without_election = fulldf[fulldf.Date != '2016-11-09']

dailyplot_wo_election = sns.factorplot(x="Date", y="count", hue="top_topic",
                                       estimator=np.sum, data=fulldf_without_election, size=6, aspect=4)

dailyplot_wo_election.set_xticklabels(rotation=90)

dailyplot_wo_election.savefig("Graphs/Istanbul/Turkish_Daily_WO_Election")

# Daily Plot as Percentage Without Election
dailyplot_woelection_percentage = sns.factorplot(x="Date", y="topic_percentage", hue="top_topic",
                                                 estimator=np.sum, data=fulldf_without_election, size=10, aspect=6)

dailyplot_woelection_percentage.set_xticklabels(rotation=90)

dailyplot_woelection_percentage.savefig(
    "Graphs/Istanbul/Turkish_Daily_Plot_WOELECTION_Percentage.png")

################### Day of The Week Plots#####################
"""
Plot Activity Throughout Days of the Week
"""
# Creating new variable for day of the week
fulldf['Day of Week'] = fulldf['Date1'].apply(lambda row: row.weekday())

# Mapping integer to name of day
map_days = {0: "Monday", 1: "Tuesday", 2: "Wednesday",
            3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"}

fulldf['Day of Week'] = fulldf['Day of Week'].map(map_days)

# Day of Week Plot
dayoftheweek = sns.factorplot(x="Day of Week", y="count",
                              hue="top_topic", estimator=np.sum, data=fulldf)
dayoftheweek.set_xticklabels(rotation=90)
dayoftheweek.savefig("Graphs/Chicago/Day_of_The_Week.png")

# Day of the Week As Percentage of Topic
dayoftheweek_percentage = sns.factorplot(x="Day of Week", y="topic_percentage", hue="top_topic",
                                         estimator=np.sum, data=fulldf, size=10, aspect=6)

dayoftheweek_percentage.set_xticklabels(rotation=90)

dayoftheweek_percentage.savefig("Graphs/Chicago/Day_of_The_Week_Percentage.png")

# Day of the Week without Election aftermath
dayoftheweek_without_election = fulldf[fulldf.Date != '2016-11-09']
dayoftheweek_woaftermath = sns.factorplot(x="Day of Week", y="count", hue="top_topic",
                                          estimator=np.sum, data=dayoftheweek_without_election)
dayoftheweek_woaftermath.set_xticklabels(rotation=90)
dayoftheweek_woaftermath.savefig("Graphs/Chicago/Day_of_The_Week_WO_Election.png")

# Day of the Week without Election aftermath as percentage
dayoftheweek_woaftermath_percentage = sns.factorplot(x="Day of Week", y="topic_percentage", hue="top_topic",
                                                     estimator=np.sum, data=dayoftheweek_without_election, size=10, aspect=6)
dayoftheweek_woaftermath_percentage.set_xticklabels(rotation=90)
dayoftheweek_woaftermath_percentage.savefig("Graphs/Chicago/Day_of_The_Week__WO_Percentage.png")
