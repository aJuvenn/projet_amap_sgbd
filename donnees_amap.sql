-- ============================================================
--    suppression des donnees
-- ============================================================

-- Tables définies par des couples/triplets de clefs étrangères
DELETE FROM prevision_calendrier;
DELETE FROM souscrire_a;
DELETE FROM contenir;
DELETE FROM appartenir_a;

-- Tables référencées par les tables précédentes
DELETE FROM denree;
DELETE FROM panier;
DELETE FROM livraison;
DELETE FROM client;
DELETE FROM foyer;
DELETE FROM contrat;
DELETE FROM producteur;
DELETE FROM adresse;

commit ;

-- ============================================================
--    creation des donnees
-- ============================================================

-- adresse

INSERT INTO adresse VALUES (1 , 'France', 'Roquefort-sur-Soulzon', '12250', '12', 'rue des Baragnaudes') ;

commit ;

-- producteur

INSERT INTO producteur VALUES (1 , 1, 'Roquefort', 'Jean', '0464646464', '12', 'Mr Roquefort') ;

commit ;

-- contrat

INSERT INTO contrat VALUES (1 , 1, 50, 200, 1, 4) ;

commit ;

-- ============================================================
--    verification des donnees
-- ============================================================

/*
select count(*),'= 37 ?','ACTEUR' from ACTEUR
union
select count(*),'= 20 ?','FILM' from FILM
union
select count(*),'= 14 ?','REALISATEUR' from REALISATEUR
union
select count(*),'= 40 ?','ROLE' from ROLE ;
*/
