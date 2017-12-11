#-*- coding: utf-8 -*-
from appJar import gui
import psycopg2
import peuplement as ppl

#Tabbed Frame
activefg="black"
activebg="white"
inactivefg="black"
inactivebg="grey"
disabledfg="black"
disabledbg="red"
tabbedbg="blue"


### APP CODE ###
## GLOBAL VARS ##
conn=None
cur=None

#################

app=gui("AMAP", "800x450")

def message(str) :
    app.setLabelBg("output", "gray")
    app.setLabel("output", str)

def success(str) :
    app.setLabelBg("output", "green")
    app.setLabel("output", str)
    
def error(str) :
    app.setLabelBg("output", "red")
    app.setLabel("output", str)    

def format_result(result) :
    res = ''
    for i in result :
        res += str(i) + '\n'
    return res
    
def consultation(btn) :
    global cur
    result = ""
    window = ""
    message("requête en cours")
    if btn == "bcons1" :
        window = "qresult"
        i = int(app.getEntry("econs_cid"))
        cmd = "SELECT * FROM liste_foyers_contrat(" + str(i) + ");"
        cur.execute(cmd)
    elif btn == "bcons2" :
        window = "qresult"
        i = int(app.getEntry("econs_month"))
        cmd = "SELECT * FROM liste_livraisons_mois(" + str(i) + ");"
        cur.execute(cmd)
    
    elif btn == "bcons3":
        window = "qresult"
        cmd = "SELECT * FROM liste_livraisons_sans_inscriptions();"
        cur.execute(cmd)        
    
    elif btn == "bcons4" :
        window = "qresult"
        i = int(app.getEntry("econs_cli"))
        cmd = "SELECT * FROM calendrier_livraisons_contrats_adherent(" + str(i) + ");"
        cur.execute(cmd)

    elif btn == "bstat1":
        window = "sresult"
        cmd = "SELECT * FROM nombre_participations_annee(2018);"
        cur.execute(cmd)

    elif btn == "bstat2":
        window = "sresult"
        cmd = "SELECT * FROM somme_montants_contrats_foyer();"
        cur.execute(cmd)

    elif btn == "bstat3":
        window = "sresult"
        cmd = "SELECT * FROM prix_moyen_panier();"
        cur.execute(cmd)

    elif btn == "bstat4":
        window = "sresult"
        cmd = "SELECT * FROM revenu_moyen_mensuel();"
        cur.execute(cmd)

    else :
        error("something went wrong")
        return
    result = format_result(cur.fetchall())
    app.clearTextArea(window)
    app.setTextArea(window, result, end=True, callFunction=False)
    success("résultat de la requête affiché")
        
def loginSubmit(btn):
    global conn
    global cur
    db = app.getEntry("dbname")
    usr = app.getEntry("username")
    pwd = app.getEntry("password")
    conncmd = "dbname=" + db + " user=" + usr
    if pwd != "":
        conncmd+=" password=" + pwd
    try :
        conn = psycopg2.connect(conncmd)
        cur = conn.cursor()
    except :
        error("La connexion à la BDD \"" + db + "\" avec l'utilisateur \"" + usr + "\" a échoué")
        conn=None
        cur=None
        return
    app.setTabbedFrameDisableAllTabs("tf", disabled=False)
    success("Connecté à la BDD \"" + db + "\" avec l'utilisateur \"" + usr + "\"")

def peupler(btn):
    global conn
    global cur
    if conn == None :
        error("Vous devez d'abord vous connecter à la BDD")
        return
    n_addr = int(app.getEntry("n_addr"))
    n_pdcr = int(app.getEntry("n_pdcr"))
    n_foy = int(app.getEntry("n_foy"))
    n_cli = int(app.getEntry("n_cli"))
    n_ctrt = int(app.getEntry("n_ctrt"))
    if n_addr == 0 or n_pdcr == 0 or n_foy == 0 or n_cli == 0 or n_ctrt == 0:
        error("Vous devez mettre au moins 1 dans chaque case")
        return

    if (n_addr<n_foy):
        error("Le nombre d'adresses doit être plus grand que le nombre de foyers")
        return
    if (n_addr<n_cli):
        error("Le nombre d'adresses doit être plus grand que le nombre de clients")
        return
    if (n_addr<n_pdcr):
        error("Le nombre d'adresses doit être plus grand que le nombre de producteurs")
        return
    
    message("génération des données de peuplement...");
    ppl.init(n_addr, n_pdcr, n_foy, n_cli, n_ctrt)
    ppl.peuplement()

    message("peuplement de la base de données...")
    try :
        with open("./peuplement.sql", 'r') as f:
            for line in f:
                print(line)
                if len(line)==0 or line.isspace() or line.startswith("--"):
                    continue
                if line.startswith("commit"):
                    conn.commit()
                    continue
                cur.execute(line)
    except:
        error("erreur lors du peuplement")
        return
    success("base de données peuplée avec succès")

    #Update DB


## GUI ##
app.setSticky("news")
app.setExpand("both")

app.startTabbedFrame("tf")
app.setTabbedFrameTabExpand("tf", expand=True)
app.setTabbedFrameActiveFg("tf", activefg)
app.setTabbedFrameActiveBg("tf", activebg)
app.setTabbedFrameInactiveFg("tf", inactivefg)
app.setTabbedFrameInactiveBg("tf", inactivebg)
app.setTabbedFrameDisabledFg("tf", disabledfg)
app.setTabbedFrameDisabledBg("tf", disabledbg)
app.setTabbedFrameBg("tf", tabbedbg)

app.startTab("Général")

app.startLabelFrame("lflogin", 0, 0, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.setFont(22)

app.addLabel("llogin", "Connexion à la BDD", 0, 0, 3)

app.setFont(15)
app.addEntry("dbname", 1, 0, 3)
app.setEntryBg("dbname", "white")
app.setEntryFg("dbname", "black")
app.setEntryDefault("dbname", "nom de la BDD")

app.addEntry("username", 2, 0, 3)
app.setEntryBg("username", "white")
app.setEntryFg("username", "black")
app.setEntryDefault("username", "identifiant")

app.addSecretEntry("password", 3, 0, 3)
app.setEntryBg("password", "white")
app.setEntryFg("password", "black")
app.setEntryDefault("password", "mot de passe")

app.addLabel("leftbs", ">>>>>", 4, 0)
app.addButton("connexion", loginSubmit, 4, 1)
app.setButtonFg("connexion", "black")
app.setButtonBg("connexion", "white")
app.addLabel("rightbs", "<<<<<", 4, 2)

app.stopLabelFrame()

app.startLabelFrame("lfpeuplement", 0, 1, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.setFont(22)

app.addLabel("lpeuplement", "Peuplement de la BDD", 0, 0, 3)
app.setFont(15)

app.addNumericEntry("n_addr", 1, 0, 3)
app.setEntryBg("n_addr", "white")
app.setEntryFg("n_addr", "black")
app.setEntryDefault("n_addr", "Nombre d'adresses")

app.addNumericEntry("n_pdcr", 2, 0, 3)
app.setEntryBg("n_pdcr", "white")
app.setEntryFg("n_pdcr", "black")
app.setEntryDefault("n_pdcr", "Nombre de producteurs")

app.addNumericEntry("n_foy", 3, 0, 3)
app.setEntryBg("n_foy", "white")
app.setEntryFg("n_foy", "black")
app.setEntryDefault("n_foy", "Nombre de foyers")

app.addNumericEntry("n_cli", 4, 0, 3)
app.setEntryBg("n_cli", "white")
app.setEntryFg("n_cli", "black")
app.setEntryDefault("n_cli", "Nombre de clients")

app.addNumericEntry("n_ctrt", 5, 0, 3)
app.setEntryBg("n_ctrt", "white")
app.setEntryFg("n_ctrt", "black")
app.setEntryDefault("n_ctrt", "Nombre de contrats")

app.addLabel("leftbs2", ">>>>>", 6, 0)
app.addButton("peupler", peupler, 6, 1)
app.setButtonFg("peupler", "black")
app.setButtonBg("peupler", "white")
app.addLabel("rightbs2", "<<<<<", 6, 2)

app.stopLabelFrame()

app.stopTab()

app.startTab("Consultation")

app.startLabelFrame("lfcons1", 0, 0, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lcons1", "Liste des adhérents ayant souscrits\n à un certain contrat")
app.addNumericEntry("econs_cid")
app.setEntryBg("econs_cid", "white")
app.setEntryFg("econs_cid", "black")
app.setEntryDefault("econs_cid", "id contrat")
app.addNamedButton("consulter", "bcons1", consultation)
app.setButtonFg("bcons1", "black")
app.setButtonBg("bcons1", "white")
app.stopLabelFrame()

app.startLabelFrame("lfcons2", 0, 1, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lcons2", "Liste des livraisons prévues pour un certain mois (entrer le mois sous forme d'un entier)")
app.addNumericEntry("econs_month")
app.setEntryBg("econs_month", "white")
app.setEntryFg("econs_month", "black")
app.setEntryDefault("econs_month", "numero mois")
app.addNamedButton("consulter", "bcons2", consultation)
app.setButtonFg("bcons2", "black")
app.setButtonBg("bcons2", "white")
app.stopLabelFrame()

app.startLabelFrame("lfcons3", 1, 0, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lcons3", "Liste des livraisons où personne n'est inscrit")
app.addNamedButton("consulter", "bcons3", consultation)
app.setButtonFg("bcons3", "black")
app.setButtonBg("bcons3", "white")
app.stopLabelFrame()

app.startLabelFrame("lfcons4", 1, 1, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lcons4", "Calendrier des livraisons des contrats auxquels un client a souscrit")
app.addNumericEntry("econs_cli")
app.setEntryBg("econs_cli", "white")
app.setEntryFg("econs_cli", "black")
app.setEntryDefault("econs_cli", "id client")
app.addNamedButton("consulter", "bcons4", consultation)
app.setButtonFg("bcons4", "black")
app.setButtonBg("bcons4", "white")
app.stopLabelFrame()

app.addScrolledTextArea("qresult", 2, 0, colspan=2)
app.setTextArea("qresult", "Ici le résultat des requêtes\n")
app.stopTab()

app.startTab("Statistiques")

app.startLabelFrame("lfstat1", 0, 0, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lstat1", "Liste des adhérents avec le nombre de participations à des distributions au cours de l'année")
app.addNamedButton("consulter", "bstat1", consultation)
app.setButtonFg("bstat1", "black")
app.setButtonBg("bstat1", "white")
app.stopLabelFrame()

app.startLabelFrame("lfstat2", 0, 1, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lstat2", "Somme des montatns de tous les contrats souscrits par chaque adhérent")
app.addNamedButton("consulter", "bstat2", consultation)
app.setButtonFg("bstat2", "black")
app.setButtonBg("bstat2", "white")
app.stopLabelFrame()

app.startLabelFrame("lfstat3", 1, 0, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lstat3", "Pour chaque contrat, prix moyen d'un panier")
app.addNamedButton("consulter", "bstat3", consultation)
app.setButtonFg("bstat3", "black")
app.setButtonBg("bstat3", "white")
app.stopLabelFrame()

app.startLabelFrame("lfstat4", 1, 1, hideTitle=True)
app.setSticky("news")
app.setExpand("column")
app.addLabel("lstat4", "Pour chaque producteur, la somme moyenne qui lui est versée chaque mois")
app.addNamedButton("consulter", "bstat4", consultation)
app.setButtonFg("bstat4", "black")
app.setButtonBg("bstat4", "white")
app.stopLabelFrame()

app.addScrolledTextArea("sresult", 2, 0, colspan=2)
app.setTextArea("sresult", "Ici le résultat des requêtes\n")
app.stopTab()

app.startTab("Ajout")
app.addLabel("l4", "Rien pour le moment")
app.stopTab()

app.startTab("Suppression")
app.addLabel("l5", "Rien pour le moment")
app.stopTab()

app.setTabbedFrameDisableAllTabs("tf", disabled=True)
app.setTabbedFrameDisabledTab("tf", "Général", disabled=False)
app.setTabbedFrameSelectedTab("tf", "Général")

app.stopTabbedFrame()

app.setExpand("column")
app.startLabelFrame("lfoutput", hideTitle=True)
app.setSticky("news")
app.addLabel("output", "")
app.setLabelBg("output", "gray")
app.setLabelFg("output", "black")
app.stopLabelFrame()
#app.addStatusBar(fields=1)
#app.setStatusBar("OUTPUT : ", 0)

app.go()

