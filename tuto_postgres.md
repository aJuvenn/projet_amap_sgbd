# Tutoriel pour la mise en place de PostgreSQL

## Installation sur linux

 1. Installe postgres avec ton package manager préféré (pacman, aptitude...)
 2. Connecte-toi en tant qu'utilisateur postgres `sudo -u postgres -i`
 3. Initialise le cluster de bases de données :
 ```initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data'```
 _NB : tu peux changer l'encodage UTF8 si tu veux. Changer la racine est plus relou..._ 
 4. Démarre le service `postgresql.service` avec `systemctl start postgresql.service`. Tu peux faire `systemctl enable postgresql.service` si tu veux que le service démarre tout seul au démarrage de l'ordinateur.

## Installation ailleurs

Je sais pas

## Créer un utilisateur et une base de données

### Créer un utilisateur
En tant qu'utilisateur postgres, fais `createuser --interactive` et indique à postgres que tu crées un admin. Mettre son identifiant sur la machine facilite le choses plus tard.

### Créer une base de données
Pour créer une base de données `amap`, effectuer la commande `createdb amap`

## Prise en main

Le shell interactif `psql` est similaire 