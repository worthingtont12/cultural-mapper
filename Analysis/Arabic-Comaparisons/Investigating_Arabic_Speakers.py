"""Analyizing Arabic Speakers Twitter Activity Across Regions"""
import pandas as pd
import pandas.io.sql as psql
import psycopg2

# database keys
from login_info import user, host, password

# sql command
from Arabic_SQL_Commands import Chicago_Sql, LA_Sql, Istanbul_Sql
#######Importing and Cleaning######
# connect to database
conn_chi = psycopg2.connect(
    "dbname='culturalmapper_Chicago' user=%s host=%s password=%s" % (user, host, password))

conn_la = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))

conn_ist = psycopg2.connect(
    "dbname='culturalmapper_Istanbul' user=%s host=%s password=%s" % (user, host, password))

la = psql.read_sql(LA_Sql, conn_la)
chi = psql.read_sql(Chicago_Sql, conn_chi)
ist = psql.read_sql(Istanbul_Sql, conn_ist)

la['count'] = 1
chi['count'] = 1
ist['count'] = 1

# LA
communitysize = la.groupby('user_lang').user_id.nunique()
community_size = dict(zip(communitysize.index, communitysize.values))
la["normalized_count"] = (1 / la["user_lang"].map(community_size))

# Chicago
communitysize = chi.groupby('user_lang').user_id.nunique()
community_size = dict(zip(communitysize.index, communitysize.values))
chi["normalized_count"] = (1 / chi["user_lang"].map(community_size))

# Istanbul
communitysize = ist.groupby('user_lang').user_id.nunique()
community_size = dict(zip(communitysize.index, communitysize.values))
ist["normalized_count"] = (1 / ist["user_lang"].map(community_size))


def formatingdata(fulldf):
    # creating date variable
    fulldf['Date'] = fulldf['tzone'].apply(lambda row: str(row).split()[0])
    fulldf['Time'] = fulldf['tzone'].apply(lambda row: str(row).split()[1])

    # Sorting
    fulldf['Date1'] = pd.to_datetime(fulldf.Date)
    fulldf = fulldf.sort_values(by='Date1')


formatingdata(la)
formatingdata(chi)
formatingdata(ist)

la_series = la.groupby(['Date1'])[
    'normalized_count'].aggregate(sum)
chi_series = chi.groupby(['Date1'])[
    'normalized_count'].aggregate(sum)
ist_series = ist.groupby(['Date1'])[
    'normalized_count'].aggregate(sum)

fig = plt.figure(figsize=(20, 10))
ts = fig.add_subplot(1, 1, 1)
plt.xlabel('Date')
la_series.plot(label='LA')
chi_series.plot(label='Chicago')
ist_series.plot(label='Istanbul')
fig = ts.legend(loc='best')
plt.savefig("Arabic_Comparisons")
