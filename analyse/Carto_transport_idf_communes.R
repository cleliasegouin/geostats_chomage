library(plyr)
library(dplyr)
library(readr)
library(ggplot2)
library(ggpubr)
library(sf)
library(mapsf)

# 1. Import des fichiers
# 1.1 Import des données brutes
communes <- st_read('data/communes_arrondissements/cities_arr.shp')
data_revenus = read.csv('data/emploi/cc_filosofi_2020_COM.csv',sep=';')
# 1.2 Import des résultats du traitement des données
frequence_par_commune <- read.csv('data/output/frequence_par_commune.csv')
stops_par_commune <- read.csv('data/output/stops_par_commune.csv')
pop_active <- read.csv('data/output/pop_active.csv', sep = ';')
flux_idf_TC_chomage <- read.csv('data/output/flux_idf_TC_chomage_depart.csv', sep = ';')
flux_idf_VP_chomage <- read.csv('data/output/flux_idf_VP_chomage_depart.csv', sep = ';')

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

# 3.2 Affichage de la proportion de stops par habitant par commune
mf_map(x = stops_par_commune_conso,
       var = "stops_par_hab",
       type = "choro",
       leg_title = "Nombre d'arrêts\n par habitant")
mf_title("Carte du nombre d'arrêts par habitant commune en Île-de-France")
mf_scale()
mf_arrow(pos = "topright")

# 3.3 Chômage par commune
mf_map(x = chomage_commune,
       var = "taux_CHOM1564_POP1564",
       type = "choro",
       pal = "Peach",
       leg_title = "Taux de chômage\n par commune")
mf_title("Carte du taux de chômage par commune en Île-de-France")
mf_scale()
mf_arrow(pos = "topright")

# 3.4 Temps de trajet moyen des habitants de chaque commune en transport en commun
flux_idf_TC_chomage$VAL <- gsub(",", ".", flux_idf_TC_chomage$VAL)
flux_idf_TC_chomage$VAL = as.double(flux_idf_TC_chomage$VAL)
flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P <- gsub(",", ".", flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P)
flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P = as.double(flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P)

flux_idf_TC_chomage$mean_time = 
  flux_idf_TC_chomage$VAL /
  flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P

flux_idf_TC_chomage$Group.1 <- as.character(flux_idf_TC_chomage$Group.1)

flux_idf_TC_chomage_comm = left_join(x = communes,
                                y = flux_idf_TC_chomage,
                                by = c('CODGEO'='Group.1'))

mf_map(x = flux_idf_TC_chomage_comm,
       var = "mean_time",
       type = "choro",
       leg_title = "Temps de trajet moyen en transports\n en commun par\n commune de départ\n (en minutes)",
       pal = "Blues 3")
mf_title("Carte des temps de trajet moyens en transports en commun par commune")
mf_scale()
mf_arrow(pos = "topright")

# 3.5 Temps de trajet moyen des habitants par commune en véhicule privé
flux_idf_VP_chomage$MEAN_DURATION <- gsub(",", ".", flux_idf_VP_chomage$MEAN_DURATION)
flux_idf_VP_chomage$MEAN_DURATION = as.double(flux_idf_VP_chomage$MEAN_DURATION)
flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P <- gsub(",", ".", flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P)
flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P = as.double(flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P)

flux_idf_VP_chomage$mean_time = 
  flux_idf_VP_chomage$MEAN_DURATION /
  flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P

flux_idf_VP_chomage$Group.1 <- as.character(flux_idf_VP_chomage$Group.1)

flux_idf_VP_chomage_comm = left_join(x = communes,
                                     y = flux_idf_VP_chomage,
                                     by = c('CODGEO'='Group.1'))

mf_map(x = flux_idf_VP_chomage_comm,
       var = "mean_time",
       type = "choro",
       leg_title = "Temps de trajet\n moyen en véhicule\n privé par commune de départ\n (en minutes)",
       pal = "Blues 3")
mf_title("Carte des temps de trajet moyens en véhicule privé par commune")
mf_scale()
mf_arrow(pos = "topright")

# 3.6 Carte des revenus par commune
data_revenus$MED20 = as.double(data_revenus$MED20)

data_revenus_comm = left_join(x = communes,
                              y = data_revenus,
                              by = "CODGEO")

mf_map(x = data_revenus_comm,
       var = "MED20",
       type = "choro",
       leg_title = "Niveau de vie\n médian par commune",
       pal = "Blues 3")
mf_title("Carte du niveau de vie médian par commune")
mf_scale()
mf_arrow(pos = "topright")
