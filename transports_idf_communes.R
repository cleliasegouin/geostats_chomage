library(plyr)
library(dplyr)
library(readr)
library(ggplot2)
library(ggpubr)
library(sf)
library(mapsf)

# 1. Import des données
stops <- read.csv('C:\\Users\\julie\\Documents\\3A\\STATISTIQUES\\PROJET GEOSTATS\\DONNEES\\Horaires et fréquence sur les lignes TeC IDF\\IDFM-gtfs\\stops.txt')
stop_times <- read.csv('C:\\Users\\julie\\Documents\\3A\\STATISTIQUES\\PROJET GEOSTATS\\DONNEES\\Horaires et fréquence sur les lignes TeC IDF\\IDFM-gtfs\\stop_times.txt')
communes <- st_read('C:\\Users\\julie\\Documents\\3A\\STATISTIQUES\\PROJET GEOSTATS\\DONNEES\\Communes-20231212T101653Z-001\\Communes\\COMMUNE.shp')
stops_shp <- st_read('C:\\Users\\julie\\Documents\\3A\\STATISTIQUES\\PROJET GEOSTATS\\DONNEES\\stops_test.shp')

# 2. Conversion du fichier txt des arrêts en couche shp
stops_spatial <- sf::st_as_sf(x = stops,                         
                              coords = c("stop_lon", "stop_lat"),
                              crs = 4326)

# 3. Affichage 
mf_map(communes)
mf_map(stops_spatial, col = "darkblue")

# 4. Agrégation sur les arrêts pour avoir le nombre de passages par arrêt
# 4.1. Création d'une table simplifié depuis stop_times
stop_times$arrival_time_num = c(1)
stop_times_reduit = data_frame("stop_id" = stop_times$stop_id,
                      "arrival_time_num" = stop_times$arrival_time_num)
# 4.2 Calcul de l'agrégation
frequence_par_arret = ddply(stop_times_reduit, .(stop_id), colwise(sum))

# 5. Jointure de la table des fréquences sur les arrêts
stops_conso = left_join(x = stops_spatial,
                            y = frequence_par_arret,
                            by = join_by(stop_id))

# 6. Jointure sur les communes
communes_reduit = data.frame("communes_id" = communes$ID,
                    "population" = communes$POPULATION)
stops_test = st_read('C:\\Users\\julie\\Documents\\3A\\STATISTIQUES\\PROJET GEOSTATS\\DONNEES\\stops_test.shp')
communes_conso <- st_join(x = communes,y = stops_spatial,join = st_contains)

