# Implementing Louvain Clustering

An Optimal Louvain Network will return a partition of the network that maximizes the modularity of the network caracterized
by dense connections within communities and sparse connections between communities. The objective of applying 
the Louvain algorithm to a cluster of tweets is to identify communities in large networks.  

## Algorithm

In order to identify communities within groups of tweets, we have implemented the Louvain Algorithm.
Communities are groups of nodes in a network or graph that are more connected to one another than to any other node in the network, and modularity is a metric between 0 and 1 that quantifies the density of links or edges inside communities as compared to links between communities.  Networks with high modularity have dense connections between nodes that belong to the same communities but sparse connections between nodes in different communities. The Louvain algorithm returns a partition of the network,the number of communities, that maximizes the modularity of the network.

### Prerequisites

Courpus of tweets (.mm file) and TF_IDF matrix for each city 


### Order

1. Louvain.R
2. Top_Words_in_Community.py

### Description 

Louvain.R will create a graph where nodes are individual twitter users connected by weighted cosine similarities of TF_IDF matrix. After running Louvain algorithm on the graph, we are going to end up 
with an optimal partition of twitter users into different communities. Louvain.R will create a nodes file and an edges file to visualize communities using Gephi as well as a file containing the community id for each twitter user (merged.csv). Top_Words_in_Communities.py will use this file to find the top 15 words in these communities. 

Louvain output
```
nodes.csv
edges.csv
communities.csv
```

How to run Top_Words_in_Community.py

```
1) Membership column name in communities.csv might change, so make sure membership_(city) in Top_Words_in_Community.py refers to the right column name
2) In Joining.py, set dbname to the right city database as well as variables primary, quotes, and user_desc 
3) python Top_Words_in_Community.py

```
Top_Words_in_Community output
```
Top_15_words.csv
```


#### Visualizing communities with Gephi

Use the nodes and edges files produced by Louvain.R to visualize communities in Gephi. Use the modularity feature found in Gephi to map this communities. This is the metric that the Louvain algorithm optimizes to identify communities. 

For more information on how to use Gephi go to [Tutorial](https://gephi.org/users/)


