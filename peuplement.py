from io import *
import random

### Options ###
N_ADDRESS = 10
N_PRODUCER = 3
N_CONTRACTS = 8
N_FOYER = 10
N_CLIENTS = 2
#...
###############

cities = {
    'France' : ['Paris', 'Bordeaux', 'Lyon', 'Metz', 'Lille', 'Marseille'],
    'Österreich' : ['Wien', 'Salzburg'],
    'Deutschland' : ['Berlin', 'München', 'Frankfurt', 'Stuttgart'],
    'Italia' : ['Roma', 'Pisa', 'Frienze', 'Gennova', 'Milano', 'Napoli'],
    'Espana' : ['Barcelona', 'Madrid', '']
    }

countries = list(cities.keys())

streets = ['rue de la pizza', 'avenue des iris', 'rue des paquerettes', 'boulevard du saucisson', 'rue du hamburger', 'avenue des lilas', 'impasse des ibiscus', 'boulevard du chocolat', 'rue des myosotis', 'avenue de la glycine']

comment_block_separator = '-- ==================================================\n'
def comment_block(str) :
    res = comment_block_separator
    for line in str.splitlines() :
        res += '-- ' + line + '\n'
    return res + comment_block_separator 

addr_id = 1
def random_address() :
    global addr_id
    id = str(addr_id)
    addr_id += 1
    country = str(random.choice(countries))
    city = str(random.choice(cities[country]))
    street = str(random.choice(streets))
    zipcode = str(random.randrange(10000, 98000, 10))
    number = str(random.randrange(1, 99, 1))
    return 'INSERT INTO adresse VALUES (' + id + ' , \'' + country + '\', \'' + city + '\', \'' + zipcode + '\', \'' + number + '\', \'' + street + '\');\n' 


producer_id = 1
def random_producer() :
    global producer_id
    #TODO : le reste

# Main part of the program
with open('peuplement.sql', 'wt') as f :
    N_ADDRESS
    f.write(comment_block('Fichier généré par peuplement.py avec amour\nArsène'))
    f.write('\n\n')

    f.write('-- Tables définies par des couples/triplets de clefs étrangères\n')
    f.write('DELETE FROM prevision_calendrier;\n')
    f.write('DELETE FROM souscrire_a;\n')
    f.write('DELETE FROM contenir;\n')
    f.write('DELETE FROM appartenir_a;\n\n')
    
    f.write('-- Tables référencées par les tables précédentes\n')
    f.write('DELETE FROM denree;\n')
    f.write('DELETE FROM panier;\n')
    f.write('DELETE FROM livraison;\n')
    f.write('DELETE FROM clien;\n')
    f.write('DELETE FROM foyer;\n')
    f.write('DELETE FROM contrat;\n')
    f.write('DELETE FROM producteur;\n')
    f.write('DELETE FROM adresse;\n\n')

    f.write('commit;\n')
    
    f.write('\n\n')
    
    f.write(comment_block('Création des données\n'))
    f.write('-- # Adresses\n')
    for i in range(N_ADDRESS) :
        f.write(random_address())

    f.write('commit;\n\n')
