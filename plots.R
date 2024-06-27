library(ggplot2)
library(leaflet)
library(sf)

#reading shapefile

create_map_research <- function(data_research, data_scores){
    sp <- read_sf("www/RN_Municipios_2021.shp")

    bounding_box <- st_bbox(sp)

    #making sure both are in the same order
    cd_muns <- as.integer(as.data.frame(sp)[, "CD_MUN"])
    cd_muns_or <- data_research[, "CD_MUN"]
    value_order <- c()
    for(val in 1:length(cd_muns)){
        value_order <- c(value_order, which(cd_muns[val] == cd_muns_or)[[1]])
    }


    #setting pallete
    mypalette <- colorNumeric(
        palette = "RdBu", domain = data_scores,
        na.color = "transparent"
    )

    xmid <- (bounding_box[["xmax"]]-abs(bounding_box[["xmin"]]))/2
    ymid <- ( bounding_box[["ymax"]]-abs(bounding_box[["ymin"]]))/2
    #plotting map
    m <- leaflet(sp) %>%
        addTiles() %>%
        addPolygons(fillColor = ~ mypalette(data_scores[value_order]), stroke = FALSE, fillOpacity = 0.8)%>%
        fitBounds(lng1 = bounding_box[["xmax"]],
                    lat1 = bounding_box[["ymax"]],
                    lng2 = bounding_box[["xmin"]],
                    lat2 = bounding_box[["ymin"]])%>%
        setMaxBounds(lng1 = bounding_box[["xmax"]],
                    lat1 = bounding_box[["ymax"]],
                    lng2 = bounding_box[["xmin"]],
                    lat2 = bounding_box[["ymin"]])

    return(m)
}

create_map <- function(input_data, scores, sf_shapefile, id_name){
    bounding_box <- st_bbox(sf_shapefile)

    #making sure both are in the same order
    cd <- as.integer(as.data.frame(sf_shapefile)[, id_name])
    cd_or <- input_data[, id_name]
    value_order <- c()
    for(val in 1:length(cd)){
        value_order <- c(value_order, which(cd[val] == cd_or)[[1]])
    }
    print("here")


    #setting pallete
    mypalette <- colorNumeric(
        palette = "RdBu", domain = scores,
        na.color = "transparent"
    )

    xmid <- (bounding_box[["xmax"]]-abs(bounding_box[["xmin"]]))/2
    ymid <- ( bounding_box[["ymax"]]-abs(bounding_box[["ymin"]]))/2
    #plotting map
    m <- leaflet(sf_shapefile) %>%
        addTiles() %>%
        addPolygons(fillColor = ~ mypalette(scores[value_order]), stroke = FALSE, fillOpacity = 0.8)%>%
        fitBounds(lng1 = bounding_box[["xmax"]],
                    lat1 = bounding_box[["ymax"]],
                    lng2 = bounding_box[["xmin"]],
                    lat2 = bounding_box[["ymin"]])%>%
        setMaxBounds(lng1 = bounding_box[["xmax"]],
                    lat1 = bounding_box[["ymax"]],
                    lng2 = bounding_box[["xmin"]],
                    lat2 = bounding_box[["ymin"]])

    return(m)
}

