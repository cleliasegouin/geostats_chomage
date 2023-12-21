library(sf)
library(dplyr)

# Import des données 
temps_flux = readRDS('data/flux_dom_trav/listtimes.Rds')

flux = read.csv('data/output/flux_idf_distance.csv',sep=";")
flux = select(flux, id,CODGEO,LIBGEO,DCLT,L_DCLT,NBFLUX_C19_ACTOCC15P,dep_geometry,arr_geometry,euclidean_distance,euclidean_distance_centroid)
flux$CODGEO = as.character(flux$CODGEO)
flux$DCLT = as.character(flux$DCLT)


df_pop_active = read.csv("./data/output/pop_active.csv",sep=";")
df_pop_chom = select(df_pop_active, CODGEO, P20_CHOM1564, taux_CHOM1564_POP1564, P20_POP1564)
df_pop_chom$CODGEO = as.character(df_pop_chom$CODGEO)

# Tableau des flux pour les temps de trajets en TC 
temps_TC = temps_flux$TC
temps_TC = temps_TC %>%  rename(CODGEO=ORI,DCLT=DES)
TC_flux_duration = left_join(x=flux,y=temps_TC,by=c('CODGEO','DCLT'))
TC_flux_duration_idf = TC_flux_duration[complete.cases(TC_flux_duration$VAL),]

    # Ajout des données taux de chômage, pop active de la commune de départ
TC_flux_duration_idf_chom = left_join(TC_flux_duration_idf, df_pop_chom, by = c('CODGEO'))


    # Regroupement des données par commune d'arrivées et selon le type d'aggregation 
TC_flux_grouped_com_1 = aggregate(select(TC_flux_duration_idf_chom,taux_CHOM1564_POP1564,P20_CHOM1564,P20_POP1564, euclidean_distance,euclidean_distance_centroid ), by=list(TC_flux_duration_idf_chom$DCLT), FUN=mean)
TC_flux_grouped_com_2 = aggregate(select(TC_flux_duration_idf_chom, VAL, NBFLUX_C19_ACTOCC15P), by = list(TC_flux_duration_idf_chom$DCLT), FUN=sum)

TC_flux_grouped_com = cbind(TC_flux_grouped_com_1, TC_flux_grouped_com_2)
TC_flux_grouped_com <- TC_flux_grouped_com[, !duplicated(colnames(TC_flux_grouped_com))]

TC_flux_grouped_filtered <- TC_flux_grouped_com %>% filter(euclidean_distance != 0)

write.csv2(TC_flux_grouped_filtered, "data/output/flux_idf_TC_chomage.csv")

  # Regroupement des données par commune de départ et selon le type d'aggregation 
TC_flux_grouped_com_dep_1 = aggregate(select(TC_flux_duration_idf_chom,taux_CHOM1564_POP1564,P20_CHOM1564,P20_POP1564, euclidean_distance,euclidean_distance_centroid ), by=list(TC_flux_duration_idf_chom$CODGEO), FUN=mean)
TC_flux_grouped_com_dep_2 = aggregate(select(TC_flux_duration_idf_chom, VAL, NBFLUX_C19_ACTOCC15P), by = list(TC_flux_duration_idf_chom$CODGEO), FUN=sum)

TC_flux_grouped_com_dep = cbind(TC_flux_grouped_com_dep_1, TC_flux_grouped_com_dep_2)
TC_flux_grouped_com_dep <- TC_flux_grouped_com_dep[, !duplicated(colnames(TC_flux_grouped_com_dep))]

TC_flux_grouped_dep_filtered <- TC_flux_grouped_com_dep %>% filter(euclidean_distance != 0)

write.csv2(TC_flux_grouped_filtered, "data/output/flux_idf_TC_chomage_depart.csv")

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

write.csv2(VP_flux_duration_idf_chom, "data/output/flux_idf_VP_chomage.csv")

# Regroupement des données par commune de départ pour les véhicules privés et selon le type d'aggregation 
VP_flux_grouped_com_dep_1 = aggregate(select(VP_flux_duration_idf_chom,taux_CHOM1564_POP1564,P20_CHOM1564,P20_POP1564, euclidean_distance,euclidean_distance_centroid ), by=list(TC_flux_duration_idf_chom$CODGEO), FUN=mean)
VP_flux_grouped_com_dep_2 = aggregate(select(VP_flux_duration_idf_chom, MEAN_DURATION, NBFLUX_C19_ACTOCC15P), by = list(TC_flux_duration_idf_chom$CODGEO), FUN=sum)

VP_flux_grouped_com_dep = cbind(VP_flux_grouped_com_dep_1, VP_flux_grouped_com_dep_2)
VP_flux_grouped_com_dep <- VP_flux_grouped_com_dep[, !duplicated(colnames(VP_flux_grouped_com_dep))]

VP_flux_grouped_dep_filtered <- VP_flux_grouped_com_dep %>% filter(euclidean_distance != 0)

write.csv2(VP_flux_grouped_dep_filtered, "data/output/flux_idf_VP_chomage_depart.csv")
