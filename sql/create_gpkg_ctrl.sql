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
WHERE NOT EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_StartPoint(c."Geometrie")) )
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn, Noeud n, RPD_GeometrieSupplementaire_Conteneur_Reco gs WHERE cn.noeud_id=n.id and cn.conteneur_id=gs.id and (PtDistWithin(gs."Ligne2.5D", ST_StartPoint(c."Geometrie"), 0.002) OR PtDistWithin(gs."Surface2.5D", ST_StartPoint(c."Geometrie"), 0.002)))
UNION ALL
SELECT id, 'il manque un Noeud à l''extrémité de ce Cable' ctrl, ST_EndPoint(CastToXY("Geometrie")) Geometrie
FROM RPD_CableElectrique_Reco c
WHERE NOT EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_EndPoint(c."Geometrie")) )
AND NOT EXISTS (SELECT 1 FROM Conteneur_Noeud cn, Noeud n, RPD_GeometrieSupplementaire_Conteneur_Reco gs WHERE cn.noeud_id=n.id and cn.conteneur_id=gs.id and (PtDistWithin(gs."Ligne2.5D", ST_EndPoint(c."Geometrie"), 0.002) OR PtDistWithin(gs."Surface2.5D", ST_EndPoint(c."Geometrie"), 0.002)))

UNION ALL
SELECT id, 'ce type de Noeud n''est pas autorisé à l''extrémité d''un Cable Electrique' ctrl, ST_StartPoint( CastToXY("Geometrie") ) Geometrie
FROM RPD_CableElectrique_Reco c
WHERE EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_StartPoint(c."Geometrie")) and type_noeud not in ('Plage', 'OuvrageCollectifBranchement', 'PointDeComptage', 'PosteElectrique', 'RaccordementModulaire', 'JeuBarres', 'Jonction'))
UNION ALL
SELECT id, 'ce type de Noeud n''est pas autorisé à l''extrémité d''un Cable Electrique' ctrl, ST_EndPoint( CastToXY("Geometrie") ) Geometrie
FROM RPD_CableElectrique_Reco c
WHERE EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_EndPoint(c."Geometrie"))  and type_noeud not in ('Plage', 'OuvrageCollectifBranchement', 'PointDeComptage', 'PosteElectrique', 'RaccordementModulaire', 'JeuBarres', 'Jonction'))

UNION ALL
SELECT id, 'le Domaine Tension de la Jonction n''est pas cohérent avec celui du Cable Electrique' ctrl, CastToXY("Geometrie") Geometrie
FROM RPD_Jonction_Reco n
WHERE EXISTS (SELECT 1 FROM RPD_CableElectrique_Reco c WHERE ( ST_Intersects(n."Geometrie",ST_StartPoint(c."Geometrie")) OR ST_Intersects(n."Geometrie",ST_EndPoint(c."Geometrie")) ) AND n.DomaineTension <> c.DomaineTension )

UNION ALL
SELECT id, 'ce type de Noeud n''est pas autorisé à l''extrémité d''un Cable de Terre' ctrl, ST_StartPoint( CastToXY("Geometrie") ) Geometrie
FROM RPD_CableTerre_Reco c
WHERE EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_StartPoint(c."Geometrie")) and type_noeud not in ('Terre'))
UNION ALL
SELECT id, 'ce type de Noeud n''est pas autorisé à l''extrémité d''un Cable de Terre' ctrl, ST_EndPoint( CastToXY("Geometrie") ) Geometrie
FROM RPD_CableTerre_Reco c
WHERE EXISTS (SELECT 1 FROM Noeud n WHERE ST_Intersects(n."Geometrie",ST_EndPoint(c."Geometrie"))  and type_noeud not in ('Terre'))

UNION ALL
SELECT n.id, 'ce Noeud n''est pas positionné à l''extrémité d''un Cable' ctrl, CastToXY(n.Geometrie) Geometrie
FROM Noeud n
WHERE NOT EXISTS (SELECT 1 FROM Cable c WHERE PtDistWithin(n."Geometrie",c."Geometrie", 0.002) )

UNION ALL
SELECT n.id, 'ce Noeud ne coupe pas le Cable' ctrl,CastToXY(n.Geometrie) Geometrie
FROM Noeud n
WHERE EXISTS (SELECT 1 FROM Cable c WHERE PtDistWithin(n."Geometrie",c."Geometrie", 0.002) and not ST_Intersects(n."Geometrie",ST_StartPoint(c."Geometrie")) and not  ST_Intersects(n."Geometrie",ST_EndPoint(c."Geometrie")) )

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

SELECT n.id, 'ce Poste Electrique n''est pas contenu dans un Batiment Technique' ctrl, CastToXY(n.Geometrie) Geometrie FROM RPD_PosteElectrique_Reco n WHERE Categorie not in ('PosteSource') and TypePoste not in ('H6') AND NOT EXISTS (SELECT 1 FROM RPD_GeometrieSupplementaire_Conteneur_Reco c WHERE (PtDistWithin(c."Ligne2.5D", n."Geometrie", 0.002) OR PtDistWithin(c."Surface2.5D", n."Geometrie", 0.002)) AND type_conteneur = 'BatimentTechnique')

UNION ALL
SELECT n.id, 'ce Poste Source n''est pas contenu dans une Enceinte Cloturee' ctrl, CastToXY(n.Geometrie) Geometrie FROM RPD_PosteElectrique_Reco n WHERE Categorie in ('PosteSource') AND NOT EXISTS (SELECT 1 FROM RPD_GeometrieSupplementaire_Conteneur_Reco c WHERE (PtDistWithin(c."Ligne2.5D", n."Geometrie", 0.002) OR PtDistWithin(c."Surface2.5D", n."Geometrie", 0.002)) AND type_conteneur = 'EnceinteCloturee')

UNION ALL
SELECT n.id, 'ce Poste Electrique n''est pas placé sur un Support' ctrl, CastToXY(n.Geometrie) Geometrie FROM RPD_PosteElectrique_Reco n WHERE TypePoste in ('H6') AND NOT EXISTS (SELECT 1 FROM Conteneur c WHERE PtDistWithin(c."Geometrie", n."Geometrie", 0.002) AND type_conteneur = 'Support')

UNION ALL
SELECT n.id, 'ce '||type_noeud||' n''est pas contenu dans un Coffret' ctrl, CastToXY(n.Geometrie) Geometrie FROM Noeud n WHERE type_noeud in ('RaccordementModulaire', 'JeuBarres', 'PlageConnexion') AND NOT EXISTS (SELECT 1 FROM RPD_GeometrieSupplementaire_Conteneur_Reco c WHERE (PtDistWithin(c."Ligne2.5D", n."Geometrie", 0.002) OR PtDistWithin(c."Surface2.5D", n."Geometrie", 0.002)) AND type_conteneur = 'Coffret')

-- TODO : PlageConnexion dans Coffret Manoeuvrable uniquement

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
AND NOT EXISTS (select 1 from Conteneur c where PtDistWithin(c.Geometrie, p.Geometrie, 0.002) and type_conteneur = 'Support')
AND NOT EXISTS (select 1 from RPD_GeometrieSupplementaire_Conteneur_Reco c where PtDistWithin(c."Ligne2.5D", p."Geometrie", 0.002))

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002))
          THEN 'le Vertex de ce Cable n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c.Geometrie, s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du Vertex de ce Cable n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c.Geometrie, s.value) Geometrie
FROM cable c
, generate_series s ON s.value <= ST_NumPoints(c.Geometrie)
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002))
          THEN 'le Vertex de ce Cheminement n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c.Geometrie, s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c.Geometrie, s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du Vertex de ce Cheminement n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c.Geometrie, s.value) Geometrie
FROM Cheminement c
, generate_series s ON s.value <= ST_NumPoints(c.Geometrie)
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c."Ligne2.5D", s.value), p.Geometrie, 0.002))
          THEN 'le Vertex de cet Ouvrage n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(ST_PointN(c."Ligne2.5D", s.value), p.Geometrie, 0.002)
                                                            AND NOT ST_Z(ST_PointN(c."Ligne2.5D", s.value)) = st_Z(p.Geometrie))
          THEN 'le Z du Vertex de cet Ouvrage n''est pas cohérent avec le Point Levé'
end ctrl
,ST_PointN(c."Ligne2.5D", s.value) Geometrie
FROM RPD_GeometrieSupplementaire_Conteneur_Reco c
, generate_series s ON s.value <= ST_NumPoints(c."Ligne2.5D")
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and type_conteneur in ('BatimentTechnique', 'EnceinteCloturee') and ctrl is not null

UNION ALL --QUESTION : Z coffret ? mettre Z sur tous les vertex ?
SELECT c.id, 'l''emprise de ce Coffret n''est pas placée sur un Point Levé' ctrl, ST_StartPoint(c."Ligne2.5D") Geometrie
FROM RPD_GeometrieSupplementaire_Conteneur_Reco c
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and type_conteneur in ('Coffret')
AND NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c."Ligne2.5D", p.Geometrie, 0.002))

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
          THEN 'ce Support n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002)
                                                            AND NOT ST_Z(c.Geometrie) = st_Z(p.Geometrie))
          THEN 'le Z du Support n''est pas cohérent avec le Point Levé'
end ctrl
,c.Geometrie
FROM Conteneur c
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and type_conteneur in ('Support') and ctrl is not null

UNION ALL
SELECT c.id
,CASE WHEN NOT EXISTS (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002))
          THEN 'ce '||type_noeud||' n''est pas placé sur un Point Levé'
      WHEN (select 1 from RPD_PointLeveOuvrageReseau_Reco p where PtDistWithin(c.Geometrie, p.Geometrie, 0.002)
                                                            AND NOT ST_Z(c.Geometrie) = st_Z(p.Geometrie))
          THEN 'le Z du '||type_noeud||' n''est pas cohérent avec le Point Levé'
end ctrl
,c.Geometrie
FROM Noeud c
WHERE PrecisionXY = 'A' and PrecisionZ = 'A' and ctrl is not null

) select ROW_NUMBER () OVER () pkid, * from all_ctrl
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('ctrl_PLOR_Ouvrage','features','ctrl_PLOR_Ouvrage',2154);
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('ctrl_PLOR_Ouvrage', 'Geometrie', 'POINT', 2154, 0, 0);

-- TODO :
--- voir regles PGOC UN PTRL tous les 15m et suffisament dans les courbes
-- CONTROLE CHEMINEMENT AERIEN / SUPPORT
-- Verifs classe precision si NOEUD pas dans CONTENEUR
-- VOIR REGLES RELATIVES A LA TERRE


-- QUESTION :
-- quel est le z pour le coffret par exemple ?


-- TODO Métier :
---- ordonner les listes
---- voir les valeurs par defaut
---- symbologie des réseaux
