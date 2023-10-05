#!/usr/bin/env python
# coding: utf-8

# In[10]:


# Import Libraries 

import pandas as pd
import seaborn as sns
import numpy as np


import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) #Adjusts the configuration of the plots we will create

# Read in the Data
df = pd.read_csv('movies.csv') #Need to put full path so instead I uploaded the csv to jupyter directory


# In[11]:


# Let's Look at Data

df.head()


# In[8]:


# Let's see if there is any missing data

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col,pct_missing))


# In[9]:


# Data types for our columns
df.dtypes


# In[12]:


# Get rid of the decimals in budget, gross income, votes (ex:927000 vs 927000.0)
df['budget'] = df['budget'].fillna(0).astype('int64')

df['gross'] = df['gross'].fillna(0).astype('int64')

df['votes'] = df['votes'].fillna(0).astype('int64')
# Have to inlcude .fillna(0) to handle NaN (Not-A-Number) values, otherwise error


# In[17]:


df


# In[13]:


# Creating a new column for Release Year (so it matches release date)

df['yearcorrect'] = df['released'].astype(str).str[:4] #this is first 4, [4:] is last 4
df


# In[14]:


# Ordering data by gross revenue descending

df = df.sort_values(by=['gross'], inplace=False, ascending=False)


# In[21]:


# Look at all the data in the dataframe

pd.set_option('display.max_rows', None)


# In[3]:


# Drop any duplicates

df['company'].drop_duplicates().sort_values(ascending=False)
# This give the distinct values in company column
#If I removed .drop_duplicates(), it would give me all values in company column


# df.drop_duplicates()
# This would drop duplicates across the whole dataframe


# In[ ]:


# Highy correlation predictions to gross income
# Budget is highly correlated
# Company is highly correlated


# In[7]:


# Scatterplot with budget vs gross


plt.scatter(x=df['budget'], y=df['gross'])

# Add Title and axis labels
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget for Film')

plt.show()


# In[6]:


df.head()


# In[19]:


# Seaborn Regression Plot: Budget vs Gross 

sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "green"}, line_kws={"color":"darkblue"})


# In[ ]:


# Let's start looking at correlation


# In[25]:


df.corr(method='pearson') #different types of methods, pearson by default, kendall, spearman

# This is giving an error- ValueError: could not convert string to float: 'Avatar'


# In[41]:


# This give the column names and datatypes
column_data_types = df.dtypes
print(column_data_types)


# In[4]:


# This fixes the above error
# Includes all numeric values as listed above 
numerical_df = df.select_dtypes(include=['float','int'])
correlation_matrix = numerical_df.corr('pearson')


# In[52]:


correlation_matrix


# In[22]:


# High correlation between budget and gross, I was right!


# In[5]:


# Visualization with HeatMap - titles and labels

correlation_matrix 

sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matrix for Numeric features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')


plt.show()


# In[6]:


# Look at Company - doesnt have numeric value but can make string into numeric value

df.head()


# In[7]:


# Numerize the string columns (company, genre, country etc)

df_numerized = df

for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'): #if object, then category statement
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

df_numerized
        


# In[15]:


df


# In[18]:


correlation_matrix = df_numerized.corr(method='pearson') 

sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matrix for All Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')


plt.show()


# In[19]:


# Correlation of all fields after converting all fields to numeric values
df_numerized.corr()


# In[21]:


# To see which have highest correlation, quickly!
# This code below shows the matrix unstacked and in a list

correlation_mat = df_numerized.corr()

corr_pairs = correlation_mat.unstack()

corr_pairs


# In[22]:


sorted_pairs = corr_pairs.sort_values()

sorted_pairs


# In[23]:


# Just view the higher correlated pairs

high_corr = sorted_pairs[(sorted_pairs) > 0.5]

high_corr

# Votes and Budget have highest correlation to Gross Earnings
# Company has low correlation


# In[24]:


# Just view lowest correlated pairs

low_corr = sorted_pairs[(sorted_pairs) < 0.3]

low_corr

# Some paired are negatively correlated!


# In[ ]:




