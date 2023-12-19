library(sf)
library(dplyr)

# Import des données 
VP_flux_duration_idf_chom = read.csv("data/flux_dom_trav/flux_idf_VP_chomage.csv")
VP_flux_duration_idf_chom$CODGEO = as.character(VP_flux_duration_idf_chom$CODGEO)

### Inégalités d'accès aux TC - courbe de lorenz et coefficient de Gini 
#install.packages('ineq')
library(ineq)
lorenz = Lc(x=TC_flux_duration_idf_chom$VAL,n=TC_flux_duration_idf_chom$NBFLUX_C19_ACTOCC15P,plot=TRUE)
Gini(TC_flux_duration_idf_chom$VAL, corr = FALSE, na.rm = TRUE)

data_revenus = read.csv('data/emploi/cc_filosofi_2020_COM.csv',sep=';')
data_revenus = select(data_revenus, CODGEO, MED20)
VP_flux_duration_idf_chom_revenu = left_join(VP_flux_duration_idf_chom,data_revenus,by=c('CODGEO'))
VP_flux_duration_idf_chom_revenu$MED20 = as.numeric(VP_flux_duration_idf_chom_revenu$MED20,rm.na=T)
VP_flux_duration_idf_chom_revenu = na.omit(VP_flux_duration_idf_chom_revenu,subset=c('MED20'))

## Revenu/chômage 
library("ggpubr")
ggscatter(VP_flux_duration_idf_chom_revenu, x = "MED20", y = "taux_CHOM1564_POP1564", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Revenu médian", ylab = "taux de chomage par commune de départ")

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

