-- ============================================================
--   Nom de la base   :  AMAP
--   Nom de SGBD      :  ORACLE Version 7.0
--   Date de creation :  18/11/17
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