library(sf)
library(dplyr)

# Import des données 
temps_flux = readRDS('data/flux_dom_trav/listtimes.Rds')
flux = read.csv('data/flux_dom_trav/base-flux-mobilite-domicile-lieu-travail-2019.csv',sep=';')
df_pop_active = read.csv("./data/emploi/pop_active.csv",sep=";")
df_pop_chom = select(df_pop_active, CODGEO, P20_CHOM1564, taux_CHOM1564_POP1564)
df_pop_chom$CODGEO = as.character(df_pop_chom$CODGEO)

# Tableau des flux pour les temps de trajets en TC 
temps_TC = temps_flux$TC
temps_TC = temps_TC %>%  rename(CODGEO=ORI,DCLT=DES)
TC_flux_duration = left_join(x=flux,y=temps_TC,by=c('CODGEO','DCLT'))
TC_flux_duration_idf = TC_flux_duration[complete.cases(TC_flux_duration$VAL),]

# Ajout des données taux de chômage, pop active de la commune de départ
TC_flux_duration_idf_chom = left_join(TC_flux_duration_idf, df_pop_chom, by = c('CODGEO'))

# Tableau des flux pour les temps de trajets en voiture
temps_vpm = temps_flux$VPM
temps_vps = temps_flux$VPS
temps_vp = left_join(x=temps_vpm,y=temps_vps,by=c('ORI','DES'))
temps_vp$MEAN_DURATION = (temps_vp$VAL.x+temps_vp$VAL.y)/2
temps_vp = select(temps_vp,ORI,DES,MEAN_DURATION)
temps_vp = temps_vp %>%  rename(CODGEO=ORI,DCLT=DES)
VP_flux_duration = left_join(x=flux,y=temps_vp,by=c('CODGEO','DCLT'))
VP_flux_duration_idf = VP_flux_duration[complete.cases(VP_flux_duration$MEAN_DURATION),]

# Ajout des données de chômage de la commune de départ 
VP_flux_duration_idf_chom = left_join(VP_flux_duration_idf, df_pop_chom, by = c('CODGEO'))

# PLOT 
# plot(TC_flux_duration_idf_chom$NBFLUX_C19_ACTOCC15P,TC_flux_duration_idf_chom$taux_CHOM1564_POP1564)


### Inégalités d'accès aux TC - courbe de lorenz et coefficient de Gini 
#install.packages('ineq')
library(ineq)
lorenz = Lc(x=TC_flux_duration_idf_chom$VAL,n=TC_flux_duration_idf_chom$NBFLUX_C19_ACTOCC15P,plot=TRUE)
Gini(TC_flux_duration_idf_chom$VAL, corr = FALSE, na.rm = TRUE)


