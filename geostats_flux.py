# -*- coding: utf-8 -*-
"""
Created on Tue Dec 12 15:50:32 2023

@author: josep
"""

import pandas as pd 
import geopandas as gpd 
import numpy as np

##Import données commune 

arrondissement = gpd.read_file("C:/Users/josep/OneDrive/Documents/ENSG/geodatascience/geostats/communes/arrondissements.shp")
cities = gpd.read_file("C:/Users/josep/OneDrive/Documents/ENSG/geodatascience/geostats/communes/COMMUNE.shp")

# On garde les communes d'IDF
cities_idf = cities[cities["INSEE_REG"]=="11"]

# On supprime l'entité "Paris"
cities_idf = cities_idf[cities_idf["INSEE_COM"]!= "75056"]

# Préparation de la concaténation
arrondissement = arrondissement.to_crs(2154)
cities_idf = cities_idf.to_crs(2154)

cities_w_arrondissement = pd.concat([cities_idf, arrondissement],ignore_index=True)


## Import des données de flux de mobilités : 
    
flux = pd.read_csv("C:/Users/josep/OneDrive/Documents/ENSG/geodatascience/geostats/traj_dom_travail/base-flux-mobilite-domicile-lieu-travail-2019.csv",sep=';',
                   dtype = {'CODGEO': str, 'LIBGEO': str, 'DCLT': str,'L_DCLT':str,'NBFLUX_C198ACTOCC15O':np.float64})

flux.reset_index(inplace=True)

# Optionally, you can rename the new index column
flux.rename(columns={'index': 'id'}, inplace=True)

cities_w_arrondissement = cities_w_arrondissement.rename(columns={"INSEE_COM": "CODGEO"})
cities_w_arrondissement = cities_w_arrondissement.dropna(subset="CODGEO")
cities_w_arrondissement["CODGEO"] = cities_w_arrondissement["CODGEO"].astype(str)


##Jointure des flux et communes d'IDF
flux_dep = pd.merge(cities_w_arrondissement,flux, how="inner",on="CODGEO")

cities_w_arrondissement = cities_w_arrondissement.rename(columns={"CODGEO": "DCLT"})
flux_arr = pd.merge(cities_w_arrondissement,flux, how="inner",on="DCLT")

## Calcul des centroïdes des polygones 
flux_dep["centroid"] = flux_dep["geometry"].centroid
flux_arr["centroid"] = flux_arr["geometry"].centroid

flux_dep["lat"] = flux_dep["centroid"].y
flux_dep["lon"] = flux_dep["centroid"].x

flux_arr["lat"] = flux_arr["centroid"].y
flux_arr["lon"] = flux_arr["centroid"].x


