library(ggplot2)
library(leaflet)
library(sf)

#reading shapefile

create_map <- function(data_research, data_scores){
  sp <- read_sf("www/RN_Municipios_2021.shp")

  #making sure both are in the same order
  cd_muns <- as.integer(as.data.frame(sp)[, "CD_MUN"])
  cd_muns_or <- data_research[, "Code"]
  value_order <- c()
  for(val in 1:length(cd_muns)){
    value_order <- c(value_order, which(cd_muns[val] == cd_muns_or)[[1]])
  }


  #setting pallete
  mypalette <- colorNumeric(
    palette = "RdBu", domain = data_scores,
    na.color = "transparent"
  )


  #plotting map
  m <- leaflet(sp) %>%
      addPolygons(fillColor = ~ mypalette(data_scores[value_order]), stroke = FALSE, fillOpacity = 1)%>%
      setView(lng = -36.672949,
              lat = -5.820301,
              zoom = 8 ) %>%
      setMaxBounds(lng1 = -38.603290,
                  lat1 = -7.255193,
                  lng2 = -34.679883,
                  lat2 = -4.532369 )

  return(m)
}

