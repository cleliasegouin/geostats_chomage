library(sf)
library(readr)
library(dplyr)


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

# 3. Calcul des frequence par habitants 
# 3.1 Affichage de la fréquence de passages par habitant par commune
frequence_par_commune_conso$freq_par_hab = 
  frequence_par_commune_conso$arrival_time_num/
  frequence_par_commune_conso$P20_POP156

stops_par_commune_conso$stops_par_hab = 
  stops_par_commune_conso$stop_id /
  stops_par_commune_conso$P20_POP156


write.csv2(chomage_commune, "data/output/chomage_par_commune.csv")
write.csv2(frequence_par_commune_conso, "data/output/frequence_par_commune_conso.csv")
write.csv2(stops_par_commune_conso, "data/output/stop_par_commune_conso.csv")




