temps_flux = readRDS("./data/flux_dom_trav/listtimes.Rds")

## DOCUMENTATION : MODE mode de transport 
## (DOMICILE: pas de mobilité ; 
## NM: non motorise = velo ou marche a pied ; 
## TC : transports en commun ; 
## VP : véhicule privé = voiture )

temps_TC = temps_flux$TC

temps_VPM = temps_flux$VPM

temps_VPS = temps_flux$VPS

temps_dist = temps_flux$DIST

flux_temps = cbind(temps_TC, temps_VPM, temps_VPS, temps_dist)


df_pop_active = read.csv("./data/emploi/pop_active.csv",sep=";")

## Corrélation entre chômage et accessibilité de l’emploi en temps de trajet

# Trajet TC : 

df_chom_access = df_pop_active[df_pop_active$CODGEO, df_pop_active$P20_CHOM1564, df_pop_active$taux_CHOM1564_POP1564]




