# étude statistique de l'isolement géographique comme facteur du taux de chomâge des communes en Île-de-France 

## Pré-traitements 

Les traitements sur les géométries de nos données ne pouvant pas être réalisés sur une console R en raison de problèmes de projection, nous les avons réalisé en python séparemment des prétraitements pour l'analyse des données.  

#### Partie flux domicile travail 
  Console Python 
1. Lancement du fichier python geostats_flux.py afin de traiter les données géographiques, soit les données de flux domicile-travail pour les communes d'Île de France associées à une géométrie (temps de traitement assez long)
   Console R 
3. Lanchement du fichier python traitement_flux_dom_trav.R afin d'associer l'ensemble des flux aux taux de chomage et temps de trajet (en voiture et transport en commun) par commune d'arrivée. Prétraitement des flux car grosse base de donnée 

#### Partie transport en commun 
  Console Python 
1. Lancement du fichier python pour traiter les données géographiques, soit les données de transports (fréquence et arrêt) en idf par commune

## Analyse 

Une fois les prétraitements lancés et les données prêtes, nous avons réalisé une analyse des différentes variables comme facteur du taux de chômage 

un peu bordel sur les données => si on divise il faut le diviser par theme 

#### Taux de chomage et l'accessibilité à l'emploi en terme de temps de trajet et distance 
=> rajouter étude des temps de transport en voiture dans TC_flux_dom_trav

peut etre coupler corrélation / analyse temps de trajet avec freq et arret  => à ce moment là prétraitement R des jointures etc 

#### Revenu et chomage 
VP_flux_dom_trav.R

#### Cartographie de la Fréquence et arret 
transport_idf_commune.R







