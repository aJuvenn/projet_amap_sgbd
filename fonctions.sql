-- CONSULTATIONS --

-- Liste des foyers ayant souscrits à un contrat donné

CREATE OR REPLACE FUNCTION liste_foyers_contrat (id_contrat INTEGER)
RETURNS TABLE(id_foyer INTEGER) STABLE AS
$$
  SELECT id_foyer FROM souscrire_a WHERE id_contrat=$1;
$$ LANGUAGE SQL;


-- Liste des livraisons prévues à un mois

CREATE OR REPLACE FUNCTION liste_livraisons_mois (mois INTEGER)
RETURNS TABLE(id_livraison INTEGER) STABLE AS
$$
SELECT id_livraison FROM livraison WHERE EXTRACT( month FROM date_livraison)=$1;
$$ LANGUAGE SQL;


-- Liste des livraisons pour lesquelles personne n'est inscrit

CREATE OR REPLACE FUNCTION liste_livraisons_sans_inscriptions ()
RETURNS TABLE(id_livraison INTEGER) STABLE AS
$$
SELECT id_livraison FROM livraison WHERE id_foyer IS NULL;
$$ LANGUAGE SQL;


-- Calendrier des livraisons de l'ensemble des contrats d'un adhérent donné

CREATE OR REPLACE FUNCTION calendrier_livraisons_contrats_adherent(id_adherent INTEGER)
RETURNS TABLE(id_contrat INTEGER, date_livraison DATE) STABLE AS
$$
SELECT sa.id_contrat, date_livraison FROM souscrire_a sa
JOIN foyer f USING (id_foyer)
JOIN livraison l USING (id_foyer)
WHERE f.id_foyer=$1
ORDER BY date_livraison ASC
$$ LANGUAGE SQL;

-- STATISTIQUES --

-- Liste des foyers, avec pour chaque foyer, son nombre de participations à des distributions pour une année donnée

CREATE OR REPLACE FUNCTION nombre_participations_annee(annee INTEGER)
RETURNS TABLE(id_foyer INTEGER, n_participations BIGINT) STABLE AS
$$
SELECT f.id_foyer, COUNT(DISTINCT id_livraison) AS n_participations FROM foyer f
JOIN livraison USING (id_foyer)
wHERE EXTRACT(year FROM date_livraison)=$1
GROUP BY f.id_foyer
ORDER BY n_participations DESC
$$ LANGUAGE SQL;

-- Tests des fonctions --

SELECT liste_foyers_contrat(2);
SELECT liste_livraisons_mois(11);
SELECT liste_livraisons_sans_inscriptions();
SELECT calendrier_livraisons_contrats_adherent(1);
