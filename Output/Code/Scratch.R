# https://gist.github.com/tcash21/f31588449076ea8e54d9
library(RColorBrewer)
library(stringr)
library(wordcloud)
library(tm)
library(ggplot2)
library(xts)
library(dygraphs)
library(rCharts)
library(shiny)
library(streamR)
Sys.setlocale('LC_ALL','C')

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  getData <- reactive({
    invalidateLater(35000, session)
    load("/home/ec2-user/twitterScrape/tweets.Rdat")
    tweets <- tweets.df
    tweets <- tweets[grep("StrataHadoop", tweets$text),]
    tweets$created_at<-as.POSIXct(tweets$created_at, format='%a %b %d %H:%M:%S', tz="UTC")
    tweets$created_at <- tweets$created_at - (4 * 60 * 60)
    tweets <- tweets[order(tweets$created_at, decreasing=TRUE),]
    tweets
  })
  
  output$results = renderDataTable({
    tweets <- getData()
    return(tweets[c("created_at", "text", "screen_name")])
  }, options = list(searching = FALSE, pageLength=7))
  
  output$tweetVolume = renderDygraph({
    tweets <- getData()
    tweets$threeMins <- paste0(substr(tweets$created, 12, 15), "3")
    tweets$threeMins <- paste0(as.Date(tweets$created_at, format='%a %b %d'), " ", tweets$threeMins, ":00")
    the_data <- data.frame(table(tweets$threeMins))
    the_data$Var1<-as.POSIXct(as.character(the_data$Var1))
    the_xts<-xts(the_data[,2], order.by=the_data[,1])
    colnames(the_xts)[1] <- "Tweets"
    dygraph(the_xts)
  })
  
  
  output$topTweeters = renderPlot({
    tweets <- getData()
    top_tweeters <- tail(data.frame(sort(table(tweets$screen_name))), n=10)
    top_tweeters <- data.frame(top_tweeters[nrow(top_tweeters):1,])
    top_tweeters <- data.frame(screen_name=rownames(top_tweeters), number_of_tweets=top_tweeters)
    colnames(top_tweeters)[2]  <- "Number.of.Tweets"
    g <- ggplot(top_tweeters, aes(x=reorder(screen_name, Number.of.Tweets), y=Number.of.Tweets)) + geom_bar(stat="identity")
    g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
    print(g)
    
  })
  
  output$topTweetersTable = renderDataTable({
    tweets <- getData()
    top_tweeters <- data.frame(sort(table(tweets$screen_name)))
    top_tweeters <- data.frame(top_tweeters[nrow(top_tweeters):1,])
    top_tweeters <- data.frame(screen_name=rownames(top_tweeters), number_of_tweets=top_tweeters)
    colnames(top_tweeters)[2]  <- "Number.of.Tweets"
    top_tweeters
    
  }, options = list(searching = FALSE, pageLength=10))
  
  
  output$wordCloud = renderPlot({
    tweets <- getData()
    all.words <- strsplit(paste(tweets$text, collapse=" "), " ")
    all.words <- sapply(all.words, function(x) str_replace_all(x, "[^[:alnum:]]", ""))
    all.words.clean <- unlist(all.words)[-which(tolower(unlist(all.words)) %in% stopwords())]
    all.words.df <- data.frame(table(tolower(all.words.clean)))
    all.words.df <- all.words.df[order(all.words.df$Freq, decreasing=TRUE),]
    bad <- c("-", "", " ", "@", "&amp;", "rt", "see", "$1", "+", "w/", "201.", "say", "it", "dont", "1")
    all.words.df <- all.words.df[-which(all.words.df[,1] %in% bad),]
    all.words.df <- all.words.df[-grep("http|strata|amp|201|and",  tolower(all.words.df[,1])),]
    all.words.df[,1] <- tolower(all.words.df[,1])
    pal <- brewer.pal(8,"Dark2")
    min.freq <- dim(all.words.df)[1] * .015
    wordcloud(all.words.df[,1], all.words.df[,2],min.freq=min.freq,scale=c(6, .75), colors=pal)
  })
  
  output$wordCloudTable = renderDataTable({
    tweets <- getData()
    all.words <- strsplit(paste(tweets$text, collapse=" "), " ")
    all.words <- sapply(all.words, function(x) str_replace_all(x, "[^[:alnum:]]", ""))
    all.words.clean <- unlist(all.words)[-which(tolower(unlist(all.words)) %in% stopwords())]
    all.words.df <- data.frame(table(tolower(all.words.clean)))
    all.words.df <- all.words.df[order(all.words.df$Freq, decreasing=TRUE),]
    bad <- c("-", "", " ", "@", "&amp;", "rt", "see", "$1", "+", "w/", "201.", "say", "it", "dont", "1")
    all.words.df <- all.words.df[-which(all.words.df[,1] %in% bad),]
    all.words.df <- all.words.df[-grep("http|strata|amp|201|and",  tolower(all.words.df[,1])),]
    all.words.df[,1] <- tolower(all.words.df[,1])
    all.words.df
  })
  
})