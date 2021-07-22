library(rgdal)
library(tmap)
library(haven)
library(sf)
library("ggplot2")
theme_set(theme_bw())
library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons
library(gstat) # Use gstat's idw routine
library(sp)    # Used for the spsample function

setwd("C:\\Users\\user1\\Desktop\\Projects\\Econ-ControlVars\\Econ-GIS\\Data")
P <- read_dta("station_id.dta")
coordinates(P) <- ~longitude+latitude
P1 <- st_as_sf(P, coords=c("longitude", "latitude"), crs=4326)
class(P1)
W <- readOGR(dsn = ".\\GIS\\China_County\\county_baidu_mainland.shp", use_iconv=TRUE, encoding="UTF-8")
W1 <- st_read(dsn = ".\\GIS\\China_County\\county_baidu_mainland.shp")
sf::st_is_valid(W1)
# sf::st_is_valid(W)

ggplot(data = W1) +
  geom_sf(aes(fill = area)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")

ggplot(data = P1) +
  geom_sf(aes(fill = pre_summer_avg)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")

ggplot(data = W1) +
  geom_sf() +
  geom_sf(data = P1, aes(fill = pre_summer_avg)) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .4) +
  coord_sf(xlim = c(70, 140), ylim = c(10, 60), expand = FALSE)

# Replace point boundary extent with that of Texas
P@bbox <- W@bbox

tm_shape(W) + tm_polygons() + tm_fill("grey70") +
  tm_shape(P) +
  tm_bubbles(size = 0.02, col="pre_summer_avg", border.col = "black", border.alpha = .5, 
             style="fixed", breaks=c(0, 400, 800, 1200, 1600, 2000, 500000),
             palette="-RdYlBu", contrast=1,
             title.col="Summer Precipitation")



# Create an empty grid where n is the total number of cells
grd              <- as.data.frame(spsample(P, "regular", n=50000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(P) <- proj4string(P) # Temp fix until new proj env is adopted
proj4string(grd) <- proj4string(P)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
P.idw <- gstat::idw(pre_summer_avg ~ 1, P, newdata=grd, idp=2.0)

# Convert to raster object then clip to Texas
r       <- raster(P.idw)
r.m     <- mask(r, W)

# Plot
tm_shape(r.m) + 
  tm_raster(n=10, palette = "inferno", style = "log10_pretty",
            title="Predicted precipitation \n(in inches)") + 
  tm_legend(legend.outside=TRUE)