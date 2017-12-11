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
app.addLabel("l2", "Rien pour le moment")
app.stopTab()

app.startTab("Statistiques")
app.addLabel("l3", "Rien pour le moment")
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

