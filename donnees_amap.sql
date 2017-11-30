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

commit;

-- ============================================================
--    creation des donnees
-- ============================================================

-- adresse

INSERT INTO adresse VALUES (1 , 'France', 'Roquefort-sur-Soulzon', '12250', '12', 'rue des Baragnaudes');
INSERT INTO adresse VALUES (2 , 'France', 'Bordeaux', '33000', '127', 'rue Pizza Saint-Genès');
INSERT INTO adresse VALUES (3 , 'France', 'Talence', '33400', '1', 'avenue du Dr Albert Schweitzer');
INSERT INTO adresse VALUES (4 , 'Autriche', 'Salzburg', '00000', '7', 'boulevard des Turcs');

commit;

-- producteur

INSERT INTO producteur VALUES (1 , 1, 'Bonneau', 'Jean', 'jeannot@laposte.net', '0777777777','M Roquefort');
INSERT INTO producteur VALUES (1 , 4, 'Ella', 'Mozart', 'wolfgang@amadeus.req', '0654321000','Figaro');

commit;

-- contrat

INSERT INTO contrat VALUES (1 , 1, 50, 200, 1, 4);
INSERT INTO contrat VALUES (2 , 2, 40, 180, 2, 3);

commit;

-- foyer

INSERT INTO foyer VALUES (1 , 3, 'Eirb', 'On brasse', 'eirb@enseirb-matmeca.fr', '0556565656');
INSERT INTO foyer VALUES (2 , 2, 'Pizza-flat', 'Superbe villa', 'arseneleboss@gmail.com', '0464646464');

commit;

-- client

INSERT INTO client VALUES (1 , 2, 'Volte', 'Arsène', 'arseneleboss@gmail.com' ,'0666666666');

commit;

-- livraison

INSERT INTO livraison VALUES (1, 2, 1, '2017-11-27 10:30:00');

commit;

-- panier

INSERT INTO panier VALUES (1, 'terroir occitan', 'contient un ensemble de produits traditionnels du Midi');
INSERT INTO panier VALUES (2, 'terroir auvergnat', 'contient un ensemble de produits traditionnels d Auvergne');

commit;

-- denree

-- Midi-Pyrénées
INSERT INTO denree VALUES (1, 'foie gras', 'incontournable de la gastronomie occitane', 'g');
INSERT INTO denree VALUES (2, 'haricot', 'Tarbais', 'g');
INSERT INTO denree VALUES (3, 'raisin', 'Chasselas', 'g');
INSERT INTO denree VALUES (4, 'melon', 'du Quercy', 'u');
INSERT INTO denree VALUES (5, 'prune', 'Reine-Claude', 'g');
INSERT INTO denree VALUES (6, 'noix', 'Périgord', 'g');
INSERT INTO denree VALUES (7, 'roquefort', 'issue des caves Papillon', 'g');
INSERT INTO denree VALUES (8, 'bleu', 'des Causses', 'g');
INSERT INTO denree VALUES (9, 'Laguiole', '', 'g');
INSERT INTO denree VALUES (10, 'Rocamadour', '', 'g');

-- Auvergne
INSERT INTO denree VALUES (11, 'Cantal', '', 'g');
INSERT INTO denree VALUES (12, 'Salers', '', 'g');
INSERT INTO denree VALUES (13, 'Saint-Nectaire', '', 'g');
INSERT INTO denree VALUES (14, 'lentille verte', 'du Puy-en-Velay', 'g');
INSERT INTO denree VALUES (15, 'verveine', '', 'u');
INSERT INTO denree VALUES (16, 'liqueur de Gentiane', 'marque : Salers', 'u');
INSERT INTO denree VALUES (17, 'terrines de campagne', 'une flopée de gôuts différents', 'u');
INSERT INTO denree VALUES (18, 'Bleu', 'd Auvergne', 'g');

commit;

-- appartenir_a

INSERT INTO appartenir_a VALUES (1, 2);

commit;

-- contenir

-- panier 1
INSERT INTO contenir VALUES (1, 1, 100);
INSERT INTO contenir VALUES (1, 2, 300);
INSERT INTO contenir VALUES (1, 5, 200);
-- panier 2
INSERT INTO contenir VALUES (2, 3, 400);
INSERT INTO contenir VALUES (2, 8, 100);
INSERT INTO contenir VALUES (2, 4, 2);
-- panier 3
INSERT INTO contenir VALUES (3, 9, 130);
INSERT INTO contenir VALUES (3, 6, 400);
INSERT INTO contenir VALUES (3, 10, 180);
INSERT INTO contenir VALUES (3, 1, 100);
-- panier 4
INSERT INTO contenir VALUES (4, 11, 200);
INSERT INTO contenir VALUES (4, 15, 1);
INSERT INTO contenir VALUES (4, 14, 300);
INSERT INTO contenir VALUES (4, 17, 3);

commit;


-- souscrire_a

INSERT INTO souscrire_a VALUES (1, 1, 3, 20);
INSERT INTO souscrire_a VALUES (2, 2, 4, 30);

commit;

-- prevision_calendrier

INSERT INTO prevision_calendrier VALUES (1, 1, 1, 3);

commit;

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
