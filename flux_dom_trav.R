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

#install.packages('ineq')
#library(ineq)
#lorenz = Lc(x=df_joint$VAL,plot=TRUE)
