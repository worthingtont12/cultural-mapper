# Hat tip to:
# http://stackoverflow.com/questions/31814037/integrating-time-series-graphs-and-leaflet-maps-using-r-shiny

library(shiny)
library(leaflet)
library(dygraphs)
library(dplyr)
library(rgdal)

# Create initial Map
# geo_map <- location_map(la_geo)

# Create XTS
# geo_filter <- la_geo$data
# geo_filter$rounded <- as.character.Date(geo_filter$rounded)
# Lang_sum <- geo_filter %>%
#   group_by(language, rounded) %>%
#   summarise(count=n()) %>%
#   spread(language,count, fill = 0) %>%
#   arrange(rounded)
# Lang_sum$rounded <- as.POSIXct(Lang_sum$rounded, tz = "America/Los_Angeles")
# volume <- colSums(Lang_sum[,-1])
# languages <- names(volume[volume > 100])
# the_xts<-xts(Lang_sum[,-1], order.by=Lang_sum$rounded, tz = "America/Los_Angeles")


# https://plot.ly/r/shinyapp-UN-advanced/ for selectizeInput

# Create UI for Shiny
ui <- fluidPage(
  sidebarPanel(
    h3("Languages in Los Angeles"),
    # Select Languages here
    selectizeInput("lang", label = "Languages of Interest",
                   choices = unique(language), multiple = T,
                   options = list(maxItems = 12, placeholder = 'Select a language'),
                   selected = "Spanish")
  ),
  mainPanel(
    leafletOutput("map1")
  ),
  dygraphOutput("dygraph1",height = 300)
)


geo <- la_geo
# Create Shiny Server
server <- function(input, output, session) {
  v <- reactiveValues(msg = "")
  
  get_Data <- reactive(
    
  )
  
  observe({
    langs <- input$lang
  })
  
  output$map1 <- renderLeaflet({
    location_map(geo)
  })
  output$dygraph1 <- renderDygraph({
    location_dygraph(geo)
  })
  
  observeEvent(input$dygraph1_date_window, {
    if(!is.null(input$dygraph1_date_window)){
      # leaflet comes with this nice feature leafletProxy
      #  to avoid rebuilding the whole map
      #  let's use it
      start <- as.POSIXct(req(input$dygraph1_date_window[[1]]),  tz = geo$tz)
      end <- as.POSIXct(req(input$dygraph1_date_window[[2]]), tz = geo$tz)
      
      subset <- geo_filter[geo_filter$created_at >= start &
                             geo_filter$created_at <= end,]
      
      leafletProxy("map1") %>%
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(lng=subset$long,
                         lat=subset$lat,
                         color = subset$color,
                         radius = 5,
                         stroke = FALSE, fillOpacity = .5,
                         popup = paste0(subset$created_at,
                                        "<br>",
                                        subset$language),
                         group = subset$language
                         )
    }
  })
}

# Launch the Server
shinyApp(ui, server)
