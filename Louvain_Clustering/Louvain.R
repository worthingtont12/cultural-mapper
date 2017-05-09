#############################################################################
#                                                                           #
#                     Capstone - Cultural Mapper                            #
#                 Louvain Clustering Implementation                         #
#                                                                           #
#############################################################################

#setwd("~/Desktop/")

#############################################################################
install.packages("spam")
install.packages("igraph")
install.packages("qlcMatrix")
install.packages("networkD3")
library(spam)
library(igraph)
library(Matrix)
library(slam)
library(qlcMatrix)
library(networkD3)
############################################################################
#the following function will accept the compus of tweets and the number of users in a cit, 
#and it will return the adjacency graph for the cluster of tweets. 

# parameter-data is the data from the .mm corpus file of tweets already read 

twitter_graph <- function(data, number_of_users){
  # Transpose the matrix 
  data <- t(data)
  # convert tdm_la into a square matrix
  data <- as.matrix(data)
  # find the cosine similarity of tdm_la
  data <- cosSparse(data, norm = norm2)
  # convert tdm_la into a matrix
  data <- as.matrix(data)
  # set diagonal extrie of the matrix to 0
  diag(data) <- 0
  # set the row and column names to integers from 1 to 354013
  rownames(data) <- c(1:number_of_users)
  colnames(data) <- c(1:number_of_users)
  ###### Building graph for Los Angeles
  ig <- graph.adjacency(data, mode="undirected", weighted=TRUE)
  
  return(ig)
}
##############################################################################
############################      Los Angeles     ############################
##############################################################################

# Read in Los Angeles corpus of tweets - (.mm file)
tdm_la <- read.MM('en_corpus_la.mm')

######
# Here you can call function twitter_graph(tmd_la,length(tdm_la)) to get the graph
# and go to line 97
# Example: ig <- twitter_graph(tmd_la,length(tdm_la))

# Transpose the matrix 
tdm_la <- t(tdm_la)
# Check the number of columns 
ncol(tdm_la)

## In case you want to work first with a small sample size first, let say (45000)
## col_sample <- sample(ncol(tdm_la), 45000)

## Extract the sample size from the the corpus of tweets 
## tdm_la <- tdm_la[, col_sample]

## check the number of columns it should be 45000
##ncol(tdm_la)

# convert tdm_la into a square matrix
tdm_la <- as.matrix(tdm_la)
# find the cosine similarity of tdm_la
tdm_la <- cosSparse(tdm_la, norm = norm2)
# convert tdm_la into a matrix
tdm_la <- as.matrix(tdm_la)
# set diagonal extrie of the matrix to 0
diag(tdm_la) <- 0

## if working with 45000 sample size
## rownames(tdm_la) <- c(1:45000)
## colnames(tdm_la) <- c(1:45000)

# set the row and column names to integers from 1 to 354013
rownames(tdm_la) <- c(1:354013)
colnames(tdm_la) <- c(1:354013)


###### Building graph for Los Angeles
# create an adjacency matrix of twitter users 
ig <- graph.adjacency(tdm_la, mode="undirected", weighted=TRUE)

## if working with sample size
## nodes <- cbind(as.character(c(1:45000)))

# create a column with node names 
nodes <- cbind(as.character(c(1:354013)))
# set the name of this column to "ID"
colnames(nodes) <- c("ID")

#### Louvain Algorithm  

# run Louvain on graph ig
louvain <- cluster_louvain(graph = ig)

#get the number of communities
louvain_sizesComm <- sizes(louvain)
#get how many members are in each community
louvain_numComm <- length(louvain_sizesComm)
# get the modularity of the graph
louvain_modularity <- modularity(louvain)

# print louvain results
print(louvain_numComm)
# filter our communities of size 1
louvain_sizesComm <- subset(louvain_sizesComm, louvain_sizesComm > 1)
print(louvain_sizesComm)


print(louvain_modularity)
# store membership of each node in membership_la
membership_la <- louvain$membership

## in case of working with sample size
#memb_type_la <- cbind(as.character(c(1:45000)), membership_la)

# combine nodes id with their membership
memb_type_la <- cbind(as.character(c(1:4354013)), membership_la)
#name columns
colnames(memb_type_la) <- c("Source", "Modularity Class")

# filter out communities of size 1
com_topic_la <- cbind(nodes, membership_la)
com_topic_la <- as.data.frame(com_topic_la)
com_topic_la <- com_topic_la[com_topic_la$membership_la == 18 | com_topic_la$membership_la == 286 |com_topic_la$membership_la == 324 | 
                               com_topic_la$membership_la == 658 |com_topic_la$membership_la == 892 |com_topic_la$membership_la == 1037 |
                               com_topic_la$membership_la == 1110 |com_topic_la$membership_la == 1131 |com_topic_la$membership_la == 1241 |
                               com_topic_la$membership_la == 1467 |com_topic_la$membership_la == 1706,]


write.csv(com_topic_la, file = "communities_la.csv")
colnames(memb_type_la) <- c("Source", "Modularity Class")

#### creating graph files

# combine edge list with their weights
graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
# weights are very small, we are going to multiply them by 1000
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_la, by = "Source")

# nodes and edges files for Los Angeles to be used with Gephie to create the graphs
write.csv(nodes, file = "nodes_la.csv")
write.csv(graph, file = "edges_la.csv")


##############################################################################
############################      Chicago         ############################
##############################################################################

tdm_ch <- read.MM('Louvain_Clustering/en_corpus_chicago.mm')

######
# Here you can call function twitter_graph(tmd_ch,length(tdm_ch)) to get the graph
# and go to line 199
# Example: ig <- twitter_graph(tmd_ch,length(tdm_ch))

tdm_ch <- t(tdm_ch)
ncol(tdm_ch)

## if working with sample size of 45000
## col_sample <- sample(ncol(tdm_ch), 45000)
## tdm_ch <- tdm_ch[, col_sample]
## ncol(tdm_ch)

tdm_ch <- as.matrix(tdm_ch)
cosine_sim_mat_ch <- cosSparse(tdm_ch, norm = norm2)
cosine_sim_mat_ch <- as.matrix(cosine_sim_mat_ch)
diag(cosine_sim_mat_ch) <- 0

## if working with sample size of 45000
## rownames(cosine_sim_mat_ch) <- c(1:45000)
## colnames(cosine_sim_mat_ch) <- c(1:45000)

rownames(cosine_sim_mat_ch) <- c(1:221032)
colnames(cosine_sim_mat_ch) <- c(1:221032)


# Building the graph for Chicago
ig <- graph.adjacency(cosine_sim_mat_ch, mode="undirected", weighted=TRUE)

## if working with sample size of 45000
## nodes <- cbind(as.character(c(1:45000)))

nodes <- cbind(as.character(c(1:221032)))
colnames(nodes) <- c("ID")


#### Louvain Algorithm 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
louvain_sizesComm <- subset(louvain_sizesComm, louvain_sizesComm > 1)
print(louvain_sizesComm)


print(louvain_modularity)
membership_ch <- louvain$membership

## if working with sample size of 45000
## memb_type_ch <- cbind(as.character(c(1:45000)), membership_ch)

memb_type_ch <- cbind(as.character(c(1:221032)), membership_ch)
colnames(memb_type_ch) <- c("Source", "Modularity Class")

# filter out communities less than 2
com_topic_ch <- cbind(nodes, membership_ch)
com_topic_ch <- as.data.frame(com_topic_ch)
com_topic_ch <- com_topic_ch[com_topic_ch$membership_ch == 22 | com_topic_ch$membership_ch == 103 |com_topic_ch$membership_ch == 403 | 
                               com_topic_ch$membership_ch == 612 |com_topic_ch$membership_ch == 738 |com_topic_ch$membership_ch == 875 |
                               com_topic_ch$membership_ch == 876 |com_topic_ch$membership_ch == 965 |com_topic_ch$membership_ch == 986 |
                               com_topic_ch$membership_ch == 1222 |com_topic_ch$membership_ch == 1775 |com_topic_ch$membership_ch == 1977 |
                               com_topic_ch$membership_ch == 2133,]

# create a file to store what community each node belongs 
write.csv(com_topic_ch, file = "communities_chicago.csv")

colnames(memb_type_ch) <- c("Source", "Modularity Class")

#### Create graph files for Chicago 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_ch, by = "Source")

# Files to be entered in Gephie for Chicago
write.csv(nodes, file = "nodes_ch.csv")
write.csv(graph, file = "edges_ch.csv")

##############################################################################
####################### Istanbul - English         ###########################
##############################################################################
tdm_is <- read.MM('Louvain_Clustering/en_corpus_istanbul.mm')

######
# Here you can call function twitter_graph(tmd_is,length(tdm_is)) to get the graph
# and go to line 283
# Example: ig <- twitter_graph(tmd_is,length(tdm_is))

tdm_is <- t(tdm_is)
ncol(tdm_is)

tdm_is <- as.matrix(tdm_is)
cosine_sim_mat_is <- cosSparse(tdm_is, norm = norm2)
cosine_sim_mat_is <- as.matrix(cosine_sim_mat_is)
diag(cosine_sim_mat_is) <- 0
rownames(cosine_sim_mat_is) <- c(1:30352)
colnames(cosine_sim_mat_is) <- c(1:30352)

#### Create graph

ig <- graph.adjacency(cosine_sim_mat_is, mode="undirected", weighted=TRUE)


nodes <- cbind(as.character(c(1:30352)))
colnames(nodes) <- c("ID")


#### louvain algorithm

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
louvain_sizesComm <- subset(louvain_sizesComm, louvain_sizesComm > 1)
print(louvain_sizesComm)

#Community sizes
#40  189 3435 5083 7835 
#453 1448 4023  360 1932 

print(louvain_modularity)
#[1] 0.480221

membership_is <- louvain$membership

memb_type_is <- cbind(as.character(c(1:30352)), membership_is)
colnames(memb_type_is) <- c("Source", "Modularity Class")

com_topic_is <- cbind(nodes, membership_is)
com_topic_is <- as.data.frame(com_topic_is)
com_topic_is <- com_topic_is[com_topic_is$membership_is == 40 | com_topic_is$membership_is == 189 | com_topic_is$membership_is ==  3435|
                               com_topic_is$membership_is == 5083 | com_topic_is$membership_is == 7835,]

nrow(com_topic_is)
write.csv(com_topic_is, file = "communities_istanbul_english.csv")

colnames(memb_type_is) <- c("Source", "Modularity Class")

#### Cretae graph files for Istanbul - English 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_is, by = "Source")

# Nodes and Edges files to be entered into Gephie
write.csv(nodes, file = "nodes_is.csv")
write.csv(graph, file = "edges_is.csv")


##############################################################################
######################### Istanbul - Turkish      ############################
##############################################################################

tdm_tr <- read.MM('Louvain_Clustering/tr_corpus_istanbul.mm')
######
# Here you can call function twitter_graph(tmd_tr,length(tdm_tr)) to get the graph
# and go to line 378
# Example: ig <- twitter_graph(tmd_tr,length(tdm_tr))


tdm_tr <- t(tdm_tr)
ncol(tdm_tr)

## If working with sample size of 45000
## col_sample <- sample(ncol(tdm_tr), 45000)
## tdm_tr <- tdm_tr[, col_sample]
## ncol(tdm_tr)


tdm_tr <- as.matrix(tdm_tr)
cosine_sim_mat_tr <- cosSparse(tdm_tr, norm = norm2)
cosine_sim_mat_tr <- as.matrix(cosine_sim_mat_tr)
diag(cosine_sim_mat_tr) <- 0

## If working with sample size of 45000
## rownames(cosine_sim_mat_tr) <- c(1:25000)
## colnames(cosine_sim_mat_tr) <- c(1:25000)

rownames(cosine_sim_mat_tr) <- c(1:182287)
colnames(cosine_sim_mat_tr) <- c(1:182287)

####

ig <- graph.adjacency(cosine_sim_mat_tr, mode="undirected", weighted=TRUE)
#ig

## If working with sample size of 45000
## nodes <- cbind(as.character(c(1:45000)))

nodes <- cbind(as.character(c(1:182287)))
colnames(nodes) <- c("ID")


#### louvain algorithm

louvain <- cluster_louvain(graph = ig)
louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
louvain_sizesComm <- subset(louvain_sizesComm, louvain_sizesComm > 1)


print(louvain_sizesComm)
print(louvain_modularity)
membership_tr <- louvain$membership

## If working with sample size of 45000
## memb_type_tr <- cbind(as.character(c(1:45000)), membership_tr)

memb_type_tr <- cbind(as.character(c(1:182287)), membership_tr)
colnames(memb_type_tr) <- c("Source", "Modularity Class")

com_topic_tr <- cbind(nodes, membership_tr)
com_topic_tr <- as.data.frame(com_topic_tr)
com_topic_tr <- com_topic_tr[com_topic_tr$membership_tr == 2 | com_topic_tr$membership_tr == 57 | com_topic_tr$membership_tr == 153 |
                               com_topic_tr$membership_tr == 488 | com_topic_tr$membership_tr == 538 | com_topic_tr$membership_tr == 831 |
                               com_topic_tr$membership_tr == 1070 | com_topic_tr$membership_tr == 1118 | com_topic_tr$membership_tr == 1210 |
                               com_topic_tr$membership_tr == 1340 | com_topic_tr$membership_tr == 1361,]


write.csv(com_topic_tr, file = "communities_istanbul_turkish.csv")

colnames(memb_type_tr) <- c("Source", "Modularity Class")

#### Create the Nodes and Edges files 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_tr, by = "Source")

# files to be entered in Gephie for Istanbul in Turkish 
write.csv(nodes, file = "nodes_tr.csv")
write.csv(graph, file = "edges_tr.csv")


###########################################################################
###########################################################################
###########################################################################

# Preparing the file to be run in python to find topics for each community

#### Los Angeles 

# read in the file that contains the community number for each user
comm_la <- read.csv("communities_la.csv")
# read in the tf-idf matrix 
en_la <- read.csv("Louvain_Clustering/English_LA.csv")
# name comumns 
colnames(comm_la) <- c("", "Index", "membership_la")
colnames(en_la) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

# merge the two files by index 
en_la$Index <- c(1:354013)
merged_la <- merge(comm_la, en_la, by = "Index")
merged_la$Var.2 <- NULL

# write file to be used in topic modeling 
write.csv(merged_la, file = "merged_la.csv")
merged_la$user_id
table(merged_la$membership_la)

## Analyzing subgroups in Los Angeles (Working with the biggest one labeled '22')
table(merged_la$membership_la)
# select just twitter users that belong to community 22
subgroup_la <- merged_la[merged_la$membership_la == 1110,]

#running Louvain Algorithm in Community-22 to find subcommunities 
tdm_la <- read.MM('Louvain_Clustering/en_corpus_la.mm')
tdm_la <- t(tdm_la)
ncol(tdm_la)
tdm_la <- tdm_la[, subgroup_la$Index]
ncol(tdm_la)

## If working with sample size 2500
## col_sample <- sample(ncol(tdm_la), 2500)
## tdm_la <- tdm_la[, col_sample]
## ncol(tdm_la)

tdm_la <- as.matrix(tdm_la)
cosine_sim_mat_la <- cosSparse(tdm_la, norm = norm2)
cosine_sim_mat_la <- as.matrix(cosine_sim_mat_la)
dim(cosine_sim_mat_la)
diag(cosine_sim_mat_la) <- 0

## If working with sample size 2500
## rownames(cosine_sim_mat_la) <- c(1:2500)
## colnames(cosine_sim_mat_la) <- c(1:2500)

rownames(cosine_sim_mat_la) <- c(1:ncol(tdm_la))
colnames(cosine_sim_mat_la) <- c(1:ncol(tdm_la))

#### graph for LA subgroup

ig <- graph.adjacency(cosine_sim_mat_la, mode="undirected", weighted=TRUE)

nodes <- cbind(as.character(c(1:ncol(tdm_la))))
colnames(nodes) <- c("ID")

#### louvain for LA subgroup

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
louvain_sizesComm <- subset(louvain_sizesComm, louvain_sizesComm > 1)
print(louvain_sizesComm)


print(louvain_modularity)
sub_membership_la <- louvain$membership

sub_membership_la <- cbind(as.character(c(1:ncol(tdm_la))), sub_membership_la)
colnames(sub_membership_la) <- c("Source", "Modularity Class")

subcom_topic_la <- cbind(nodes, sub_membership_la)
subcom_topic_la <- as.data.frame(subcom_topic_la)
subcom_topic_la <- subcom_topic_la[subcom_topic_la$`Modularity Class` == 7 | subcom_topic_la$`Modularity Class` == 47 |subcom_topic_la$`Modularity Class` == 53 | 
                                     subcom_topic_la$`Modularity Class` == 56 |subcom_topic_la$`Modularity Class` == 79 |subcom_topic_la$`Modularity Class` == 93 |
                                     subcom_topic_la$`Modularity Class` == 101,]

write.csv(subcom_topic_la, file = "sub_community_la.csv")

#### graph for LA subgroup

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, subcom_topic_la, by = "Source")
write.csv(nodes, file = "nodes_subcomm_la.csv")
write.csv(graph, file = "edges_subcomm_la.csv")


######### Chicago 

comm_ch <- read.csv("communities_chicago.csv")
en_ch <- read.csv("Louvain_Clustering/English_Chicago.csv")
colnames(comm_ch) <- c("", "Index", "membership_ch")
colnames(en_ch) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_ch$Index <- c(1:221032)
merged_ch <- merge(comm_ch, en_ch, by = "Index")
merged_ch$Var.2 <- NULL

write.csv(merged_ch, file = "merged_ch.csv")

######### Istanbul - Turkish
comm_tr <- read.csv("communities_istanbul_turkish.csv")
en_tr <- read.csv("Turkish_Istanbul.csv")
colnames(comm_tr) <- c("", "Index", "membership_tr")
colnames(en_tr) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_tr$Index <- c(1:182287)
merged_tr <- merge(comm_tr, en_tr, by = "Index")
merged_tr$Var.2 <- NULL

write.csv(merged_tr, file = "merged_tr.csv")
merged_tr$user_id
table(merged_tr$membership_tr)

######### Istanbul - English
comm_is <- read.csv("communities_istanbul_english.csv")
nrow(comm_is)
en_is <- read.csv("Louvain_Clustering/English_Istanbul.csv")
colnames(comm_is) <- c("", "Index", "membership_is")
colnames(en_is) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_is$Index <- c(1:30352)
merged_is <- merge(comm_is, en_is, by = "Index")
merged_is$Var.2 <- NULL

write.csv(merged_is, file = "merged_is.csv")
merged_is$user_id
table(merged_is$membership_is)

########## Los Angeles - Subcommunitie 

comm_la <- read.csv("sub_community_la.csv")
en_la <- read.csv("Louvain_Clustering/English_LA.csv")
colnames(comm_la) <- c("", "Index", "Source","membership_la")
colnames(en_la) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_la$Index <- c(1:354013)
sub_merged_la <- merge(comm_la, en_la, by = "Index")
sub_merged_la$Var.2 <- NULL
sub_merged_la$Source <- NULL

write.csv(sub_merged_la, file = "sub_merged_la.csv")
sub_merged_la$user_id
table(sub_merged_la$membership_la)
