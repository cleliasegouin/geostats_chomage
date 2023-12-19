flux_TC = read.csv("data/flux_dom_trav/flux_idf_tc_chomage.csv", sep=";")

# Corrélation entre chômage et accessibilité de l’emploi en temps de trajet

# Temps pondéré par nombre d’emplois à destination 
# plot des variables 
flux_TC$temps_par_emploi = flux_TC$VAL / flux_TC$NBFLUX_C19_ACTOCC15P 
plot(x=flux_TC$temps_par_emploi,y=flux_TC$taux_CHOM1564_POP1564)

#modele linéaire avec le temps pondéré par le nombre d'emploi pour expliquer le taux de chomage
modele_temps_par_emploi = lm(taux_CHOM1564_POP1564~temps_par_emploi, data = flux_TC)
summary(modele_temps_par_emploi)

modele_temps_par_emploi_log = lm(log(taux_CHOM1564_POP1564)~log(temps_par_emploi),data=flux_TC)
summary(modele_temps_par_emploi_log)
plot(x=log(flux_TC$temps_par_emploi),y=log(flux_TC$taux_CHOM1564_POP1564))


## A FAIRE 
# Temps pondéré par la population habitant dans la commune de départ
# plot des variables 
flux_TC$temps_par_pop = flux_TC$VAL / flux_TC$P20_POP1564
plot(x=flux_TC$temps_par_pop,y=flux_TC$taux_CHOM1564_POP1564)

## suppréssion des valeurs à 0? 
modele_temps_par_pop = lm(taux_CHOM1564_POP1564 ~temps_par_pop, data = flux_TC)
summary(modele_temps_par_pop)

modele_temps_par_pop_log = lm(log(taux_CHOM1564_POP1564)~log(temps_par_pop),data=flux_TC)
summary(modele_temps_par_pop_log)
plot(x=log(flux_TC$temps_par_pop),y=log(flux_TC$taux_CHOM1564_POP1564))


# Corrélation entre chômage et accessibilité des communes en distance

# fitter un modele avec la distance uniquement pour expliquer le taux de chomage)
modele_dist = lm(log(taux_CHOM1564_POP1564)~log(euclidean_distance),data=flux_TC)
summary(modele_simple_dist)

# -> distance et temps en minute
modele_dist_temps = lm(taux_CHOM1564_POP1564~euclidean_distance+VAL,data=flux_TC)
summary(modele_dist_temps)


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



