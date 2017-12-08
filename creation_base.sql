-- ============================================================
--   Nom de la base   :  AMAP
--   Nom de SGBD      :  POSTGRESQL
-- ============================================================



-- ============================================================
--   Table : adresse
-- ============================================================

DROP  TABLE IF EXISTS adresse CASCADE;
CREATE TABLE adresse
(
	id_adresse		INTEGER		NOT NULL,

	pays			VARCHAR(50)		NOT NULL,
	ville			VARCHAR(50)		NOT NULL,
	code_postal		VARCHAR(50)		NOT NULL,
	numero_rue		VARCHAR(50)		NOT NULL,
	rue				VARCHAR(50)		NOT NULL,

	CONSTRAINT pk_adresse PRIMARY KEY (id_adresse)
);

-- ============================================================
--   Table : foyer
-- ============================================================

DROP TABLE IF EXISTS foyer CASCADE;
CREATE TABLE foyer
(
	id_foyer		INTEGER		NOT NULL,

	id_adresse		INTEGER				,

	nom				VARCHAR(50)				,
	description		VARCHAR(1000)			,
	adresse_mail	VARCHAR(50)				,
	telephone		VARCHAR(50)				,

	CONSTRAINT pk_foyer PRIMARY KEY (id_foyer),

	CONSTRAINT fk_foyer FOREIGN KEY (id_adresse)
		REFERENCES adresse (id_adresse)
);



-- ============================================================
--   Table : client
-- ============================================================

DROP TABLE IF EXISTS client CASCADE;
CREATE TABLE client
(
	id_client		INTEGER		NOT NULL,

	id_adresse		INTEGER				,

	nom				VARCHAR(50)		NOT NULL,
	prenom			VARCHAR(50)		NOT NULL,
	adresse_mail	VARCHAR(50)		NOT NULL,
	telephone		VARCHAR(50)				,

	CONSTRAINT pk_client PRIMARY KEY (id_client),

	CONSTRAINT fk_client FOREIGN KEY (id_adresse)
		REFERENCES adresse (id_adresse)
);



-- ============================================================
--   Table : appartenir_a
-- ============================================================

DROP TABLE IF EXISTS appartenir_a CASCADE;
CREATE TABLE appartenir_a
(
    id_client		INTEGER		NOT NULL,
    id_foyer		INTEGER		NOT NULL,

    CONSTRAINT pk_appartenir_a PRIMARY KEY (id_client,id_foyer),

    CONSTRAINT fk1_appartenir_a FOREIGN KEY (id_client)
		REFERENCES client (id_client),
	CONSTRAINT fk2_appartenir_a FOREIGN KEY (id_foyer)
		REFERENCES foyer (id_foyer)
);





-- ============================================================
--   Table : producteur
-- ============================================================

DROP TABLE IF EXISTS producteur CASCADE;
CREATE TABLE producteur
(
    id_producteur	INTEGER		NOT NULL,

    id_adresse		INTEGER		NOT NULL,


		nom         VARCHAR(50)   NOT NULL,
    prenom			VARCHAR(50)		NOT NULL,
    adresse_mail	VARCHAR(50)		NOT NULL,
    telephone		VARCHAR(50)				,
    ordre_reglement	VARCHAR(50)		NOT NULL,

    CONSTRAINT pk_producteur PRIMARY KEY (id_producteur),

    CONSTRAINT fk_producteur FOREIGN KEY (id_adresse)
		REFERENCES adresse (id_adresse)
);


-- ============================================================
--   Table : contrat
-- ============================================================

DROP TABLE IF EXISTS contrat CASCADE;
CREATE TABLE contrat
(
	id_contrat			INTEGER		NOT NULL,

	id_producteur		INTEGER		NOT NULL,

	nb_max_adherents	INTEGER		NOT NULL,
	prix_total			INTEGER		NOT NULL,
	nb_min_paiements	INTEGER		NOT NULL,
	nb_max_paiements	INTEGER		NOT NULL,

	CONSTRAINT pk_contrat PRIMARY KEY (id_contrat),

    CONSTRAINT fk_contrat FOREIGN KEY (id_producteur)
		REFERENCES producteur (id_producteur)

);





-- ============================================================
--   Table : souscrire_a
-- ============================================================

DROP TABLE IF EXISTS souscrire_a CASCADE;
CREATE TABLE souscrire_a
(
	id_foyer			INTEGER		NOT NULL,
	id_contrat			INTEGER		NOT NULL,

	nb_paiements		INTEGER		NOT NULL,
	nb_souscriptions	INTEGER 		NOT NULL,

	CONSTRAINT pk_souscrire_a PRIMARY KEY (id_foyer,id_contrat),

    CONSTRAINT fk1_souscrire_a FOREIGN KEY (id_foyer)
		REFERENCES foyer (id_foyer),
    CONSTRAINT fk2_souscrire_a FOREIGN KEY (id_contrat)
		REFERENCES contrat (id_contrat)

);






-- ============================================================
--   Table : denree
-- ============================================================

DROP TABLE IF EXISTS denree CASCADE;
CREATE TABLE denree
(
	id_denree		INTEGER		NOT NULL,

	nom				VARCHAR(50)		NOT NULL,
	description		VARCHAR(1000)			,
	unite 			VARCHAR(50) 	NOT NULL,

	CONSTRAINT pk_denree PRIMARY KEY(id_denree)
);



-- ============================================================
--   Table : panier
-- ============================================================

DROP TABLE IF EXISTS panier CASCADE;
CREATE TABLE panier
(
	id_panier		INTEGER		NOT NULL,

	nom				VARCHAR(50)				,
	description		VARCHAR(1000)			,

	CONSTRAINT pk_panier PRIMARY KEY(id_panier)
);




-- ============================================================
--   Table : contenir
-- ============================================================

DROP TABLE IF EXISTS contenir CASCADE;
CREATE TABLE contenir
(
	id_panier		INTEGER		NOT NULL,
	id_denree		INTEGER		NOT NULL,

	quantité		INTEGER		NOT NULL,

	CONSTRAINT pk_contenir PRIMARY KEY (id_panier,id_denree),

    CONSTRAINT fk1_contenir FOREIGN KEY (id_panier)
		REFERENCES panier (id_panier),
    CONSTRAINT fk2_contenir FOREIGN KEY (id_denree)
		REFERENCES denree (id_denree)
);




-- ============================================================
--   Table : livraison
-- ============================================================

DROP TABLE IF EXISTS livraison CASCADE;
CREATE TABLE livraison
(
    id_livraison		INTEGER		NOT NULL,

    id_adresse			INTEGER		NOT NULL,
    id_foyer			INTEGER				,

    date_livraison		DATE					,


    CONSTRAINT pk_livraison PRIMARY KEY (id_livraison),

    CONSTRAINT fk1_livraison FOREIGN KEY (id_adresse)
		REFERENCES adresse (id_adresse),
    CONSTRAINT fk2_livraison FOREIGN KEY (id_foyer)
		REFERENCES foyer (id_foyer)
);




-- ============================================================
--   Table : prevision_calendrier
-- ============================================================

DROP TABLE IF EXISTS prevision_calendrier CASCADE;
CREATE TABLE prevision_calendrier
(
    id_contrat		INTEGER		NOT NULL,
    id_livraison 	INTEGER		NOT NULL,
    id_panier 		INTEGER		NOT NULL,

    quantité		INTEGER		NOT NULL,


    CONSTRAINT pk_prevision_calendrier PRIMARY KEY (id_contrat,id_livraison,id_panier),

    CONSTRAINT fk1_prevision_calendrier FOREIGN KEY (id_contrat)
		REFERENCES contrat (id_contrat),
    CONSTRAINT fk2_prevision_calendrier FOREIGN KEY (id_livraison)
		REFERENCES livraison (id_livraison),
	CONSTRAINT fk3_prevision_calendrier FOREIGN KEY (id_panier)
		REFERENCES panier (id_panier)
);







-- ============================================================
-- ============================================================
--   					Triggers
-- ============================================================
-- ============================================================




-- ============================================================
--   Un foyer ne peut pas être volontaire pour une livraison
-- 	 qui ne fait pas partie d'un des contrats pour lesquels
--	 il a souscri.
-- ============================================================

CREATE OR REPLACE FUNCTION volontaire_est_legitime() 
RETURNS TRIGGER AS 
$volontaire_pour_livraison$
BEGIN 

	IF 
		NEW.id_foyer IS NOT NULL 
	AND  
		NOT EXISTS
		(
			SELECT 
				1,	
			FROM 
				prevision_calendrier pc
				JOIN souscrire_a sa 
					USING (id_contrat)
			WHERE 
				sa.id_foyer = NEW.id_foyer
				AND pc.id_livraison = NEW.id_livraison
		)	
	THEN 
		RAISE EXCEPTION 'Le foyer % ne peut pas se porter volontaire pour la livraison %', NEW.id_foyer, NEW.id_livraison ;
	END IF;
	
	RETURN NEW;
	
END;
$volontaire_pour_livraison$
LANGUAGE plpgsql;
	



CREATE TRIGGER volontaire_pour_livraison
(
	BEFORE 
		UPDATE OF id_foyer 	
		OR INSERT 
			ON livraison
	FOR EACH ROW
	EXECUTE PROCEDURE 
		volontaire_est_legitime()
);

		
		
	
		
-- ============================================================
--   Lors de la souscription à un contrat, un foyer
--	 doit indiquer un nombre de paiement situé entre les bornes
-- 	 précisées par le contrat.
-- ============================================================
		
		
	
CREATE OR REPLACE FUNCTION nombre_de_paiements_valide() 
RETURNS TRIGGER AS 
$nombre_de_paiements$
DECLARE 
	nb_min_paiement INTEGER;
	nb_max_paiment INTEGER;
	
BEGIN

	SELECT 
		nb_min_paiements,
		nb_max_paiements 
	INTO 
		nb_min_paiement,
		nb_max_paiment 
	FROM 
		contrat ctr 
	WHERE 
		ctr.id_contrat = NEW.id_contrat;
	
	IF 
		NEW.nb_paiements < nb_min_paiement
		OR NEW.nb_paiements > nb_max_paiment
	THEN 
		RAISE EXCEPTION 'Le foyer % ne peut souscrire au contrat % en % paiements', NEW.id_foyer, NEW.id_contrat, NEW.nb_paiements ;
	END IF ;
	
	RETURN NEW;
	
END;
$nombre_de_paiements$
LANGUAGE plpgsql;
		

DROP TRIGGER IF EXISTS nombre_de_paiements ON souscrire_a;
CREATE TRIGGER nombre_de_paiements
	BEFORE 
		UPDATE OF nb_paiements 
		OR INSERT 
			ON souscrire_a
	FOR EACH ROW
	EXECUTE PROCEDURE 
		nombre_de_paiements_valide();
		
		
		
		
		
		

-- ============================================================
-- Il n'y a pas plus de souscriptions à un contrat que le
-- nombre spécifié dans ce dernier.
-- ============================================================	
	

		
	
CREATE OR REPLACE FUNCTION nombre_de_souscriptions_valide() 
RETURNS TRIGGER AS 
$nombre_de_souscriptions$
DECLARE 
	nb_max_souscription INTEGER;
	nb_actuel INTEGER;
BEGIN

	SELECT
		nb_max_adherents 
	INTO 
		nb_max_souscription 
	FROM 
		contrat ctr 
	WHERE 
		ctr.id_contrat = NEW.id_contrat;
	
		
	SELECT 
		SUM(nb_souscriptions) 
	INTO 
		nb_actuel
	FROM 
		souscrire_a sa 
	WHERE 
		sa.id_contrat = NEW.id_contrat 
		AND sa.id_foyer != NEW.id_foyer ;
		
		
	nb_actuel = COALESCE(nb_actuel,0);
	
	
	IF nb_actuel + NEW.nb_souscriptions > nb_max_souscription
	THEN 
		RAISE EXCEPTION 
			'Le foyer % ne peut souscrire % fois au contrat % car cela dépasse son nombre maximum de souscriptions.', 
			NEW.id_foyer,
			NEW.nb_souscriptions, 
			NEW.id_contrat;
	END IF;
	
	RETURN NEW;
	
END;
$nombre_de_souscriptions$
LANGUAGE plpgsql;
		



DROP TRIGGER IF EXISTS nombre_de_souscriptions ON souscrire_a;
CREATE TRIGGER nombre_de_souscriptions
	BEFORE 
		UPDATE OF nb_souscriptions
		OR INSERT 
			ON souscrire_a
	FOR EACH ROW
	EXECUTE PROCEDURE 
		nombre_de_souscriptions_valide();
		
		
				
				
				
				
				
COMMIT;				
