library(dplyr)

# Extract Day of the Week as an additional feature
topics_merged_clean <- topics_merged_clean %>%
  mutate(dow = as.numeric(strftime(tz,'%u')))

# Convert dow to 2D angular time - multiply by 360/7
# Convert hour to 2D angular time - multiply by 360/24

# sin/cos take radians. Function for conversion:
# degrees to radians =d *pi /180

deg.to.rad <- function(x){
  rad <- x*(pi/180)
  rad
}

topics_angluar <- topics_merged_clean %>%
                  select(top_topic,lat,long,day,hour,dow) %>%
                  mutate(
                    dow = dow*(360/7),
                    hour = hour*(360/24)
                  ) %>% transmute(
                    top_topic = as.factor(top_topic),
                    lat = lat,
                    long = long,
                    dow_sin = sin(deg.to.rad(dow)),
                    dow_cos = cos(deg.to.rad(dow)),
                    hour_sin = sin(deg.to.rad(hour)),
                    hour_cos = cos(deg.to.rad(hour))
                  )



