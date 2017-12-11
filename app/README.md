# Interface graphique pour le projet AMAP

## Prérequis

### Python 3
La compatibilité avec python 2 est très hasardeuse...

### Tkinter
Il vous faut le module Tkinter dans votre configuration python (il est souvent présent de base)

### psycopg2
Module qui permet de communiquer avec PostgreSQL, il peut s'installer via `pip` ou avec le gestionnaire de paquets de votre distribution.

## Utilisation

### Lancement
Aller dans le dossier app et faire `python gui.py`

### Une fois lancé
C'est assez graphique, pour se connecter à la base de données, il faut utiliser des identifiants valides dans PostgreSQL et le nom donné à la base de données AMAP lorsque vous l'avez crée.