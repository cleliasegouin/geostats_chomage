library(ggplot2)

# Import des données 
flux_TC = read.csv("data/flux_dom_trav/flux_idf_TC_chomage.csv", sep=";")

data_revenus = read.csv('data/emploi/cc_filosofi_2020_COM.csv',sep=';')
data_revenus = select(data_revenus, CODGEO, MED20)

VP_flux_duration_idf_chom = read.csv("data/flux_dom_trav/flux_idf_VP_chomage.csv")
VP_flux_duration_idf_chom$CODGEO = as.character(VP_flux_duration_idf_chom$CODGEO)


## Analyse de la corrélation entre le taux de chomage et l'accessibilité à l'emploi: 
      # - en TC temps 
      # - en TC temps / emploi 
      # - selon la distance euclidienne entre les communes
      # - selon la distance au centre de paris 

## Temps de trajet 
plot(x=flux_TC$VAL,y=flux_TC$taux_CHOM1564_POP1564)


## Temps de trajet par le nombre d'emploi à destination

flux_TC$temps_par_emploi = flux_TC$VAL / as.numeric(flux_TC$NBFLUX_C19_ACTOCC15P) 
plot(x=flux_TC$temps_par_emploi,y=flux_TC$taux_CHOM1564_POP1564)

modele_temps_par_emploi = lm(taux_CHOM1564_POP1564~temps_par_emploi, data = flux_TC)
summary(modele_temps_par_emploi)
#cor(flux_TC$temps_par_emploi, flux_TC$taux_CHOM1564_POP1564, method = "pearson")


modele_temps_par_emploi_log = lm(log(taux_CHOM1564_POP1564)~log(temps_par_emploi),data=flux_TC)
summary(modele_temps_par_emploi_log)
plot(x=log(flux_TC$temps_par_emploi),y=log(flux_TC$taux_CHOM1564_POP1564))


## Selon la distance euclidienne

modele_dist = lm(log(taux_CHOM1564_POP1564)~log(euclidean_distance),data=flux_TC)
summary(modele_dist)


## Distance + temps en minute

modele_dist_temps = lm(taux_CHOM1564_POP1564~euclidean_distance+VAL,data=flux_TC)
summary(modele_dist_temps)

plot(x=flux_TC$euclidean_distance,y=flux_TC$taux_CHOM1564_POP1564)

# Pas de corrélation linéaire mais forte dépendance 
  #=> approximation par une regression adaptée aux données avec geom_smooth 

ggplot(data = flux_TC, aes(x = euclidean_distance, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  geom_smooth(method = NULL , se = TRUE) +  # Ajoute une ligne de régression linéaire
  theme_minimal() +  # Utilise un thème minimal pour le graphique
  labs(title = "Relation entre la distance euclidienne et le taux de chômage",
       x = "Distance Euclidienne",
       y = "Taux de Chômage")

## Selon la distance au centre de paris

flux_TC$taux_CHOM1564_POP1564 <- gsub(",", ".", flux_TC$taux_CHOM1564_POP1564)
flux_TC$taux_CHOM1564_POP1564 = as.double(flux_TC$taux_CHOM1564_POP1564)

flux_TC$euclidean_distance_centroid <- gsub(",", ".", flux_TC$euclidean_distance_centroid)
flux_TC$euclidean_distance_centroid = as.double(flux_TC$euclidean_distance_centroid)


plot(x=flux_TC$euclidean_distance_centroid,y=flux_TC$taux_CHOM1564_POP1564)

modele_dist_centre = lm(taux_CHOM1564_POP1564~euclidean_distance_centroid,data=flux_TC)
summary(modele_dist_centre)

# Pas de corrélation linéaire mais forte dépendance 
  #=> approximation par une regression adaptée aux données avec geom_smooth 

ggplot(data = flux_TC, aes(x = euclidean_distance_centroid, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  geom_smooth(method = NULL , se = TRUE) +  # Ajoute une ligne de régression linéaire
  theme_minimal() +  # Utilise un thème minimal pour le graphique
  labs(title = "Relation entre la distance au centre et le taux de chômage",
       x = "Distance Euclidienne au centre (m)",
       y = "Taux de Chômage")

## question centre périphérie : chomage zone rural et pauvre du centre 


# -------------------------------------------------------------------------------- # 

## Analyse de la corrélation entre le taux de chomage et : 
# - accessibilité à l'emploi selon le taux de passage de TC dans la commune
# - accessibilité à l'emploi selon le nombre d'arret de TC
# - accessibilité à l'emploi selon la fréquence de passage par habitant
# - le revenu



## Preparation des données 
VP_flux_duration_idf_chom_revenu = left_join(VP_flux_duration_idf_chom,data_revenus,by=c('CODGEO'))
VP_flux_duration_idf_chom_revenu$MED20 = as.numeric(VP_flux_duration_idf_chom_revenu$MED20,rm.na=T)
VP_flux_duration_idf_chom_revenu = na.omit(VP_flux_duration_idf_chom_revenu,subset=c('MED20'))


## Corrélation chômage/arrêt/fréquence de passage
frequences = read.csv('data/transports_idf/frequence_par_commune.csv')
arret = read.csv('data/transports_idf/stops_par_commune.csv')
frequences$CODGEO = as.character(frequences$CODGEO)
arret$CODGEO = as.character(arret$CODGEO)
df_pop_active$CODGEO = as.character(df_pop_active$CODGEO)
comm_pop_freq = left_join(df_pop_active,frequences,by=c('CODGEO'))
comm_pop_freq_arr = left_join(comm_pop_freq,arret,by=c('CODGEO'))

comm_pop_freq_arr$freq_par_hab = 
  comm_pop_freq_arr$arrival_time_num/
  comm_pop_freq_arr$P20_POP1564

ggscatter(comm_pop_freq_arr, x = "arrival_time_num", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Nombre de passages par jour", ylab = "taux de chomage par commune de départ")


VP_flux_duration_idf_chom_revenu_freq = left_join(VP_flux_duration_idf_chom_revenu,frequences,by=c('CODGEO'))
ggscatter(VP_flux_duration_idf_chom_revenu_freq, x = "arrival_time_num", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Arrêts par commune", ylab = "taux de chomage par commune de départ")

# normalisation par le nombre de communes 
VP_flux_duration_idf_chom_revenu_freq$freq_par_hab = 
  VP_flux_duration_idf_chom_revenu_freq$arrival_time_num/
  VP_flux_duration_idf_chom_revenu_freq$P20_POP1564


VP_flux_duration_idf_chom_revenu_freq_arr = left_join(VP_flux_duration_idf_chom_revenu_freq,arret,by=c('CODGEO'))
VP_flux_duration_idf_chom_revenu_freq_arr = filter(VP_flux_duration_idf_chom_revenu_freq_arr,CODGEO!='77291'&CODGEO!=95527&CODGEO!=91538)

ggscatter(VP_flux_duration_idf_chom_revenu_freq_arr, x = "freq_par_hab", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Fréquence de passage par habitant", ylab = "taux de chomage par commune de départ")

ggscatter(VP_flux_duration_idf_chom_revenu_freq_arr, x = "stop_id", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Nombre d'arrêts par commune", ylab = "taux de chomage par commune de départ")

ggscatter(VP_flux_duration_idf_chom_revenu_freq_arr, x = "stop_id", y = "MED20", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Nombre d'arrêts par commune", ylab = "Niveau de vie médian")

ggscatter(VP_flux_duration_idf_chom_revenu_freq_arr, x = "freq_par_hab", y = "MED20", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Nombre de passage par jour par habitant", ylab = "Niveau de vie médian")

## Revenu/chômage 

library("ggpubr")
ggscatter(VP_flux_duration_idf_chom_revenu, x = "MED20", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Revenu médian", ylab = "taux de chomage par commune de départ")
