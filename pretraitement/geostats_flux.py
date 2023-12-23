# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 16:49:06 2023

@author: josep
"""


import pandas as pd 
import geopandas as gpd 
import numpy as np
import plotly.graph_objects as go
import plotly.express as px
import os

## Changer de répertoire de travail 
os.chdir("C:/Users/steph/OneDrive/Bureau/ENSG/ING3/DESIGEO/Analyse spatiale/projet_v3/geostats_chomage")

##Import données communes (et arrondissement de Paris)
arrondissement = gpd.read_file("./data/communes_arrondissements/arrondissements.shp")
cities = gpd.read_file("./data/communes_arrondissements/COMMUNE.shp")

# On garde les communes d'IDF
cities_idf = cities[cities["INSEE_REG"]=="11"]

# Ajout des arrondissement de Paris 
    # On supprime l'entité "Paris"
cities_idf = cities_idf[cities_idf["INSEE_COM"]!= "75056"]

    # Préparation de la concaténation
arrondissement = arrondissement.to_crs(2154)
cities_idf = cities_idf.to_crs(2154)
arrondissement = arrondissement.rename(columns={"c_arinsee": "INSEE_COM"})

cities_w_arrondissement = pd.concat([cities_idf, arrondissement],ignore_index=True)


## Import des données de flux de mobilités : 
    
flux = pd.read_csv("./data/flux_dom_trav/base-flux-mobilite-domicile-lieu-travail-2019.csv",sep=';',
                   dtype = {'CODGEO': str, 'LIBGEO': str, 'DCLT': str,'L_DCLT':str,'NBFLUX_C198ACTOCC15O':np.float64})

flux.reset_index(inplace=True)

# Optionally, you can rename the new index column
flux.rename(columns={'index': 'id'}, inplace=True)

cities_w_arrondissement = cities_w_arrondissement.rename(columns={"INSEE_COM": "CODGEO"})
cities_w_arrondissement = cities_w_arrondissement.dropna(subset="CODGEO")
cities_w_arrondissement["CODGEO"] = cities_w_arrondissement["CODGEO"].astype(str)


## Jointure des flux et des communes d'IDF 
flux_dep_join = pd.merge(flux,cities_w_arrondissement.add_prefix('dep_'), left_on='CODGEO',right_on='dep_CODGEO', how="left")

cities_w_arrondissement = cities_w_arrondissement.rename(columns={"CODGEO": "DCLT"})
flux_all_join = pd.merge(flux_dep_join, cities_w_arrondissement.add_prefix('arr_'),left_on='DCLT',right_on='arr_DCLT', how="left")

flux_all_join = flux_all_join.dropna(subset=["CODGEO","DCLT","dep_CODGEO","arr_DCLT"])
flux_all_join = gpd.GeoDataFrame(flux_all_join, geometry='arr_geometry')


## Calcul des centroïdes des polygones 

# Assurer que les colonnes de géométrie sont des GeoSeries
flux_all_join['dep_geometry'] = gpd.GeoSeries(flux_all_join['dep_geometry'])
flux_all_join['arr_geometry'] = gpd.GeoSeries(flux_all_join['arr_geometry'])

# Calcul des centroïdes pour les géométries de départ et d'arrivée
flux_all_join['centroid_dep'] = flux_all_join['dep_geometry'].centroid
flux_all_join['centroid_arr'] = flux_all_join['arr_geometry'].centroid

# Calcul de la distance euclidienne entre les centroïdes
flux_all_join['euclidean_distance'] = flux_all_join.apply(lambda row: row['centroid_dep'].distance(row['centroid_arr']), axis=1)
 

paris = cities[cities["INSEE_COM"] == "75056"]

paris["centroid"] = paris['geometry'].centroid

flux_all_join['euclidean_distance_centroid'] = flux_all_join.apply(lambda row: row['centroid_dep'].distance(paris["centroid"]), axis=1)

flux_all_join_filtered = flux_all_join[["id","CODGEO","LIBGEO","DCLT","L_DCLT","NBFLUX_C19_ACTOCC15P","dep_geometry","arr_geometry","euclidean_distance","euclidean_distance_centroid"]]


flux_all_join_filtered.to_csv("./data/output/flux_idf_distance.csv",sep=";")
