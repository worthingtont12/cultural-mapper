#### Global ####

library(shiny)
library(leaflet)
library(dygraphs)
library(dplyr)
library(rgdal)
library(RColorBrewer)

# Read in Data
source('Registry.R')
city <- location('../../Data/Queries/LA_Geotagged.csv', 
                           "America/Los_Angeles",
                           -118.723549, 33.694679, -117.929466, 34.33926)
zone <- city$zone

# Create Color Palette
pal <- brewer.pal(9, "Set1")

#### UI ####
ui <- fluidPage(
  fluidRow(
    column(3,
           h3("Languages in Los Angeles"),
           # Select Languages here
           selectizeInput("lang",
                          label = "Languages of Interest",
                          choices = as.character(unique(city$data$language)),
                          multiple = T,
                          options = list(maxItems = 9, placeholder = 'Select a language'),
                          selected = "Spanish")
           
    ),
    column(9,
           leafletOutput("map1")
    )
  ),
  fluidRow(
    column(10,
           dygraphOutput("dygraph1",height = 200)
    ),
    column(2,
           textOutput("dyLegend")
    )
  )
)

#### Server ####
server <- function(input, output, session) {
  output$map1 <- renderLeaflet({
    #location_map(city)
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng = city$center$long, lat = city$center$lat, zoom = 10)
  })
  
  output$dygraph1 <- renderDygraph({
    createDygraph(countLang(city$data, city$zone)$Spanish, pal=pal) %>%
      dyLegend(labelsDiv = "dyLegend",
               labelsSeparateLines = TRUE)
  })
  
  langs <- eventReactive(input$lang, {
    temp <- subset(city$data) %>%
      filter(language %in% input$lang) %>%
      arrange(language)
    temp
  })
  
  times <- eventReactive(input$dygraph1_date_window,{
    start <- as.POSIXct(req(input$dygraph1_date_window[[1]]),  tz = city$zone)
    end <- as.POSIXct(req(input$dygraph1_date_window[[2]]), tz = city$zone)
    temp <- langs() %>%
                  filter(created_at >= start & created_at <= end) %>%
                  arrange(language)
    temp
  })
  
  observeEvent(input$lang, {
    subset <- isolate(langs())
    subset_time <- isolate(times())
    pal_sub <- pal[1:length(input$lang)]
    factpal <- colorFactor(pal_sub, subset$language)
    the_xts <- countLang(subset,zone)
    
    # Render the Dygraph
    output$dygraph1 <- renderDygraph({
      createDygraph(the_xts, pal=pal_sub)%>%
        dyLegend(labelsDiv = "dyLegend",
                 labelsSeparateLines = TRUE)
    })
    
    leafletProxy("map1") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircles(lng=subset_time$long,
                       lat=subset_time$lat,
                       color = factpal(subset_time$language),
                       radius = 50,
                       stroke = FALSE, fillOpacity = .5,
                       popup = paste0(subset_time$created_at,
                                      "<br>",
                                      subset_time$language),
                       group = subset_time$language,
                       weight = 0
                 )
  })
  
  observeEvent(input$dygraph1_date_window, {
    subset <- isolate(langs())
    
    pal_sub <- pal[1:length(input$lang)]
    factpal <- colorFactor(pal_sub, subset$language)
    start <- as.POSIXct(req(input$dygraph1_date_window[[1]]),  tz = zone)
    end <- as.POSIXct(req(input$dygraph1_date_window[[2]]), tz = zone)
    
    subset_time <- isolate(times())
    
    leafletProxy("map1") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircles(lng=subset_time$long,
                       lat=subset_time$lat,
                       color = factpal(subset_time$language),
                       radius = 50,
                       stroke = FALSE, fillOpacity = .5,
                       popup = paste0(subset_time$created_at,
                                      "<br>",
                                      subset_time$language),
                       group = subset_time$language, weight = 0)
  })
}

# Launch the Server
shinyApp(ui, server)
