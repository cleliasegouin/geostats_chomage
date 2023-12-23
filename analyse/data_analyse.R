library(ggplot2)

# Import des données 
flux_TC = read.csv("data/output/flux_idf_TC_chomage.csv", sep=";")
flux_idf_TC_chomage <- read.csv('data/output/flux_idf_TC_chomage_depart.csv', sep = ';')
flux_idf_VP_chomage <- read.csv('data/output/flux_idf_VP_chomage_depart.csv', sep = ';')
data_revenus = read.csv('data/emploi/cc_filosofi_2020_COM.csv',sep=';')
data_revenus = select(data_revenus, CODGEO, MED20)
data_revenus$MED20 = as.double(data_revenus$MED20)
frequences = read.csv('data/transports_idf/frequence_par_commune.csv')
arret = read.csv('data/transports_idf/stops_par_commune.csv')
df_pop_active = read.csv2("data/output/pop_active.csv")

## Matrice de corrélation : 
## Indicateurs à comparer au taux de chômage : temps moyen en TC, temps moyen en VP, revenu,
## Nombre d'arrêts par commune, nombre de passages par communes, distance au centre
  
frequences$CODGEO = as.character(frequences$CODGEO)
arret$CODGEO = as.character(arret$CODGEO)
df_pop_active$CODGEO = as.character(df_pop_active$CODGEO)
comm_pop_freq = left_join(df_pop_active,frequences,by=c('CODGEO'))
comm_pop_freq_arr = left_join(comm_pop_freq,arret,by=c('CODGEO'))
comm_pop_freq_arr$P20_POP1564 = as.double(comm_pop_freq_arr$P20_POP1564)

comm_pop_freq_arr$freq_par_hab = 
  comm_pop_freq_arr$arrival_time_num/
  comm_pop_freq_arr$P20_POP1564
  
indicateurs_par_com = comm_pop_freq_arr

# Ajout du niveau de vie médian par commune 
indicateurs_par_com = left_join(indicateurs_par_com,data_revenus,by='CODGEO')
# Ajout du temps moyen en TC et de la distance à vol d'oiseau à la commune d'arrivée
flux_idf_TC_chomage$Group.1 = as.character(flux_idf_TC_chomage$Group.1)
flux_idf_TC_chomage$euclidean_distance_centroid <- gsub(",", ".", flux_idf_TC_chomage$euclidean_distance_centroid)
flux_idf_TC_chomage$euclidean_distance_centroid = as.double(flux_idf_TC_chomage$euclidean_distance_centroid)
flux_idf_TC_chomage$euclidean_distance <- gsub(",", ".", flux_idf_TC_chomage$euclidean_distance)
flux_idf_TC_chomage$euclidean_distance = as.double(flux_idf_TC_chomage$euclidean_distance)

# Temps de trajet moyen des habitants de chaque commune en transport en commun
flux_idf_TC_chomage$VAL <- gsub(",", ".", flux_idf_TC_chomage$VAL)
flux_idf_TC_chomage$VAL = as.double(flux_idf_TC_chomage$VAL)
flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P <- gsub(",", ".", flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P)
flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P = as.double(flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P)

flux_idf_TC_chomage$temps_moyen_TC_comm = 
  flux_idf_TC_chomage$VAL /
  flux_idf_TC_chomage$NBFLUX_C19_ACTOCC15P

indicateurs_par_com = left_join(indicateurs_par_com,select(flux_idf_TC_chomage,Group.1,temps_moyen_TC_comm,euclidean_distance_centroid,euclidean_distance),by=c('CODGEO'='Group.1'))

#Temps de trajet moyen des habitants par commune en véhicule privé
flux_idf_VP_chomage$MEAN_DURATION <- gsub(",", ".", flux_idf_VP_chomage$MEAN_DURATION)
flux_idf_VP_chomage$MEAN_DURATION = as.double(flux_idf_VP_chomage$MEAN_DURATION)
flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P <- gsub(",", ".", flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P)
flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P = as.double(flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P)

flux_idf_VP_chomage$temps_moyen_VP_comm = 
  flux_idf_VP_chomage$MEAN_DURATION /
  flux_idf_VP_chomage$NBFLUX_C19_ACTOCC15P


# Ajout du temps moyen en VP 
flux_idf_VP_chomage$Group.1 = as.character(flux_idf_VP_chomage$Group.1)
indicateurs_par_com = left_join(indicateurs_par_com,select(flux_idf_VP_chomage,Group.1,temps_moyen_VP_comm),by=c('CODGEO'='Group.1'))

nom_col = c('Taux chomage','Nombre de passage de TC par jour par habitant', "Nombre d'arrets par commune",'Niveau de vie median','Temps moyen en TC', 'Temps moyen en VP',"Distance au centre de la commune d'arrivee")
other_variables = cbind(as.double(indicateurs_par_com$taux_CHOM1564_POP1564),as.double(indicateurs_par_com$freq_par_hab),as.double(indicateurs_par_com$stop_id),as.double(indicateurs_par_com$MED20),as.double(indicateurs_par_com$temps_moyen_TC_comm),as.double(indicateurs_par_com$temps_moyen_VP_comm),as.double(indicateurs_par_com$euclidean_distance_centroid))
colnames(other_variables) = nom_col
corr_matrix = cor(other_variables,other_variables,use='complete.obs')  

write.csv2(corr_matrix,'data/output/correlation_matrix.csv')

## Taux de chômage par rapport à la distance des communes à Paris 
plot(indicateurs_par_com$euclidean_distance_centroid, 
      y = indicateurs_par_com$taux_CHOM1564_POP1564, 
      xlab = "Distance à vol d'oiseau par rapport à Paris (en m)", ylab = "Taux de chomage par commune de départ"
      )
mod = lm(taux_CHOM1564_POP1564~euclidean_distance_centroid,data=indicateurs_par_com)
summary(mod)
plot(indicateurs_par_com$euclidean_distance,
     y = indicateurs_par_com$taux_CHOM1564_POP1564, 
     xlab = "Distance à vol d'oiseau par rapport aux communes d'arrivée (en m)", ylab = "Taux de chomage par commune de départ"
    )
mod = lm(taux_CHOM1564_POP1564~euclidean_distance,data=indicateurs_par_com)
summary(mod)
# Suppression des valeurs NA
indicateurs_par_com_ech = na.omit(indicateurs_par_com,subset=c('euclidean_distance','taux_CHOM1564_POP1564'))
indicateurs_par_com_ech$taux_CHOM1564_POP1564 = as.double(indicateurs_par_com_ech$taux_CHOM1564_POP1564)
cor_chom_dist = cor(indicateurs_par_com_ech$euclidean_distance,
    y = indicateurs_par_com_ech$taux_CHOM1564_POP1564)

## Régression sur les log entre temps moyen en transports en commun et taux de chômage*
indicateurs_par_com$taux_CHOM1564_POP1564 = as.double(indicateurs_par_com$taux_CHOM1564_POP1564)
modele_temps_par_com_log = lm(log(taux_CHOM1564_POP1564)~log(temps_moyen_TC_comm),data=indicateurs_par_com)
summary(modele_temps_par_com_log)
  # supprimer les valeurs NA 
ech_indicateurs_par_com = na.omit(indicateurs_par_com,subste=c('taux_CHOM1564_POP1564','temps_moyen_TC_comm'))

coeff_corr = cor(log(ech_indicateurs_par_com$taux_CHOM1564_POP1564),log(ech_indicateurs_par_com$temps_moyen_TC_comm))

plot(x=log(indicateurs_par_com$temps_moyen_TC_comm),y=log(indicateurs_par_com$taux_CHOM1564_POP1564))
plot(log(taux_CHOM1564_POP1564)~log(temps_moyen_TC_comm),
     data=indicateurs_par_com,
     xlab= "log(Temps moyen en transport en commun par commune de départ)",
     ylab = "log(Taux de chômage par com de départ)")
abline(modele_temps_par_com_log)

mod = lm(taux_CHOM1564_POP1564~temps_moyen_TC_comm,data=indicateurs_par_com)
summary(mod)

## Régression sur les log entre temps moyen en VP et taux de chômage
modele_temps_VP_par_com_log = lm(log(taux_CHOM1564_POP1564)~log(temps_moyen_VP_comm),data=indicateurs_par_com)
summary(modele_temps_VP_par_com_log)
plot(x=log(indicateurs_par_com$temps_moyen_VP_comm),y=log(indicateurs_par_com$taux_CHOM1564_POP1564))
plot(log(taux_CHOM1564_POP1564)~log(temps_moyen_VP_comm),
     data=indicateurs_par_com,
     xlab= "log(Temps moyen en véhicule privé par commune de départ)",
     ylab = "log(Taux de chômage par com de départ)")
abline(modele_temps_VP_par_com_log)


## Régression entre fréquence de passage par communes et taux de chômage
modele_temps_arret_par_com = lm(taux_CHOM1564_POP1564~stop_id,data=na.omit(indicateurs_par_com,subset='stop_id'))
summary(modele_temps_arret_par_com)
plot(x=indicateurs_par_com$stop_id,y=indicateurs_par_com$taux_CHOM1564_POP1564)
plot(taux_CHOM1564_POP1564~stop_id,
     data=indicateurs_par_com,
     xlab= "Nombre d'arrêts",
     ylab = "Taux de chômage")
abline(modele_temps_arret_par_com)

## Régression entre revenu médian et taux de chômage
modele_revenu = lm(taux_CHOM1564_POP1564~MED20,data=indicateurs_par_com)
summary(modele_revenu)
plot(taux_CHOM1564_POP1564~MED20,
     data=indicateurs_par_com,
     xlab= "Revenu médian",
     ylab = "Taux de chômage")
abline(modele_revenu)

# Pas de corrélation linéaire mais forte dépendance 
#=> approximation par une regression adaptée aux données avec geom_smooth 
ggplot(data = indicateurs_par_com, aes(x = temps_moyen_TC_comm, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  geom_smooth(method = NULL , se = TRUE) +  # Ajoute une ligne de régression linéaire
  theme_minimal() +  # Utilise un thème minimal pour le graphique
  labs(title = "Relation entre le temps de trajet moyen en TC et le taux de chômage",
       x = "Temps de trajet moyen en TC (minutes)",
       y = "Taux de Chômage")

## Même chose pour le temps de trajet en VP
# Pas de corrélation linéaire mais forte dépendance 
#=> approximation par une regression adaptée aux données avec geom_smooth 
ggplot(data = indicateurs_par_com, aes(x = temps_moyen_VP_comm, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  geom_smooth(method = NULL , se = TRUE) +  # Ajoute une ligne de régression linéaire
  theme_minimal() +  # Utilise un thème minimal pour le graphique
  labs(title = "Relation entre le temps de trajet moyen en véhicule privé et le taux de chômage",
       x = "Temps de trajet moyen en véhicule privé (minutes)",
       y = "Taux de Chômage")

