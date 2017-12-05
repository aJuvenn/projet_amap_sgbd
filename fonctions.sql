-- CONSULTATIONS --

-- Liste des foyers ayant souscrits à un contrat donné

CREATE OR REPLACE FUNCTION liste_foyers_contrat (id_contrat INTEGER)
RETURNS TABLE(id_foyer INTEGER) STABLE AS
$$
  SELECT id_foyer 
  	 FROM souscrire_a 
	      WHERE id_contrat=$1;
$$ LANGUAGE SQL;


-- Liste des livraisons prévues à un mois

CREATE OR REPLACE FUNCTION liste_livraisons_mois (mois INTEGER)
RETURNS TABLE(id_livraison INTEGER) STABLE AS
$$
  SELECT id_livraison 
  	 FROM livraison 
              WHERE EXTRACT(month FROM date_livraison)=$1;
$$ LANGUAGE SQL;


-- Liste des livraisons pour lesquelles personne n'est inscrit

CREATE OR REPLACE FUNCTION liste_livraisons_sans_inscriptions ()
RETURNS TABLE(id_livraison INTEGER) STABLE AS
$$
  SELECT id_livraison 
       FROM livraison 
       	    WHERE id_foyer IS NULL;
$$ LANGUAGE SQL;


-- Calendrier des livraisons de l'ensemble des contrats d'un adhérent donné

CREATE OR REPLACE FUNCTION calendrier_livraisons_contrats_adherent(id_adherent INTEGER)
RETURNS TABLE(id_contrat INTEGER, date_livraison DATE) STABLE AS
$$
  SELECT sa.id_contrat, 
  	 date_livraison 
	 FROM souscrire_a sa
    	      JOIN foyer 
       	      	   USING (id_foyer)
   	      JOIN livraison 
       	      	   USING (id_foyer)
    	      JOIN appartenir_a 
       	      	   USING (id_foyer)
    	      JOIN client 
      	      	    USING (id_client)
    	   	    	   WHERE id_client=$1
  	         	   	 ORDER BY date_livraison ASC
$$ LANGUAGE SQL;

-- Calendrier des livraisons de l'ensemble des contrats d'un foyer donné

CREATE OR REPLACE FUNCTION calendrier_livraisons_contrats_foyer(id_foyer INTEGER)
RETURNS TABLE(id_contrat INTEGER, date_livraison DATE) STABLE AS
$$
  SELECT sa.id_contrat, 
  	 date_livraison 
	 FROM souscrire_a sa
	      JOIN foyer f 
	      	   USING (id_foyer)
	      JOIN livraison 
	      	   USING (id_foyer)
		   	 WHERE f.id_foyer=$1
			       ORDER BY date_livraison ASC
$$ LANGUAGE SQL;

-- STATISTIQUES --

-- Liste des foyers, avec pour chaque foyer, son nombre de participations à des distributions pour une année donnée

CREATE OR REPLACE FUNCTION nombre_participations_annee(annee INTEGER)
RETURNS TABLE(id_foyer INTEGER, n_participations BIGINT) STABLE AS
$$
  SELECT f.id_foyer, 
  	 COUNT(DISTINCT id_livraison) AS n_participations 
	 FROM foyer f
	      JOIN livraison 
	      	   USING (id_foyer)
		   	 WHERE EXTRACT(year FROM date_livraison)=$1
			       GROUP BY f.id_foyer
			       	     ORDER BY n_participations DESC
$$ LANGUAGE SQL;

-- Somme des montants des tous les contrats souscrits pour chaque foyer

CREATE OR REPLACE FUNCTION somme_montants_contrats_foyer()
RETURNS TABLE(id_foyer INTEGER, somme_contrats BIGINT) STABLE AS
$$
  SELECT f.id_foyer, 
  	 SUM(prix_total) AS somme 
	 FROM foyer f
	      JOIN souscrire_a 
	      	   USING (id_foyer)
	      JOIN contrat 
	      	   USING (id_contrat)
		   	 GROUP BY f.id_foyer
			       ORDER BY somme DESC
$$ LANGUAGE SQL;

-- Somme des montants des tous les contrats souscrits pour chaque adhérent

CREATE OR REPLACE FUNCTION somme_montants_contrats_adherent()
RETURNS TABLE(id_adherent INTEGER, somme_contrats BIGINT) STABLE AS
$$
  SELECT id_client, 
  	 SUM(prix_total) AS somme 
	 FROM foyer f
	      JOIN souscrire_a 
	      	   USING (id_foyer)
	      JOIN contrat 
	      	   USING (id_contrat)
              JOIN appartenir_a 
	      	   USING (id_foyer)
              JOIN client 
	      	   USING (id_client)
		   	 GROUP BY id_client
			       ORDER BY somme DESC
$$ LANGUAGE SQL;

-- Prix moyen du panier pour chaque contrat

CREATE OR REPLACE FUNCTION prix_moyen_panier()
RETURNS TABLE(id_contrat INTEGER, prix_moyen INTEGER) STABLE AS
$$
  SELECT id_contrat, 
  	 prix_total/quantité AS prix_moyen 
	 FROM contrat
	      JOIN prevision_calendrier
	      	   USING (id_contrat)
		   	 GROUP BY id_contrat, 
			       	  prix_moyen
				  ORDER BY prix_moyen DESC
$$ LANGUAGE SQL;

-- Revenu moyen par mois pour chaque producteur, pour une année donnée

CREATE OR REPLACE FUNCTION revenu_moyen_mensuel()	
RETURNS TABLE(id_producteur INTEGER, revenu_moyen BIGINT) STABLE AS
$$
  SELECT p.id_producteur, 
  	 SUM(prix_total*nb_souscriptions)/12 AS revenu_moyen 
	 FROM producteur p
	      JOIN contrat
	      	    USING (id_producteur)
	      JOIN souscrire_a 
	      	   USING (id_contrat)
	      JOIN foyer
	      	    USING (id_foyer)
		    	  GROUP BY p.id_producteur
			  	ORDER BY revenu_moyen DESC 
$$ LANGUAGE SQL;

-- MISE A JOUR --

-- Préliminaires --

CREATE OR REPLACE FUNCTION max_id_adresse()
RETURNS INTEGER AS
$$
SELECT MAX(id_adresse) FROM adresse 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_denree()
RETURNS INTEGER AS
$$
SELECT MAX(id_denree) FROM denree 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_panier()
RETURNS INTEGER AS
$$
SELECT MAX(id_panier) FROM panier
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_livraison()
RETURNS INTEGER AS
$$
SELECT MAX(id_livraison) FROM livraison 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_client()
RETURNS INTEGER AS
$$
SELECT MAX(id_client) FROM client 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_foyer()
RETURNS INTEGER AS
$$
SELECT MAX(id_foyer) FROM foyer 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_contrat()
RETURNS INTEGER AS
$$
SELECT MAX(id_contrat) FROM contrat
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION max_id_producteur()
RETURNS INTEGER AS
$$
SELECT MAX(id_producteur) FROM producteur 
$$ LANGUAGE SQL;

-- Ajouts --

CREATE OR REPLACE FUNCTION ajout_adresse(id INTEGER, pays VARCHAR(50), ville VARCHAR(50), code_postal VARCHAR(50), numero_rue VARCHAR(50), rue VARCHAR(50))
RETURNS VOID AS
$$
INSERT INTO adresse VALUES (id, pays, ville, code_postal, numero_rue, rue)
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ajout_foyer(id INTEGER, id_adresse INTEGER, nom VARCHAR(50), description VARCHAR(1000), adresse_mail VARCHAR(50), telephone VARCHAR(50))
RETURNS VOID AS
$$
INSERT INTO foyer VALUES (id, id_adresse, nom, description, adresse_mail, telephone)
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION ajout_client(id INTEGER, id_adresse INTEGER, nom VARCHAR(50), prenom VARCHAR(50), adresse_mail VARCHAR(50), telephone VARCHAR(50))
RETURNS VOID AS
$$
INSERT INTO client VALUES (id, id_adresse, nom, prenom, adresse_mail, telephone)
$$ LANGUAGE SQL;


-- Suppression --

-- Supprimer une ligne correspondant à un id

CREATE OR REPLACE FUNCTION supprime_adresse(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM adresse WHERE id_adresse=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_denree(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM denree WHERE id_denree=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_panier(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM panier WHERE id_panier=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_livraison(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM livraison WHERE id_livraison=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_client(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM client WHERE id_client=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_foyer(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM foyer WHERE id_foyer=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_contrat(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM contrat WHERE id_contrat=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_producteur(id INTEGER)
RETURNS VOID AS
$$
DELETE FROM producteur WHERE id_producteur=$1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_souscrire_a(id INTEGER, id_2 INTEGER)
RETURNS VOID AS
$$
DELETE FROM souscrire_a WHERE id_foyer=$1 AND id_contrat=$2
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_contenir(id INTEGER, id_2 INTEGER)
RETURNS VOID AS
$$
DELETE FROM contenir WHERE id_panier=$1 AND id_denree=$2
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_appartenir_a(id INTEGER, id_2 INTEGER)
RETURNS VOID AS
$$
DELETE FROM appartenir_a WHERE id_client=$1 AND id_foyer=$2
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_prevision_calendrier(id INTEGER, id_2 INTEGER, id_3 INTEGER)
RETURNS VOID AS
$$
DELETE FROM prevision_calendrier WHERE id_contrat=$1 AND id_livraison=$2 AND id_panier=$3
$$ LANGUAGE SQL;

-- Supprimer une table entière

CREATE OR REPLACE FUNCTION supprime_table_adresse()
RETURNS VOID AS
$$
DELETE FROM adresse 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_denree()
RETURNS VOID AS
$$
DELETE FROM denree 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_panier()
RETURNS VOID AS
$$
DELETE FROM panier
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_livraison()
RETURNS VOID AS
$$
DELETE FROM livraison
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_client()
RETURNS VOID AS
$$
DELETE FROM client 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_foyer()
RETURNS VOID AS
$$
DELETE FROM foyer 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_contrat()
RETURNS VOID AS
$$
DELETE FROM contrat 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprime_table_producteur()
RETURNS VOID AS
$$
DELETE FROM producteur 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_table_souscrire_a()
RETURNS VOID AS
$$
DELETE FROM souscrire_a 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_table_contenir()
RETURNS VOID AS
$$
DELETE FROM contenir 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_table_appartenir_a()
RETURNS VOID AS
$$
DELETE FROM appartenir_a 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION supprimer_table_prevision_calendrier()
RETURNS VOID AS
$$
DELETE FROM prevision_calendrier 
$$ LANGUAGE SQL;

-- Modification --


-- TESTS --

-- Consultations

SELECT liste_foyers_contrat(2);
SELECT liste_livraisons_mois(11);
SELECT liste_livraisons_sans_inscriptions();
SELECT calendrier_livraisons_contrats_adherent(1);
SELECT calendrier_livraisons_contrats_foyer(1);

-- Statistiques

SELECT nombre_participations_annee(2017);
SELECT somme_montants_contrats_foyer();
SELECT somme_montants_contrats_adherent();
SELECT prix_moyen_panier();
SELECT revenu_moyen_mensuel();

-- Mises à jour

SELECT max_id_adresse();
SELECT max_id_denree();
SELECT max_id_panier();
SELECT max_id_livraison();
SELECT max_id_client();
SELECT max_id_foyer();
SELECT max_id_contrat();
SELECT max_id_producteur();

SELECT ajout_adresse(max_id_adresse()+1,'Mexique','Tulum','','','');
SELECT ajout_foyer(max_id_foyer()+1,5,'Le foyer','un foyer','lol@xd.ptdr','0787546721');
SELECT ajout_client(max_id_client()+1,4,'Racine','Jean','','');

SELECT supprime_foyer(max_id_foyer());
SELECT supprime_adresse(max_id_adresse());

