library(plyr)
library(dplyr)
library(readr)
library(ggplot2)
library(ggpubr)
library(sf)
library(mapsf)


## Changer de répertoire de travail : 

setwd("~/ENSG/geodatascience/geostats_chomage")

# 1. Import des fichiers
# 1.1 Import des données brutes
communes <- st_read('data/communes_arrondissements/cities_arr.shp')
# 1.2 Import des résultats du traitement des données
frequence_par_commune <- read.csv('data/transports_idf/frequence_par_commune.csv')
stops_par_commune <- read.csv('data/transports_idf/stops_par_commune.csv')
pop_active <- read.csv('data/emploi/pop_active.csv', sep = ';')

# 2. Jointures sur les communes
# 2.1 Jointure de la fréquence par commune sur les communes
frequence_par_commune$CODGEO <- as.character(frequence_par_commune$CODGEO)
frequence_par_commune_conso = left_join(x = communes,
                                        y = frequence_par_commune,
                                        by = join_by(CODGEO))
# 2.2 Jointure des stops par commune sur les communes
stops_par_commune$CODGEO <- as.character(stops_par_commune$CODGEO)
stops_par_commune_conso = left_join(x = communes,
                                    y = stops_par_commune,
                                    by = join_by(CODGEO))
# 2.3 Jointure du taux de chômage
pop_active$CODGEO <- as.character(pop_active$CODGEO)
chomage_commune = left_join(x = communes,
                            y = pop_active,
                            by = join_by(CODGEO))

frequence_par_commune_conso$freq_par_hab = 
  frequence_par_commune_conso$arrival_time_num/
  frequence_par_commune_conso$P20_POP156

stops_par_commune_conso$stops_par_hab = 
  stops_par_commune_conso$stop_id /
  stops_par_commune_conso$P20_POP156

# 3. Affichage des cartes
# 3.1 Affichage de la fréquence de passages par habitant par commune

mf_map(x = frequence_par_commune_conso,
       var = "freq_par_hab",
       type = "choro",
       leg_title = "Nombre de passages\n par habitant")
mf_title("Carte du nombre de passages par habitant par commune en Île-de-France")
mf_scale()
mf_arrow(pos = "topright")

mf_map(x = frequence_par_commune_conso,
       var = "freq_par_hab",
       type = "prop")

# 3.2 Affichage de la proportion de stops par habitant par commune



mf_map(x = stops_par_commune_conso,
       var = "stops_par_hab",
       type = "choro",
       leg_title = "Nombre d'arrêts\n par habitant")
mf_title("Carte du nombre d'arrêts par habitant commune en Île-de-France")
mf_scale()
mf_arrow(pos = "topright")

mf_base(communes, col = "white", border = "black")
points((6961598.08,3113789.96))

mf_map(x = c(6961598.08,3113789.96))
mf_map(x = stops_par_commune_conso,
       var = "stop_id",
       type = "prop")


# 3.3 Chômage par commune
mf_map(x = chomage_commune,
       var = "taux_CHOM1564_POP1564",
       type = "choro",
       pal = "Peach",
       leg_title = "Taux de chômage\n par commune")
mf_title("Carte du taux de chômage par commune en Île-de-France")
mf_scale()
mf_arrow(pos = "topright")

