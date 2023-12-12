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


cities_w_arrondissement = cities_w_arrondissement.rename(columns={"INSEE_COM": "CODGEO"})
cities_w_arrondissement = cities_w_arrondissement.dropna(subset="CODGEO")
cities_w_arrondissement["CODGEO"] = cities_w_arrondissement["CODGEO"].astype(str)
flux_dep = pd.merge(cities_w_arrondissement,flux, how="inner",on="CODGEO")
cities_w_arrondissement = cities_w_arrondissement.rename(columns={"CODGEO": "DCLT"})
flux_arr = pd.merge(cities_w_arrondissement,flux, how="inner",on="DCLT")

def filtrer_par_insee(df, col_insee):
    # Les préfixes à filtrer
    prefixes = ["75", "77", "78", "91", "92", "93", "94", "95"]
    
    # Créer un masque pour filtrer les lignes
    mask = df[col_insee].astype(str).str.startswith(tuple(prefixes))
    
    # Filtrer le DataFrame
    df_filtre = df[mask]
    
    return df_filtre

# flux_idf_dep = filtrer_par_insee(flux, 'CODGEO')
# flux_idf_all = filtrer_par_insee(flux_idf_dep, 'DCLT')

# cities_w_arrondissement = cities_w_arrondissement.rename(columns={"INSEE_COM": "CODGEO"})
# flux_idf_all["CODGEO_int"] = pd.to_numeric(flux_idf_all["CODGEO"])

# cities_w_arrondissement = cities_w_arrondissement.dropna(subset="CODGEO")

# cities_w_arrondissement["CODGEO_int"] = cities_w_arrondissement["CODGEO"].astype(int)
