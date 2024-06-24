library(ggplot2)
library(leaflet)
library(sf)

sp <- read_sf("www/RN_Municipios_2021.shp")

mypalette <- colorNumeric(
  palette = "RdBu", domain = data_scores,
  na.color = "transparent"
)

m <- leaflet(sp) %>%
    addPolygons(fillColor = ~ mypalette(data_scores), stroke = FALSE)%>%
    setView(lng = -36.672949,
            lat = -5.820301,
            zoom = 8 ) %>%
    setMaxBounds(lng1 = -38.603290,
                lat1 = -7.255193,
                lng2 = -34.679883,
                lat2 = -4.532369 )

