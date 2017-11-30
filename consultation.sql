CREATE OR REPLACE FUNCTION liste_foyers (id_contrat INTEGER)
RETURNS TABLE(id_foyer INTEGER) AS
$$
  SELECT id_foyer FROM souscrire_a WHERE id_contrat=$1;
$$ LANGUAGE sql;
