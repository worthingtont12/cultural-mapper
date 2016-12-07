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
    column(2,
      h3("Languages in Los Angeles"),
      # Select Languages here
      selectizeInput("lang",
                     label = "Languages of Interest",
                     choices = as.character(unique(city$data$language)),
                     multiple = T,
                     options = list(maxItems = 9, placeholder = 'Select a language'),
                     selected = "Spanish")
    ),
    column(10,
      leafletOutput("map1")
    )
  ),
  fluidRow(
    column(9,
      dygraphOutput("dygraph1",height = 200)
    ),
    column(3,
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
      setView(lng = city$center$long, lat = city$center$lat, zoom = 9)
  })
  
  output$dygraph1 <- renderDygraph({
    location_dygraph(city, pal) %>%
      dyLegend(labelsDiv = "dyLegend")
  })
  
  # When languages are changed!
  observeEvent(input$lang, {
    # Create Subset of the data by the languages selected
    subset <- subset(city$data) %>%
                  filter(language %in% input$lang) %>%
                  # filter(created_at >= start & created_at <= end) %>%
                  arrange(language)
    # Update the color pallette
    pal_sub <- pal[1:length(input$lang)]
    factpal <- colorFactor(pal_sub, subset$language)


    the_xts <- countLang(subset,zone)

    # Render the Dygraph
    output$dygraph1 <- renderDygraph({
      createDygraph(the_xts, pal=pal_sub)%>%
        dyLegend(labelsDiv = "dyLegend",
                 labelsSeparateLines = TRUE)
    })

    # Update the Leaflet
      leafletProxy("map1") %>%
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(lng=subset$long,
                         lat=subset$lat,
                         color = factpal(subset$language),
                         radius = 5,
                         stroke = FALSE, fillOpacity = .5,
                         popup = paste0(subset$created_at,
                                        "<br>",
                                        subset$language),
                         group = subset$language
        )
     })
  
  # Use Dygraph Sliders to adjust the time
  # observeEvent(input$dygraph1_date_window, {
  #   if(!is.null(input$dygraph1_date_window)){
  #     # leaflet comes with this nice feature leafletProxy
  #     #  to avoid rebuilding the whole map
  #     #  let's use it
  #     # start <- as.POSIXct(req(input$dygraph1_date_window[[1]]),  tz = city$zone)
  #     # end <- as.POSIXct(req(input$dygraph1_date_window[[2]]), tz = city$zone)
  # 
  #     subset_time <- subset %>%
  #                   filter(created_at >= start & created_at <= end) %>%
  #                   arrange(language)
  # 
  #     leafletProxy("map1") %>%
  #       clearMarkers() %>%
  #       clearShapes() %>%
  #       addCircleMarkers(lng=subset$long,
  #                        lat=subset$lat,
  #                        color = factpal(subset$language),
  #                        radius = 5,
  #                        stroke = FALSE, fillOpacity = .5,
  #                        popup = paste0(subset$created_at,
  #                                       "<br>",
  #                                       subset$language),
  #                        group = subset$language
  #       )
  #   }
  # })
  
}


# Launch the Server
shinyApp(ui, server)