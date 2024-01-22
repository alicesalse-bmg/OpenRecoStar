--CONTROLES TOPO
DROP TABLE IF EXISTS generate_series;
CREATE TABLE generate_series(
  value
);

WITH RECURSIVE
  cnt(x) AS (VALUES(1) UNION ALL SELECT x+1 FROM cnt WHERE x<1000)
INSERT INTO generate_series SELECT x FROM cnt;

SELECT value FROM generate_series;

--XXX NOEUD / CABLE
DROP VIEW IF EXISTS ctrl_Noeud_Cable;
CREATE VIEW ctrl_Noeud_Cable AS
with all_ctrl as(

SELECT id, 'il manque un Noeud à l''extrémité de ce Cable' ctrl, ST_StartPoint(CastToXY("Geometrie")) Geometrie
FROM RPD_CableElectrique_Reco c
WHERE NOT EXISTS (SELECT 1 FROM Noeud_Cable cn WHERE cn.cable_id=c.id and cn.connpt = 'StartPoint' )
AND NOT EXISTS (SELECT 1 FROM Conteneur_Cable cc
                          JOIN Conteneur_Noeud cn ON cc.conteneur_id=cn.conteneur_id
                          WHERE cc.cable_id=c.id AND cc.connpt = 'StartPoint' )
UNION ALL
SELECT id, 'il manque un Noeud à l''extrémité de ce Cable' ctrl, ST_EndPoint(CastToXY("Geometrie")) Geometrie
FROM RPD_CableElectrique_Reco c
WHERE NOT EXISTS (SELECT 1 FROM Noeud_Cable cn WHERE cn.cable_id=c.id and cn.connpt = 'EndPoint' )
AND NOT EXISTS (SELECT 1 FROM Conteneur_Cable cc
                          JOIN Conteneur_Noeud cn ON cc.conteneur_id=cn.conteneur_id
                          WHERE cc.cable_id=c.id AND cc.connpt = 'EndPoint' )

UNION ALL
SELECT noeud_id id, 'ce type de Noeud n''est pas autorisé à l''extrémité d''un Cable Electrique' ctrl, CastToXY(n."Geometrie") Geometrie
FROM Noeud_Cable cn
JOIN Noeud n ON n.id=cn.noeud_id
WHERE type_cable = 'CableElectrique' and cn.type_noeud not in ('Plage', 'OuvrageCollectifBranchement', 'PointDeComptage', 'PosteElectrique', 'RaccordementModulaire', 'JeuBarres', 'Jonction')

UNION ALL
SELECT n.id, 'le Domaine Tension de la Jonction n''est pas cohérent avec celui du Cable Electrique' ctrl, CastToXY(n."Geometrie") Geometrie
FROM RPD_Jonction_Reco n
JOIN Noeud_Cable cn on cn.noeud_id=n.id
JOIN RPD_CableElectrique_Reco c on c.id=cn.cable_id
WHERE n.DomaineTension <> c.DomaineTension

UNION ALL
SELECT n.id, 'ce Noeud n''est pas positionné à l''extrémité d''un Cable' ctrl, CastToXY(n.Geometrie) Geometrie
FROM Noeud n
WHERE NOT EXISTS (SELECT 1 FROM Noeud_Cable cn WHERE cn.noeud_id=n.id)
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn
                          JOIN Conteneur_Cable cc on cc.conteneur_id=cn.conteneur_id
                          WHERE cn.noeud_id=n.id) -- QUESTION : exceptions ? jeu de barre doit etre positionné sur le CableElectrique meme si dans un Conteneur?

UNION ALL
SELECT n.id, 'ce Noeud ne coupe pas le Cable' ctrl,CastToXY(n.Geometrie) Geometrie
FROM Noeud n
JOIN Cable c ON PtDistWithin(n."Geometrie",c."Geometrie", 0.002)
WHERE NOT EXISTS (SELECT 1 FROM Noeud_Cable cn WHERE cn.cable_id=c.id and cn.noeud_id=n.id )

) select ROW_NUMBER () OVER () pkid, * from all_ctrl
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('ctrl_Noeud_Cable','features','ctrl_Noeud_Cable',2154);
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('ctrl_Noeud_Cable', 'Geometrie', 'POINT', 2154, 0, 0);

--XXX CHEMINEMENT / CABLE
DROP VIEW IF EXISTS ctrl_Cheminement_Cable;
CREATE VIEW ctrl_Cheminement_Cable AS -- QUESTION : peut arriver dans quels cas?
SELECT id, 'aucun Cable ne passe dans ce Cheminement' ctrl, CastToXY(h.Geometrie) Geometrie
FROM Cheminement h
WHERE NOT EXISTS (SELECT 1 FROM Cable c where ST_Within(h."Geometrie", c."Geometrie"));

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ctrl_Cheminement_Cable','features','ctrl_Cheminement_Cable');
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('ctrl_Cheminement_Cable', 'Geometrie', 'LINESTRING', 2154, 0, 0);


--XXX NOEUD / CONTENEUR
DROP VIEW IF EXISTS ctrl_Noeud_Conteneur;
CREATE VIEW ctrl_Noeud_Conteneur AS
with all_ctrl as(

SELECT n.id, 'ce Poste Electrique n''est pas contenu dans un Batiment Technique' ctrl, CastToXY(n.Geometrie) Geometrie
FROM RPD_PosteElectrique_Reco n
WHERE Categorie_href not in ('PosteSource') and TypePoste_href not in ('H6')
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id AND cn.type_conteneur = 'BatimentTechnique')

UNION ALL
SELECT n.id, 'ce Poste Source n''est pas contenu dans une Enceinte Cloturee' ctrl, CastToXY(n.Geometrie) Geometrie
FROM RPD_PosteElectrique_Reco n
WHERE Categorie_href in ('PosteSource')
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id AND cn.type_conteneur = 'EnceinteCloturee')

UNION ALL
SELECT n.id, 'ce Poste Electrique n''est pas placé sur un Support' ctrl, CastToXY(n.Geometrie) Geometrie
FROM RPD_PosteElectrique_Reco n
WHERE TypePoste_href in ('H6')
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id AND cn.type_conteneur = 'Support')

UNION ALL
SELECT n.id, 'ce noeud '||type_noeud||' n''est pas contenu dans un Coffret' ctrl, CastToXY(n.Geometrie) Geometrie
FROM Noeud n
WHERE type_noeud in ('RaccordementModulaire', 'JeuBarres', 'Plage')
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id AND cn.type_conteneur = 'Coffret')

UNION ALL
SELECT n.id, 'les '||n.type_noeud||' ne sont autorisées que dans les Coffrets Manoeuvrables' ctrl, CastToXY(n.Geometrie) Geometrie
FROM Noeud n
JOIN Conteneur_Noeud cn ON cn.noeud_id=n.id
JOIN RPD_Coffret_Reco c ON c.id=cn.conteneur_id
WHERE n.type_noeud in ('Plage') AND cn.type_conteneur='Coffret' AND NOT c.FonctionCoffret_href = 'Manoeuvrable'

UNION ALL
SELECT n.id, 'cette RAS n''est pas placé sur un Support' ctrl, CastToXY(n.Geometrie) Geometrie
FROM RPD_Jonction_Reco n
WHERE TypeJonction in ('RAS')
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id AND cn.type_conteneur = 'Support')

UNION ALL
SELECT n.id, 'la précison XY / Z de ce noeud '||type_noeud||' n''est pas renseignée' ctrl, CastToXY(n.Geometrie) Geometrie
FROM Noeud n
WHERE (PrecisionXY is Null OR PrecisionZ is Null)
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=n.id)

) select ROW_NUMBER () OVER () pkid, * from all_ctrl
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('ctrl_Noeud_Conteneur','features','ctrl_Noeud_Conteneur',2154);
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('ctrl_Noeud_Conteneur', 'Geometrie', 'POINT', 2154, 0, 0);

-- XXX PTRL
DROP VIEW IF EXISTS ctrl_PLOR_Ouvrage;
CREATE VIEW ctrl_PLOR_Ouvrage AS
with all_ctrl as(

select p.id, 'ce Point Levé n''est pas placé sur le tracé d''un Ouvrage' ctrl, CastToXY(p.Geometrie) Geometrie
from RPD_PointLeveOuvrageReseau_Reco p
WHERE NOT EXISTS (select 1 from Cheminement c where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
AND NOT EXISTS (select 1 from Cable c where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
AND NOT EXISTS (select 1 from Noeud c where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
AND NOT EXISTS (select 1 from Conteneur c where PtDistWithin(c.Geometrie, p.Geometrie, 0.002) and type_conteneur in ('Support', 'Coffret'))
AND NOT EXISTS (select 1 from RPD_GeometrieSupplementaire_Reco c where PtDistWithin(c."Ligne2.5D", p."Geometrie", 0.002))

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002))
      AND NOT EXISTS (select 1 from RPD_GeometrieSupplementaire_Reco g where PtDistWithin(ST_PointN(c.Geometrie, s.value), g."Ligne2.5D", 0.002))
          THEN 'le sommet de ce Cable n''est pas placé sur un Point Levé'
          --ok si il arrive sur l'emprise d'un conteneur
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c.Geometrie, s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du sommet de ce Cable n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c.Geometrie, s.value) Geometrie
FROM cable c
, generate_series s ON s.value <= ST_NumPoints(c.Geometrie)
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002))
      AND NOT EXISTS (select 1 from RPD_GeometrieSupplementaire_Reco g where PtDistWithin(ST_PointN(c.Geometrie, s.value), g."Ligne2.5D", 0.002))
          THEN 'le sommet de ce Cheminement n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c.Geometrie, s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du sommet de ce Cheminement n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c.Geometrie, s.value) Geometrie
FROM Cheminement c
, generate_series s ON s.value <= ST_NumPoints(c.Geometrie)
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c."Ligne2.5D", s.value), p.Geometrie, 0.002))
          THEN 'le sommet de ce Conteneur n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c."Ligne2.5D", s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c."Ligne2.5D", s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du sommet de ce Conteneur n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c."Ligne2.5D", s.value) Geometrie
FROM RPD_GeometrieSupplementaire_Reco c
, generate_series s ON s.value <= ST_NumPoints(c."Ligne2.5D")
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and type_conteneur in ('BatimentTechnique', 'EnceinteCloturee') and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
          THEN 'ce '||type_conteneur||' n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002)
                                                            AND NOT ST_Z(c.Geometrie) = st_Z(p.Geometrie))
          THEN 'le Z du '||type_conteneur||' n''est pas cohérent avec le Point Levé'
end ctrl
,c.Geometrie
FROM Conteneur c
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and type_conteneur in ('Support', 'Coffret') and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
          THEN 'ce noeud '||type_noeud||' n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002)
                                                            AND NOT ST_Z(c.Geometrie) = st_Z(p.Geometrie))
          THEN 'le Z du noeud '||type_noeud||' n''est pas cohérent avec le Point Levé'
end ctrl
,c.Geometrie
FROM Noeud c
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn WHERE cn.noeud_id=c.id)

) select ROW_NUMBER () OVER () pkid, * from all_ctrl
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('ctrl_PLOR_Ouvrage','features','ctrl_PLOR_Ouvrage',2154);
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('ctrl_PLOR_Ouvrage', 'Geometrie', 'POINT', 2154, 0, 0);

-- TODO :
--- voir regles PGOC UN PTRL tous les 15m et suffisament dans les courbes
-- CONTROLE CHEMINEMENT AERIEN / SUPPORT
-- Verifs classe precision si NOEUD pas dans CONTENEUR
-- VOIR REGLES RELATIVES A LA TERRE :
--    - un cable de terre doit avoir au moins 1 noeud de terre à une de ses extrémités


-- TODO Métier :
---- ordonner les listes
---- voir les valeurs par defaut
---- symbologie des réseaux
