-- ============================================================
--   Nom de la base   :  AMAP                                
--   Nom de SGBD      :  ORACLE Version 7.0                    
--   Date de creation :  18/11/17                       
-- ============================================================



-- ============================================================
--   Table : adresse                                       
-- ============================================================

DROP TABLE IF EXISTS adresse;
CREATE TABLE adresse
(
	id_adresse	NUMBER(10)	NOT NULL,
	pays		VARCHAR(50)	NOT NULL,
	ville		VARCHAR(50)	NOT NULL,
	code_postal	VARCHAR(50)	NOT NULL,
	rue		VARCHAR(50)	NOT NULL,
	numero_rue	VARCHAR(50)	NOT NULL,

	CONSTRAINT pk_adresse PRIMARY KEY (id_adresse)
);






-- ============================================================
--   Table : foyer                                            
-- ============================================================

DROP TABLE IF EXISTS foyer;
CREATE TABLE foyer
(
	id_foyer	NUMBER(10)	NOT NULL,
	
	id_adresse	NUMBER(10)		,
	
	nom		VARCHAR(50)		,
	description	VARCHAR(1000)		,
	adresse_mail	VARCHAR(50)		,
	telephone	VARCHAR(50)		,

	CONSTRAINT pk_foyer PRIMARY KEY (id_foyer)
);



-- ============================================================
--   Table : client                                       
-- ============================================================

DROP TABLE IF EXISTS client;
CREATE TABLE client
(
	id_client	NUMBER(10)	NOT NULL,
	
	id_adresse	NUMBER(10)		,
	
	nom		VARCHAR(50)	NOT NULL,
	prenom		VARCHAR(50)	NOT NULL,
	adresse_mail	VARCHAR(50)	NOT NULL,
	telephone	VARCHAR(50)		,

	CONSTRAINT pk_client PRIMARY KEY (id_client)
);



-- ============================================================
--   Table : appartenir_a                                              
-- ============================================================

DROP TABLE IF EXISTS appartenir_a;
CREATE TABLE appartenir_a
(
    id_client	NUMBER(10)	NOT NULL,
    id_foyer	NUMBER(10)	NOT NULL
);





-- ============================================================
--   Table : producteur                                              
-- ============================================================

DROP TABLE IF EXISTS producteur;
CREATE TABLE producteur
(
    id_producteur	NUMBER(10)	NOT NULL,
    
    id_adresse		NUMBER(10)	NOT NULL,
    
    prenom		VARCHAR(50)	NOT NULL,
    adresse_mail	VARCHAR(50)	NOT NULL,
    telephone		VARCHAR(50)		,
    ordre_reglement	VARCHAR(50)	NOT NULL,

    CONSTRAINT pk_producteur PRIMARY KEY (id_producteur)
);


-- ============================================================
--   Table : contrat       
-- ============================================================


DROP TABLE IF EXISTS contrat;
CREATE TABLE contrat
(
	id_contrat		NUMBER(10)	NOT NULL,

	id_producteur		NUMBER(10)	NOT NULL,

	nb_max_adherents	NUMBER(10)	NOT NULL,
	prix_total		NUMBER(10)	NOT NULL,
	nb_min_paiements	NUMBER(10)	NOT NULL,
	nb_max_paiements	NUMBER(10)	NOT NULL,

	CONSTRAINT pk_contrat PRIMARY KEY (id_contrat)
);
	
