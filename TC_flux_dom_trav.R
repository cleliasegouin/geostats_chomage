# Import des données 
flux_TC = read.csv("data/flux_dom_trav/flux_idf_tc_chomage.csv", sep=";")

# Corrélation entre chômage et accessibilité de l’emploi en temps de trajet

# Temps pondéré par nombre d’emplois à destination 
# plot des variables 
flux_TC$temps_par_emploi = flux_TC$VAL / as.numeric(flux_TC$NBFLUX_C19_ACTOCC15P) 
plot(x=flux_TC$temps_par_emploi,y=flux_TC$taux_CHOM1564_POP1564)

#modele linéaire avec le temps pondéré par le nombre d'emploi pour expliquer le taux de chomage
modele_temps_par_emploi = lm(taux_CHOM1564_POP1564~temps_par_emploi, data = flux_TC)
summary(modele_temps_par_emploi)

modele_temps_par_emploi_log = lm(log(taux_CHOM1564_POP1564)~log(temps_par_emploi),data=flux_TC)
summary(modele_temps_par_emploi_log)
plot(x=log(flux_TC$temps_par_emploi),y=log(flux_TC$taux_CHOM1564_POP1564))


# Corrélation entre chômage et accessibilité des communes en distance

# fitter un modele avec la distance uniquement pour expliquer le taux de chomage
modele_dist = lm(log(taux_CHOM1564_POP1564)~log(euclidean_distance),data=flux_TC)
summary(modele_dist)

# -> distance et temps en minute
modele_dist_temps = lm(taux_CHOM1564_POP1564~euclidean_distance+VAL,data=flux_TC)
summary(modele_dist_temps)

plot(x=flux_TC$euclidean_distance,y=flux_TC$taux_CHOM1564_POP1564)
## Pas de corrélation linéaire mais forte dépendance => approximation par distribution données  
library(ggplot2)

ggplot(data = flux_TC, aes(x = euclidean_distance, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  geom_smooth(method = NULL , se = TRUE) +  # Ajoute une ligne de régression linéaire
  theme_minimal() +  # Utilise un thème minimal pour le graphique
  labs(title = "Relation entre la distance euclidienne et le taux de chômage",
       x = "Distance Euclidienne",
       y = "Taux de Chômage")


#ggplots => geomsmooth regression adaptée aux données 
#distance au centre de paris question centre périphérie : chomage zone rural et pauvre du centre 
#gwr : geographical weighted regression comme ouverture 
#ACP + matrice de corrélation 


#### Reprise des données : 

# Analyse graphique : 
    # Diagramme de dispersion
ggplot(flux_TC, aes(x = euclidean_distance, y = taux_CHOM1564_POP1564)) +
  geom_point() +
  theme_minimal()

    # Pour une transformation logarithmique
ggplot(flux_TC, aes(x = log(euclidean_distance), y = log(taux_CHOM1564_POP1564))) +
  geom_point() +
  theme_minimal()

# Analyse de la corrélation :
    #pour nos données brutes 
cor(flux_TC$euclidean_distance, flux_TC$taux_CHOM1564_POP1564, method = "pearson")

    #pour nos données log
cor(log(flux_TC$euclidean_distance), log(flux_TC$taux_CHOM1564_POP1564), method = "pearson")

# Modélisation statistique : 
library(lmtest)

# Modèle linéaire
modele_lin = lm(taux_CHOM1564_POP1564 ~ euclidean_distance, data = flux_TC)

# Modèle logarithmique
modele_log = lm(log(taux_CHOM1564_POP1564) ~ log(euclidean_distance), data = flux_TC)

# Comparaison des modèles
summary(modele_lin)
summary(modele_log)

# Analyse des résidus
plot(residuals(modele_lin))

# Affichage graphique :
ggplot(flux_TC, aes(x = log(euclidean_distance), y = log(taux_CHOM1564_POP1564))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()



