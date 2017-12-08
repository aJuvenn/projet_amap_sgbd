#-*- coding: utf-8 -*-
from io import *
import random

### Options ###
N_ADDRESSES = 15 # Doit etre plus grand que le nombre de foyers/clients...
N_PRODUCERS = 2
N_FOYERS = 3
N_CLIENTS = 10
N_CONTRACTS = 5

###############

### ADRESSES
cities = {
    'France' : ['Paris', 'Bordeaux', 'Lyon', 'Metz', 'Lille', 'Marseille', 'Nantes', 'Rennes', 'Toulouse', 'Reims', 'Grenoble', 'Nice'],
    'Österreich' : ['Wien', 'Salzburg', 'Innsbrück', 'Graz'],
    'Deutschland' : ['Berlin', 'München', 'Frankfurt', 'Stuttgart', 'Düsseldorf', 'Nürnberg', 'Hamburg'],
    'Italia' : ['Roma', 'Pisa', 'Frienze', 'Gennova', 'Milano', 'Napoli', 'Palermo'],
    'Espana' : ['Barcelona', 'Madrid', 'Malaga', 'Valencià'],
    'United Kingdom' : ['London', 'Exeter', 'Cambridge', 'Brimingham', 'Manchester', 'Liverpool'],
    'Suisse' : ['Bern', 'Lausanne', 'Genève']
    }

countries = list(cities.keys())

streets = ['rue de la pizza', 'avenue des iris', 'rue des paquerettes', 'boulevard du saucisson', 'rue du hamburger', 'avenue des lilas', 'impasse des ibiscus', 'boulevard du chocolat', 'rue des myosotis', 'avenue de la glycine', 'chemin du bouton d or', 'passage des paninis', 'allée du ketchup', 'voie du kebab', 'parc des hortensias', 'avenue de la frite', 'rue de la blanquette']


### NOMS
names = [('Ray','Defesse'), ('Jerry','Kan'), ('Juda','Bricot'), ('Jean','Bon'), ('Axel','Aire'), ('Vic','Tim'), ('Alain','Proviste'), ('Paul','Aroide'), ('Denis','Chon'), ('Kelly','Diote'), ('Igor','Gonzola'), ('Yves','Remord'), ('Armand','Chabalais'), ('Ali','Gator'), ('Alain','Térieur'), ('Alex','Térieur'), ('Bart','Habba'), ('Cécile','Hon'), ('Céline','Évitable'), ('Clément','Tine'), ('Élie','Coptère'), ('Élise','Émoi'), ('Jean','Registre'), ('Jeff','Hun'), ('Karl','Hage'), ('Laure','Dure'), ('Marie', 'Tim'), ('Maude', 'Errateur'), ('Lydie', 'Commandements'), ('Nicolas', 'Niorangina'), ('Omer', 'Dalors'), ('Pat', 'Réloin'), ('Paul', 'Hochon'), ('Pit', 'Za'), ('Rob', 'Otique'), ('Roland', 'Culé'), ('Richard', 'Dasso'), ('Sacha', 'Hutte'), ('Sacha', 'Touille'), ('Sam', 'Lécasse'), ('Samantha', 'Lo'), ('Sandra', 'Nicouverture'), ('Sandy', 'Kilo'), ('Sarah', 'Croche'), ('Sarah', 'Pelle'), ('Serge', 'Oin'), ('Sylvie', 'Bromasseur'), ('Terry', 'Dicule'), ('Thierry', 'Gollo'), ('Yamamoto', 'Kaderate'), ('Emma', 'Carenna'), ('Candy', 'Raton')]

domains = ['enseirb-matmeca.fr', 'coucou.com', 'bonjour.net', 'salut.fr', 'hello.org', 'yo.io', 'hey.com', 'bonsoir.net']

foyers = [('Enseirb-Matmeca', 'La meilleure école'), ('Pizza House', 'La maison de la pizza'), ('Cake Mansion', 'Le manoir du gâteau'), ('Sausage Stadium', 'Un stade dans lequel on mange de la saucisse'), ('JDR/JDS Foyer', 'pour la blague'), ('Le bar du coin', 'c est un point relais'), ('Chez Paul', 'ça sent pas bon mais il reste réceptionner le colis'), ('Au RU1', 'Si tu n as pas peur de faire la queue')]

### PANIERS
paniers = [('vegan', 'que des légumes (ou pas)'), ('carnivore', 'que de la viande (ou pas)'), ('équilibré', 'un peu de tout'), ('soussoupe', 'de bonnes choses pour faire une bonne soupe'), ('fromager', 'parce que ça a pas le goût de l odeur'), ('éco', 'ne coûte pas très cher (en théorie)'), ('salade', 'de quoi faire une bonne salade originale')]

denrees = [('jambon', 'sans couenne', 'g'), ('laitue', 'fraîche', 'g'), ('lait', 'demi-écrémé', 'l'), ('gruyère', 'suisse', 'g'), ('pâtes', 'coquillettes', 'g'), ('tomate', 'coeur de boeuf', 'g'), ('confit d oignon', 'du vigan', 'g'), ('vin rouge', 'bordeaux', 'l'), ('oeufs', 'de poule', 'u'), ('pain', 'de campagne complet', 'g'), ('courgettes', 'verte', 'g'), ('poivrons', 'rouges, verts, jaunes', 'g'), ('gingembre', 'épicé', 'g'), ('carottes', 'riches en vitamines', 'g'), ('roquefort', 'très fort', 'g'), ('emmental', 'classique', 'g'), ('camembert', 'qui coule', 'g'), ('saucisses', 'chipos et merguez', 'g'), ('steaks', 'non hachés', 'g'), ('bananes', 'exotiques', 'g'), ('oranges', 'juteuses', 'g'), ('pommes', 'croquantes', 'g'), ('clémentines', 'vitaminées', 'g'), ('lait de soja', 'naturel', 'l'), ('chocolat', 'de suisse', 'g'), ('riz', 'basmati', 'g'), ('maïs', 'bien tendre', 'g'), ('fraises', 'juteuses', 'g'), ('abricots', 'du valais', 'g'), ('durian', 'qui sent pas bon', 'g'), ('farine', 'de sarrasin', 'g'), ('champignons', 'de Paris', 'g'), ('aubergines', 'violettes', 'g'), ('poulet', 'en filets', 'g'), ('viande des grisons', 'salée', 'g'), ('vin blanc', 'riesling', 'l'), ('vin rouge', 'bordeaux', 'l'), ('patates', 'de terre', 'g'), ('gigot', 'd agneau', 'g'), ('bavette', 'd Aloyau', 'g'), ('porc', 'caramelisé', 'g')]

N_PANIERS = len(paniers)
N_DENREES = len(denrees)


comment_block_separator = '-- ==================================================\n'
def comment_block(str) :
    res = comment_block_separator
    for line in str.splitlines() :
        res += '-- ' + line + '\n'
    return res + comment_block_separator 

def comment_title(str) :
    return '-- ### ' + str + ' ###\n'

def random_phone() :
    return random.choice(['06', '05', '01', '04', '09']) + str(random.randrange(10000000, 99999999, 1))

addr_id = 1
def random_address() :
    global addr_id
    id = str(addr_id)
    addr_id += 1
    country = random.choice(countries)
    city = random.choice(cities[country])
    street = random.choice(streets)
    zipcode = str(random.randrange(10000, 98000, 10))
    number = str(random.randrange(1, 99, 1))
    return 'INSERT INTO adresse VALUES (' + id + ' , \'' + country + '\', \'' + city + '\', \'' + zipcode + '\', \'' + number + '\', \'' + street + '\');\n' 

prod_id = 1
free_addr_prod = list(range(1, N_ADDRESSES+1))
def random_producer() :
    global prod_id
    id = str(prod_id)
    prod_id += 1
    
    global free_addr_prod
    i = random.randrange(0, len(free_addr_prod))
    aid = str(free_addr_prod[i])
    del free_addr_prod[i]
    
    prenom, nom = random.choice(names)
    phone = random_phone()
    email = prenom.lower() + nom.lower() + '@' + random.choice(domains)
    return 'INSERT INTO producteur VALUES (' +  id + ', ' + aid + ', \'' + nom + '\', \'' + prenom + '\', \'' + email + '\', \'' + phone + '\', \'' + prenom + ' ' + nom + '\');\n'

foyer_id = 1
free_addr_foyer = list(range(1, N_ADDRESSES+1))
def random_foyer() :
    global foyer_id
    id = str(foyer_id)
    foyer_id += 1

    global free_addr_foyer
    i = random.randrange(0, len(free_addr_foyer))
    aid = str(free_addr_foyer[i])
    del free_addr_foyer[i]

    name, description = random.choice(foyers)
    email = name.lower().replace(' ', '') + '@' + random.choice(domains)
    phone = random_phone()
    return 'INSERT INTO foyer VALUES (' + id + ', ' + aid + ', \'' + name + '\', \'' + description + '\', \'' + email + '\', \'' + phone + '\');\n'


cli_id = 1
free_addr_cli = list(range(1, N_ADDRESSES+1))
free_foyers_cli = list(range(1, N_FOYERS+1))
def random_client() :
    res = ''
    global cli_id
    id = str(cli_id)
    cli_id += 1
    
    global free_addr_cli
    i = random.randrange(0, len(free_addr_cli))
    aid = str(free_addr_cli[i])
    del free_addr_cli[i]
    
    prenom, nom = random.choice(names)
    phone = random_phone()
    email = prenom.lower() + nom.lower() + '@' + random.choice(domains)
    res += 'INSERT INTO client VALUES (' +  id + ', ' + aid + ', \'' + nom + '\', \'' + prenom + '\', \'' + email + '\', \'' + phone +  '\');\n'

    fid = str(random.randrange(1, N_FOYERS+1))
    if (len(free_foyers_cli) != 0) :
        i = random.randrange(0, len(free_foyers_cli))
        fid = str(free_foyers_cli[i])
        del free_foyers_cli[i]
    res += 'INSERT INTO appartenir_a VALUES(' + id + ', ' + fid + ');\n'

    return res

livr_id = 1
def random_livraison(fid, cid) :
    res = ''

    global livr_id
    global N_ADDRESSES
    global N_PANIERS
    global horaires
    
    id = str(livr_id)
    livr_id +=1

    aid = str(random.randrange(1, N_ADDRESSES +1))
    if (random.random() < 0.2) :
        fid = 'NULL'
    
    date = '\'2018-' + '{:2>}'.format(str(random.randrange(1, 13))).replace(' ', '0') + '-' + '{:2>}'.format(str(random.randrange(1, 29))).replace(' ', '0') + ' ' + '{:2>}'.format(str(random.randrange(0, 24))).replace(' ', '0') + ':' + '{:2>}'.format(str(random.randrange(0, 60))).replace(' ', '0') + ':00\''

    res += 'INSERT INTO livraison VALUES (' + id + ', ' + aid + ', ' + 'NULL' + ', ' + date + ');\n'
    
    pid = str(random.randrange(1, N_PANIERS +1))
    qtt = str(random.randrange(1, 100))
    res += 'INSERT INTO prevision_calendrier VALUES (' + cid + ', ' + id + ', ' + pid + ', ' + qtt + ');\n'

    res += 'UPDATE livraison SET id_foyer=' + fid + ' WHERE id_livraison=' + id + ';\n'
    return res

ctrt_id = 1
def random_contract() :
    res = ''
    
    global ctrt_id
    global N_PRODUCERS
    global N_FOYERS
    
    id = str(ctrt_id)
    ctrt_id += 1

    pid = str(random.randrange(1, N_PRODUCERS+1))
    n_max_adh = str(random.randrange(1, 100))
    prix = str(random.randrange(20, 100))
    n_max_pai = str(random.randrange(3, 10))
    n_min_pai = str(random.randrange(1, 4))
    res += 'INSERT INTO contrat VALUES (' + id + ', ' + pid + ', ' + n_max_adh + ', ' + prix + ', ' + n_min_pai + ', ' + n_max_pai + ');\n'

    id_foyers = list(range(1, N_FOYERS+1))
    n_adh_max = int(n_max_adh)
    n_adh = 0
    while (n_adh < n_adh_max) :
    
        if random.random() < 0.00001 :
            break
        
        if len(id_foyers) == 0 :
            break
        i = random.randrange(len(id_foyers))
        fid = str(id_foyers[i])
        del id_foyers[i]
        
        n_sous = min(n_adh_max - n_adh, random.randrange(1, 20))
        n_adh += n_sous
        n_sous = str(n_sous)
        n_pai = str(random.randrange(int(n_min_pai), int(n_max_pai)+1))
        res += 'INSERT INTO souscrire_a VALUES (' + fid + ', ' + id + ', ' + n_pai + ', ' + n_sous + ');\n'

        res += random_livraison(fid, id)
        
    return res + '\n'

def paniers_denrees() :
    res = ''

    global paniers
    global denrees
    global N_PANIERS
    global N_DENREES

    for id in range(N_PANIERS) :
        nom, desc = paniers[id]
        res += 'INSERT INTO panier VALUES (' + str(id+1) + ', \'' + nom + '\', \'' + desc + '\');\n'

    for id in range(N_DENREES) :
        nom, desc, uni = denrees[id]
        res += 'INSERT INTO denree VALUES (' + str(id+1) + ', \'' + nom + '\', \'' + desc + '\', \'' + uni + '\');\n'

    for pid in range(1, N_PANIERS+1) :
        id_denrees = random.sample(list(range(1, N_DENREES+1)), random.randrange(4, 8))
        for did in id_denrees :
            res += 'INSERT INTO contenir VALUES (' + str(pid) + ', ' + str(did) + ', ' + str(random.randrange(1,654)) + ');\n'
        

    return res

# Main part of the program
with open('peuplement.sql', 'wt') as f :
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
    f.write('DELETE FROM client;\n')
    f.write('DELETE FROM foyer;\n')
    f.write('DELETE FROM contrat;\n')
    f.write('DELETE FROM producteur;\n')
    f.write('DELETE FROM adresse;\n\n')

    f.write('commit;\n')
    
    f.write('\n\n')
    
    f.write(comment_block('Création des données\n'))
    f.write('\n')
    f.write(comment_title('Adresses'))
    for i in range(N_ADDRESSES) :
        f.write(random_address())
    f.write('commit;\n\n')

    f.write(comment_title('Producteurs'))
    for i in range(N_PRODUCERS) :
        f.write(random_producer())
    f.write('commit;\n\n')

    f.write(comment_title('Foyers'))
    for i in range(N_FOYERS) :
        f.write(random_foyer())
    f.write('commit;\n\n')

    f.write(comment_title('Clients'))
    for i in range(N_CLIENTS) :
        f.write(random_client())
    f.write('commit;\n\n')

    f.write(comment_title('Paniers et denrées'))
    f.write(paniers_denrees())
    f.write('commit;\n\n')
    
    f.write(comment_title('Contrats + souscriptions + livraisons + prévisions calendrier'))
    for i in range(N_CONTRACTS) :
        f.write(random_contract())
    f.write('commit;\n\n')

