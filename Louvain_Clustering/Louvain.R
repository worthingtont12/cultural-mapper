######################## Capstone #################################
setwd("~/Desktop/Cultural_Mapper-master/Comm_detection_Louvain")
install.packages("spam")
install.packages("igraph")
install.packages("qlcMatrix")
install.packages("networkD3")
library(spam)
library(igraph)
library(qlcMatrix)
library(networkD3)



tdm <- read.MM('en_corpus.mm')
tdm1 <- t(tdm)
ncol(tdm1)
tdm1 <- tdm1[, sample(ncol(tdm1), 500)]
ncol(tdm1)

tdm1 <- as.matrix(tdm1)
cosine_sim_mat <- cosSparse(tdm1, norm = norm2)
cosine_sim_mat <- as.matrix(cosine_sim_mat)
diag(cosine_sim_mat) <- 0
cosine_sim_mat[lower.tri(cosine_sim_mat)] <- 0
rownames(cosine_sim_mat) <- c(1:500)
colnames(cosine_sim_mat) <- c(1:500)

####

ig <- graph.adjacency(cosine_sim_mat, mode="undirected", weighted=TRUE)
ig

nodes <- cbind(as.character(c(1:500)))
colnames(nodes) <- c("ID")

#### louvain 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
memb <- louvain$membership


memb_type <- cbind(as.character(c(1:500)), memb)

colnames(memb_type) <- c("Source", "Modularity Class")

#### graph 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type, by = "Source")
write.csv(nodes, file = "nodes.csv")
write.csv(graph, file = "graph.csv")

write.csv(memb_type, file = "memb.csv")

#plot(ig)
#plot(ig, edge.label=round(E(ig)$weight, 1))





#memberships <- membership(louvain)
#network.result <- as.data.frame(cbind(names(memberships), membership(louvain)))
#names(network.result) <- c("group_assignment")

#id <- c(1:500)
#network.result <- cbind(id,network.result)

#cosine_sim_mat <- as.matrix(cosine_sim_mat)
#cosine_sim_mat <- as.data.frame(cosine_sim_mat)

#simpleNetwork(network.result)


V(ig)$color <- louvain$membership + 1
#plot(ig,vertex.size = 5, vertex.label.dist = 1)
louvain_Layout <- layout_with_fr(ig)

#plot(x = louvain, y = ig, vertex.size = 10)
plot(x = louvain, y = ig, edge.width = 1, vertex.size = 5, 
     vertex.label = NA, mark.groups = NULL, layout = louvain_Layout)



edge.weights <- function(community, network, weight.within = 100, weight.between = 1) {
  bridges <- crossing(communities = community, graph = network)
  weights <- ifelse(test = bridges, yes = weight.between, no = weight.within)
  return(weights) 
}

E(ig)$weight <- edge.weights(louvain, ig)
# I use the original layout as a base for the new one
louvain_LayoutA <- layout_with_fr(ig, louvain_Layout)
# the graph with the nodes grouped
plot(x = louvain, y = ig, edge.width = 0.5, vertex.size = 5, 
     mark.groups = NULL, layout = louvain_LayoutA, vertex.label = NA)

layout.modular <- function(G,c){
  nm <- length(levels(as.factor(c$membership)))
  gr <- 2
  while(gr^2<nm){
    gr <- gr+1
  }
  i <- j <- 0
  for(cc in levels(as.factor(c$membership))){
    F <- delete.vertices(G,c$membership!=cc)
    F$layout <- layout.kamada.kawai(F)
    F$layout <- layout.norm(F$layout, i,i+0.5,j,j+0.5)
    G$layout <- layout.fruchterman.reingold(G)
    G$layout[c$membership==cc,] <- F$layout
    if(i==gr){
      i <- 0
      if(j==gr){
        j <- 0
      }else{
        j <- j+1
      }
    }else{
      i <- i+1
    }
  }
  return(G$layout)
}

ig$layout <- layout.modular(ig,louvain)
V(ig)$color <- rainbow(length(levels(as.factor(louvain$membership))))[louvain$membership]
#plot(ig)


head(get.edgelist(ig))


plot(x = louvain, y = ig, edge.width = 0.5, vertex.size = 5, 
     mark.groups = NULL,layout = ig$layout, vertex.label = NA)

head(get.edgelist(ig))
head(round( E(ig)$weight, 3 ))
write.table(cosine_sim_mat, file = "graph.csv", sep = ";")


######################################
setwd("~/Desktop/Cultural_Mapper-master/Comm_detection_Louvain")
install.packages("spam")
install.packages("igraph")
install.packages("qlcMatrix")

library(spam)
library(igraph)
library(qlcMatrix)


########## Los Angeles 
tdm_la <- read.MM('en_corpus_la.mm')
tdm1_la <- t(tdm_la)
ncol(tdm1_la)
col_sample <- sample(ncol(tdm1_la), 500)
tdm1_la <- tdm1_la[, col_sample]
ncol(tdm1_la)

tdm1_la <- as.matrix(tdm1_la)
cosine_sim_mat_la <- cosSparse(tdm1_la, norm = norm2)
cosine_sim_mat_la <- as.matrix(cosine_sim_mat_la)
diag(cosine_sim_mat_la) <- 0
rownames(cosine_sim_mat_la) <- c(1:500)
colnames(cosine_sim_mat_la) <- c(1:500)

####

ig <- graph.adjacency(cosine_sim_mat_la, mode="undirected", weighted=TRUE)
#ig

nodes <- cbind(as.character(col_sample))
colnames(nodes) <- c("ID")

#### louvain 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
membership_la <- louvain$membership

com_topic_la <- cbind(nodes, membership_la)
com_topic_la <- as.data.frame(com_topic_la)
#com_topic_la$membership_la <- as.numeric(com_topic_la$membership_la)
com_topic_la <- com_topic_la[com_topic_la$membership_la == 8 | com_topic_la$membership_la == 11 |com_topic_la$membership_la == 17 | 
                               com_topic_la$membership_la == 18 |com_topic_la$membership_la == 20 |com_topic_la$membership_la == 22 |
                               com_topic_la$membership_la == 24 |com_topic_la$membership_la == 26 |com_topic_la$membership_la == 28 |
                               com_topic_la$membership_la == 29 |com_topic_la$membership_la == 32 |com_topic_la$membership_la == 33,]

write.csv(com_topic_la, file = "communities_la.csv")
colnames(memb_type_la) <- c("Source", "Modularity Class")

#### graph 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_la, by = "Source")
write.csv(nodes, file = "nodes_la.csv")
write.csv(graph, file = "edges_la.csv")


############ Chicago 
setwd("~/Desktop/corpus")
tdm_ch <- read.MM('en_corpus_chicago.mm')
tdm1_ch <- t(tdm_ch)
ncol(tdm1_ch)
col_sample <- sample(ncol(tdm1_ch), 500)
tdm1_ch <- tdm1_ch[, col_sample]
ncol(tdm1_ch)

tdm1_ch <- as.matrix(tdm1_ch)
cosine_sim_mat_ch <- cosSparse(tdm1_ch, norm = norm2)
cosine_sim_mat_ch <- as.matrix(cosine_sim_mat_ch)
diag(cosine_sim_mat_ch) <- 0

rownames(cosine_sim_mat_ch) <- c(1:500)
colnames(cosine_sim_mat_ch) <- c(1:500)

####

ig <- graph.adjacency(cosine_sim_mat_ch, mode="undirected", weighted=TRUE)
#ig

nodes <- cbind(as.character(col_sample))
colnames(nodes) <- c("ID")


#### louvain 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
membership_ch <- louvain$membership


com_topic_ch <- cbind(nodes, membership_ch)
com_topic_ch <- as.data.frame(com_topic_ch)
#com_topic_ch$membership_ch <- as.numeric(com_topic_la$membership_ch)
com_topic_ch <- com_topic_ch[com_topic_ch$membership_ch == 9 | com_topic_ch$membership_ch == 20 |com_topic_ch$membership_ch == 22 | 
                               com_topic_ch$membership_ch == 23 |com_topic_ch$membership_ch == 25 |com_topic_ch$membership_ch == 26 |
                               com_topic_ch$membership_ch == 27 |com_topic_ch$membership_ch == 29 |com_topic_ch$membership_ch == 31 |
                               com_topic_ch$membership_ch == 32 |com_topic_ch$membership_ch == 33 |com_topic_ch$membership_ch == 34 |
                               com_topic_ch$membership_ch == 35 | com_topic_ch$membership_ch == 36,]

write.csv(com_topic_ch, file = "communities_chicago.csv")

colnames(memb_type_ch) <- c("Source", "Modularity Class")

#### graph 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_ch, by = "Source")
write.csv(nodes, file = "nodes_ch.csv")
write.csv(graph, file = "edges_ch.csv")

############# Turkey - English 
tdm_is <- read.MM('en_corpus_istanbul.mm')
tdm1_is <- t(tdm_is)
ncol(tdm1_is)
col_sample <- sample(ncol(tdm1_is), 500)
tdm1_is <- tdm1_is[, col_sample]
ncol(tdm1_is)

tdm1_is <- as.matrix(tdm1_is)
cosine_sim_mat_is <- cosSparse(tdm1_is, norm = norm2)
cosine_sim_mat_is <- as.matrix(cosine_sim_mat_is)
diag(cosine_sim_mat_is) <- 0
#cosine_sim_mat[lower.tri(cosine_sim_mat_la)] <- 0
rownames(cosine_sim_mat_is) <- c(1:500)
colnames(cosine_sim_mat_is) <- c(1:500)

####

ig <- graph.adjacency(cosine_sim_mat_is, mode="undirected", weighted=TRUE)
#ig

nodes <- cbind(as.character(col_sample))
colnames(nodes) <- c("ID")


#### louvain 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
membership_is <- louvain$membership


com_topic_is <- cbind(nodes, membership_is)
com_topic_is <- as.data.frame(com_topic_is)
#com_topic_is$membership_is <- as.numeric(com_topic_is$membership_is)
com_topic_is <- com_topic_is[com_topic_is$membership_is == 48 | com_topic_is$membership_is == 76 | com_topic_is$membership_is == 107 |
                               com_topic_is$membership_is == 145 | com_topic_is$membership_is == 175 | com_topic_is$membership_is == 264,]

write.csv(com_topic_la, file = "communities_istanbul_english.csv")

colnames(memb_type_is) <- c("Source", "Modularity Class")

#### graph 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_is, by = "Source")
write.csv(nodes, file = "nodes_is.csv")
write.csv(graph, file = "edges_is.csv")

############## Turkey - Turkish 
tdm_tr <- read.MM('tr_corpus_istanbul.mm')
tdm1_tr <- t(tdm_tr)
ncol(tdm1_tr)
col_sample <- sample(ncol(tdm1_tr), 500)
tdm1_tr <- tdm1_tr[, col_sample]

ncol(tdm1_tr)

tdm1_tr <- as.matrix(tdm1_tr)
cosine_sim_mat_tr <- cosSparse(tdm1_tr, norm = norm2)
cosine_sim_mat_tr <- as.matrix(cosine_sim_mat_tr)
diag(cosine_sim_mat_tr) <- 0
#cosine_sim_mat[lower.tri(cosine_sim_mat_la)] <- 0
rownames(cosine_sim_mat_tr) <- c(1:500)
colnames(cosine_sim_mat_tr) <- c(1:500)

####

ig <- graph.adjacency(cosine_sim_mat_tr, mode="undirected", weighted=TRUE)
#ig

nodes <- cbind(as.character(col_sample))
colnames(nodes) <- c("ID")

#### louvain 

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
membership_tr <- louvain$membership


com_topic_tr <- cbind(nodes, membership_tr)
com_topic_tr <- as.data.frame(com_topic_tr)
com_topic_tr <- com_topic_tr[com_topic_tr$membership_tr == 8 | com_topic_tr$membership_tr == 17 | com_topic_tr$membership_tr == 21 |
                               com_topic_tr$membership_tr == 27 | com_topic_tr$membership_tr == 30 | com_topic_tr$membership_tr == 31 |
                               com_topic_tr$membership_tr == 34 | com_topic_tr$membership_tr == 35 | com_topic_tr$membership_tr == 37 ,]

write.csv(com_topic_la, file = "communities_istanbul_turkish.csv")

colnames(memb_type_tr) <- c("Source", "Modularity Class")

#### graph 

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, memb_type_tr, by = "Source")
write.csv(nodes, file = "nodes_tr.csv")
write.csv(graph, file = "edges_tr.csv")

setwd("~/Desktop/Cultural_Mapper/Louvain_Clustering/communities")

# merging LA
comm_la <- read.csv("communities_la.csv")
en_la <- read.csv("English_LA.csv")
colnames(comm_la) <- c("", "Index", "membership_la")
colnames(en_la) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_la$Index <- c(1:354013)
merged_la <- merge(comm_la, en_la, by = "Index")
merged_la$Var.2 <- NULL

write.csv(merged_la, file = "merged_la.csv")
merged_la$user_id
table(merged_la$membership_la)

## Analyzing subgroups in Los Angeles (Working with the biggest one labeled '22')
table(merged_la$membership_la)
subgroup_la <- merged_la[merged_la$membership_la == 22,]
#running Louvain Algorithm in subgroup_la
setwd("~/Desktop/corpus")
tdm_la <- read.MM('en_corpus_la.mm')
tdm1_la <- t(tdm_la)
ncol(tdm1_la)
tdm1_la <- tdm1_la[, subgroup_la$Index]
ncol(tdm1_la)

tdm1_la <- as.matrix(tdm1_la)
cosine_sim_mat_la <- cosSparse(tdm1_la, norm = norm2)
cosine_sim_mat_la <- as.matrix(cosine_sim_mat_la)
diag(cosine_sim_mat_la) <- 0
rownames(cosine_sim_mat_la) <- c(1:149)
colnames(cosine_sim_mat_la) <- c(1:149)

#### graph for LA subgroup

ig <- graph.adjacency(cosine_sim_mat_la, mode="undirected", weighted=TRUE)

nodes <- cbind(as.character(c(1:149)))
colnames(nodes) <- c("ID")

#### louvain for LA subgroup

louvain <- cluster_louvain(graph = ig)

louvain_sizesComm <- sizes(louvain)
louvain_numComm <- length(louvain_sizesComm)
louvain_modularity <- modularity(louvain)

print(louvain_numComm)
print(louvain_sizesComm)
print(louvain_modularity)
sub_membership_la <- louvain$membership

subcom_topic_la <- cbind(nodes, sub_membership_la)
subcom_topic_la <- as.data.frame(subcom_topic_la)
subcom_topic_la <- subcom_topic_la[subcom_topic_la$sub_membership_la == 4 | subcom_topic_la$sub_membership_la == 6 |subcom_topic_la$sub_membership_la == 9 | 
                                     subcom_topic_la$sub_membership_la == 12 |subcom_topic_la$sub_membership_la == 13 |subcom_topic_la$sub_membership_la == 15 |
                                     subcom_topic_la$sub_membership_la == 16 |subcom_topic_la$sub_membership_la == 17,]

write.csv(subcom_topic_la, file = "sub_community_la.csv")
colnames(subcom_topic_la) <- c("Source", "Modularity Class")
#### graph for LA subgroup

graph <- cbind( get.edgelist(ig) , round( E(ig)$weight, 3))
type <- rep("Undirected",nrow(graph))
graph <- cbind(graph, type)


colnames(graph) <- c("Source", "Target", "Weight", "Type")
graph[,"Weight"] <- as.numeric(graph[,"Weight"])*1000

graph <- merge(graph, subcom_topic_la, by = "Source")
write.csv(nodes, file = "nodes_subcomm_la.csv")
write.csv(graph, file = "edges_subcomm_la.csv")


# merging Chicago
comm_ch <- read.csv("communities_chicago.csv")
en_ch <- read.csv("English_Chicago.csv")
colnames(comm_ch) <- c("", "Index", "membership_ch")
colnames(en_ch) <- c("Index", "user_id", "user_language", "top_topic", "topic_prob")

en_ch$Index <- c(1:221032)
merged_ch <- merge(comm_ch, en_ch, by = "Index")
merged_ch$Var.2 <- NULL

write.csv(merged_ch, file = "merged_ch.csv")
