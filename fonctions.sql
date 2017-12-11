-- CONSULTATIONS --

-- Liste des foyers ayant souscrits à un contrat donné

CREATE OR REPLACE FUNCTION liste_foyers_contrat (id_contrat INTEGER)
RETURNS TABLE(id_foyer INTEGER, nom VARCHAR, description VARCHAR, adresse_mail VARCHAR, telephone VARCHAR) STABLE AS
$$
	SELECT DISTINCT
		id_foyer,
		f.nom,
		f.description,
		f.adresse_mail,
		f.telephone
	FROM 
		souscrire_a
		JOIN foyer f
			USING (id_foyer)
	WHERE
		id_contrat = $1;
$$ LANGUAGE SQL;



-- Liste des livraisons prévues à un mois

CREATE OR REPLACE FUNCTION liste_livraisons_mois (mois INTEGER)
RETURNS TABLE
	(
		id_livraison INTEGER, 
		date_livraison DATE, 
		numero_rue VARCHAR, 
		rue VARCHAR, 
		code_postal VARCHAR, 
		ville VARCHAR, 
		pays VARCHAR
	)STABLE AS
$$
	SELECT 
		id_livraison,
		l.date_livraison,
		a.numero_rue,
		a.rue,
		a.code_postal,
		a.ville,
		a.pays
	FROM 
		livraison l
		JOIN adresse a
			USING (id_adresse)
    WHERE 
    	EXTRACT(month FROM date_livraison) = $1;
    	
$$ LANGUAGE SQL;


-- Liste des livraisons pour lesquelles personne n'est inscrit

CREATE OR REPLACE FUNCTION liste_livraisons_sans_inscriptions ()
RETURNS 
TABLE(
	id_livraison INTEGER,
	date_livraison DATE, 
		numero_rue VARCHAR, 
		rue VARCHAR, 
		code_postal VARCHAR, 
		ville VARCHAR, 
		pays VARCHAR
) STABLE AS
$$
  SELECT 
 	 id_livraison,
 	 date_livraison, 
		numero_rue, 
		rue, 
		code_postal, 
		ville, 
		pays
    FROM
    	livraison 
    	JOIN adresse
    		USING (id_adresse)
	WHERE 
		id_foyer IS NULL;
		
$$ LANGUAGE SQL;


-- Calendrier des livraisons de l'ensemble des contrats d'un adhérent donné

CREATE OR REPLACE FUNCTION calendrier_livraisons_contrats_adherent(id_adherent INTEGER)
RETURNS 
	TABLE(
		id_contrat INTEGER, 
		date_livraison DATE, 
		numero_rue VARCHAR, 
		rue VARCHAR, 
		code_postal VARCHAR, 
		ville VARCHAR, 
		pays VARCHAR
	) STABLE AS
$$
	SELECT DISTINCT
  		sa.id_contrat, 
  		liv.date_livraison,
		numero_rue, 
		rue, 
		code_postal, 
		ville, 
		pays
  		
	FROM 
		prevision_calendrier pc
		JOIN souscrire_a sa
			ON pc.id_contrat = sa.id_contrat
		JOIN appartenir_a appa
			ON sa.id_foyer = sa.id_foyer
		JOIN livraison liv
			ON liv.id_livraison = pc.id_livraison
		JOIN adresse adr
			ON adr.id_adresse = liv.id_adresse
			
	WHERE 
		id_client = $1
		
	ORDER BY
		liv.date_livraison ASC
		
$$ LANGUAGE SQL;




-- Calendrier des livraisons de l'ensemble des contrats d'un foyer donné

CREATE OR REPLACE FUNCTION calendrier_livraisons_contrats_foyer(id_foyer INTEGER)
RETURNS TABLE(id_contrat INTEGER, 
nom VARCHAR,
prneom VARCHAR,
date_livraison DATE, 
numero_rue VARCHAR,
rue VARCHAR,
code_postal VARCHAR, 
ville VARCHAR, 
pays VARCHAR) STABLE AS
$$
	SELECT DISTINCT
  		sa.id_contrat,
  		p.nom,
  		p.prenom,
  		liv.date_livraison,
  		adr.numero_rue, 
  		adr.rue, 
		adr.code_postal, 
		adr.ville, 
		adr.pays
  		
	FROM 
		prevision_calendrier pc
		JOIN souscrire_a sa
			ON pc.id_contrat = sa.id_contrat
		JOIN livraison liv
			ON liv.id_livraison = pc.id_livraison
		JOIN adresse adr
			ON adr.id_adresse = liv.id_adresse
		JOIN contrat c
			ON c.id_contrat = pc.id_contrat
		JOIN producteur p
			ON p.id_producteur = c.id_producteur
			
	WHERE 
		sa.id_foyer = $1
		
	ORDER BY
		liv.date_livraison ASC
		
$$ LANGUAGE SQL;

-- STATISTIQUES --

-- Liste des foyers, avec pour chaque foyer, son nombre de participations à des distributions pour une année donnée


CREATE OR REPLACE FUNCTION nombre_participations_annee(annee INTEGER)
RETURNS TABLE(nom VARCHAR, description VARCHAR, adresse_mail VARCHAR, nb_participations BIGINT) STABLE AS
$$

	WITH compte_des_participants AS
	(
		SELECT 
			id_foyer,
			count(*) AS nb_participations
		FROM 
			livraison
		WHERE 
			EXTRACT(YEAR FROM date_livraison) = $1
		
		GROUP BY
			id_foyer
	)
	
	SELECT 
		f.nom,
		f.description,
		f.adresse_mail,
		COALESCE(nb_participations,0) AS nb_participations
	FROM 
		foyer f
		LEFT JOIN compte_des_participants
			USING (id_foyer)
			
	ORDER BY
		nb_participations DESC
	
$$ LANGUAGE SQL;




	
-- Somme des montants des tous les contrats souscrits pour chaque foyer

CREATE OR REPLACE FUNCTION somme_montants_contrats_foyer()
RETURNS TABLE(id_foyer INTEGER, nom VARCHAR, description VARCHAR, adresse_mail VARCHAR, somme_contrats BIGINT) STABLE AS
$$

	WITH somme_des_souscrivants AS 
	(
		SELECT 
			id_foyer,
			SUM(prix_total * nb_souscriptions) AS somme
		FROM 
			souscrire_a
			JOIN contrat
				USING (id_contrat)
		GROUP BY 
			id_foyer
	)
	
	SELECT 
		id_foyer,
		f.nom,
		f.description,
		f.adresse_mail,
		COALESCE(somme,0) AS somme_contrats
	FROM
		foyer f
		LEFT JOIN somme_des_souscrivants
			USING (id_foyer)
	ORDER BY 
		somme DESC ;
	
$$ LANGUAGE SQL;




	
	

-- Somme des montants des tous les contrats souscrits pour chaque adhérent

CREATE OR REPLACE FUNCTION somme_montants_contrats_adherent()
RETURNS TABLE(id_adherent INTEGER, somme_contrats BIGINT) STABLE AS
$$
  SELECT 
  	id_client,
  	 SUM(prix_total) AS somme 
	 FROM foyer f
	      JOIN souscrire_a 
	      	   USING (id_foyer)
	      JOIN contrat 
	      	   USING (id_contrat)
              JOIN appartenir_a 
	      	   USING (id_foyer)
              JOIN client c
	      	   USING (id_client)
		   	 GROUP BY id_client
			       ORDER BY somme DESC
$$ LANGUAGE SQL;






-- Prix moyen du panier pour chaque contrat

CREATE OR REPLACE FUNCTION prix_moyen_panier()
RETURNS TABLE(id_contrat INTEGER, prix_moyen NUMERIC) STABLE AS
$$
	SELECT 
		id_contrat,
		prix_total :: NUMERIC / SUM(quantité) :: NUMERIC AS prix_moyen
	FROM 
		prevision_calendrier
		JOIN contrat
			USING (id_contrat)
	GROUP BY 
		id_contrat,
		prix_total
	ORDER BY 
		prix_moyen DESC
		
$$ LANGUAGE SQL;

-- Revenu moyen par mois pour chaque producteur, pour une année donnée
	
CREATE OR REPLACE FUNCTION revenu_moyen_mensuel()	
RETURNS TABLE(id_producteur INTEGER, prenom VARCHAR, nom VARCHAR, adresse_mail VARCHAR, revenu_moyen NUMERIC) STABLE AS
$$
  SELECT 
  	p.id_producteur,
  	p.prenom,
  	p.nom,
  	p.adresse_mail,
  	SUM(prix_total*nb_souscriptions) :: NUMERIC /12. AS revenu_moyen 
	 FROM producteur p
	      JOIN contrat
	      	    USING (id_producteur)
	      JOIN souscrire_a 
	      	   USING (id_contrat)
	 GROUP BY 
	 		p.id_producteur
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


