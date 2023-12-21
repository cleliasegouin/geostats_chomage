# Etude statistique de l'isolement géographique comme facteur du taux de chômage des communes en Île-de-France 

## Pré-traitements 

Les traitements sur les géométries de nos données ne pouvant pas être réalisés sur une console R en raison de problèmes de projection, nous les avons réalisé en python séparemment des prétraitements pour l'analyse des données.  

#### Partie flux domicile travail 
  Console Python 
1. Téléchargement des données sources, trop lourdes pour être sur le git.
données sources :
https://www.insee.fr/fr/statistiques/7632867?sommaire=7632977
3. Ajouter dans le dossier data un dossier vide nommé "output"
4. Lancement des fichier python geostats_flux.py afin de traiter les données géographiques, soit les données de flux domicile-travail pour les communes d'Île de France associées à une géométrie (temps de traitement assez long). Et lancement du fichier geostats_emploi afin d'obtenir les taux de chômage par commune en IDF.  
   Console R 
5. Lanchement du fichier python traitement_flux_dom_trav.R afin d'associer l'ensemble des flux aux taux de chomage et temps de trajet (en voiture et transport en commun) par commune d'arrivée. Prétraitement des flux car grosse base de donnée 

#### Partie transport en commun 
  Console Python 
1. Téléchargement des données sources avant le lancement du code :
données sources :
https://www.data.gouv.fr/fr/datasets/horaires-prevus-sur-les-lignes-de-transport-en-commun-dile-de-france-gtfs-datahub/
2. Lancement du fichier python pour traiter les données géographiques, soit les données de transports (fréquence et arrêt) en idf par commune

## Analyse 

Une fois les prétraitements lancés et les données prêtes, nous avons réalisé une analyse des différentes variables comme facteur du taux de chômage 

#### Cartographie de la Fréquence et arret 

Visualisation de nos données statistiques localisées dans le fichier Carto_transport_idf_commune.R

#### Taux de chomage et l'accessibilité à l'emploi

Analyse statistiques de nos variables en R dans le fichier data_analyse.R
