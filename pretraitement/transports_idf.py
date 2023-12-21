# -*- coding: utf-8 -*-
"""
Created on Mon Dec 18 12:07:31 2023

@author: julie
"""

import geopandas as gpd
import pandas as pd
import os 

## Changer de répertoire de travail 
os.chdir("C:/Users/josep/OneDrive/Documents/ENSG/geodatascience/geostats_chomage")

# 1. Import des fichiers

##Fichiers à télécharger 
stops = pd.read_csv('data/transports_idf/stops.txt')
stop_times = pd.read_csv('data/transports_idf/stop_times.txt')
communes = gpd.read_file('data/communes_arrondissements/cities_arr.shp')

# 2. Conversion des fichiers en GeoDataFrame
communes_spatial = gpd.GeoDataFrame(data = communes, geometry='geometry')

# 3. Agrégation sur les arrêts pour avoir le nombre de passages par arrêt
# 3.1. Création d'une table simplifié depuis stop_times
stop_times.insert(loc = 10, column = 'arrival_time_num', value = 1)
# 3.2 Calcul de l'agrégation
frequence_par_arret = stop_times.groupby(by=["stop_id"]).sum()

# 4. Jointure de la table des fréquences sur les arrêts
stops = stops.join(other = frequence_par_arret, on = 'stop_id', how = 'left')

# 5. Jointure spatiale sur les communes
# 5.1 Formatage et reprojection
stops_spatial = gpd.GeoDataFrame(data = stops, geometry = gpd.points_from_xy(x = stops.stop_lon, y = stops.stop_lat),crs = 4326)
stops_spatial = stops_spatial.to_crs(2154)
# 5.2 Jointure spatiale
jointure = gpd.sjoin(left_df= stops_spatial, right_df = communes, how = 'left', predicate = 'within')
# 5.3 Fréquence par commune et arrêts par commune
frequence_par_commune = jointure.groupby(by=["CODGEO"])['arrival_time_num'].sum()
stops_par_commune = jointure.groupby(by=["CODGEO"])['stop_id'].count()

# 6. Export des résultats
frequence_par_commune = pd.DataFrame(data = frequence_par_commune)
stops_par_commune = pd.DataFrame(data = stops_par_commune)
frequence_par_commune.to_csv('data/output/frequence_par_commune.csv')
stops_par_commune.to_csv('data/output/stops_par_commune.csv')

