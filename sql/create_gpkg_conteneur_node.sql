-- select load_extension("/usr/local/lib/mod_spatialite.dylib");
-- SELECT EnableGpkgMode(); --GPKG
---XXX Conteneur

--XXX RPD_BatimentTechnique_Reco

DROP TABLE IF EXISTS RPD_BatimentTechnique_Reco_line;
CREATE TABLE RPD_BatimentTechnique_Reco_line (
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_BatimentTechnique_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie MULTILINESTRINGZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, geometriesupplementaire_href TEXT NOT NULL DEFAULT (CreateUUID())
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_BatimentTechnique_Reco_line','features','RPD_BatimentTechnique_Reco_line',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_BatimentTechnique_Reco_line', 'Geometrie', 'MULTILINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_BatimentTechnique_Reco_line', 'Geometrie' );

DROP VIEW IF EXISTS RPD_BatimentTechnique_Reco;
CREATE VIEW RPD_BatimentTechnique_Reco as
select fid, ogr_pkid, id, ST_Centroid(Geometrie) Geometrie, PrecisionXY, PrecisionZ
from RPD_BatimentTechnique_Reco_line;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_BatimentTechnique_Reco','features','RPD_BatimentTechnique_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_BatimentTechnique_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS RPD_BatimentTechnique_Reco_reseau_reseau;
CREATE VIEW RPD_BatimentTechnique_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_BatimentTechnique_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_BatimentTechnique_Reco_reseau_reseau','attributes','RPD_BatimentTechnique_Reco_reseau_reseau'); --GPKG

DROP VIEW IF EXISTS RPD_BatimentTechnique_Reco_geometriesupplementaire;
CREATE VIEW RPD_BatimentTechnique_Reco_geometriesupplementaire as
select fid, c.ogr_pkid ogr_pkid, c.ogr_pkid parent_ogr_pkid
, geometriesupplementaire_href href
, cast(null as text) geometriesupplementair_rpd_geometriesupplementaire_reco_pkid
 from RPD_BatimentTechnique_Reco_line c ;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_BatimentTechnique_Reco_geometriesupplementaire','attributes','RPD_BatimentTechnique_Reco_geometriesupplementaire'); --GPKG

--XXX RPD_EnceinteCloturee_Reco

DROP TABLE IF EXISTS RPD_EnceinteCloturee_Reco_line;
CREATE TABLE RPD_EnceinteCloturee_Reco_line(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_EnceinteCloturee_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie MULTILINESTRINGZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, geometriesupplementaire_href TEXT NOT NULL DEFAULT (CreateUUID())
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_EnceinteCloturee_Reco_line','features','RPD_EnceinteCloturee_Reco_line',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_EnceinteCloturee_Reco_line', 'Geometrie', 'MULTILINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_EnceinteCloturee_Reco_line', 'Geometrie' );

DROP VIEW IF EXISTS RPD_EnceinteCloturee_Reco;
CREATE VIEW RPD_EnceinteCloturee_Reco as
select fid, ogr_pkid, id, ST_Centroid(Geometrie) Geometrie, PrecisionXY, PrecisionZ
from RPD_EnceinteCloturee_Reco_line;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_EnceinteCloturee_Reco','features','RPD_EnceinteCloturee_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_EnceinteCloturee_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS RPD_EnceinteCloturee_Reco_reseau_reseau;
CREATE VIEW RPD_EnceinteCloturee_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_EnceinteCloturee_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_EnceinteCloturee_Reco_reseau_reseau','attributes','RPD_EnceinteCloturee_Reco_reseau_reseau'); --GPKG

DROP VIEW IF EXISTS RPD_EnceinteCloturee_Reco_geometriesupplementaire;
CREATE VIEW RPD_EnceinteCloturee_Reco_geometriesupplementaire as
select fid, c.ogr_pkid ogr_pkid, c.ogr_pkid parent_ogr_pkid
, geometriesupplementaire_href href
, cast(null as text) geometriesupplementair_rpd_geometriesupplementaire_reco_pkid
from RPD_EnceinteCloturee_Reco_line c ;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_EnceinteCloturee_Reco_geometriesupplementaire','attributes','RPD_EnceinteCloturee_Reco_geometriesupplementaire'); --GPKG

--XXX RPD_Coffret_Reco

DROP TABLE IF EXISTS ImplantationArmoireValue;
CREATE TABLE ImplantationArmoireValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ImplantationArmoireValue VALUES
  ('Encastree', 'Encastrée')
, ('IntegreeDansLocal', 'Intégrée dans le local')
, ('Saillie', 'Saillie')
, ('SurSocleAluminium', 'Sur socle en aluminium')
, ('SurSocleBeton', 'Sur socle béton')
, ('SurSoclePolyester', 'Sur socle polyester')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ImplantationArmoireValue','attributes','ImplantationArmoireValue'); --GPKG

DROP TABLE IF EXISTS TypeCoffretValue;
CREATE TABLE TypeCoffretValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO TypeCoffretValue VALUES
  ('RMBT300','Coffret RMBT 300 (6 plages)')
, ('RMBT450','Coffret RMBT 450 (9 plages)')
, ('RMBT600','Coffret RMBT 600 (12 plages)')
, ('CIBE','Coffret Individuel de Branchement Electrique')
, ('ECP','Coffret ECP2D ou ECP3D')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('TypeCoffretValue','attributes','TypeCoffretValue'); --GPKG

DROP TABLE IF EXISTS FonctionCoffretValue;
CREATE TABLE FonctionCoffretValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO FonctionCoffretValue VALUES
  ('Manoeuvrable','Coffret manœuvrable en charge grâce à la présence d’un moyen de coupure dans le coffret (couteau ou fusible)')
, ('Separable','Tous les autres cas. Nécessité de dévisser les raccords pour séparer un câble (travaux hors charge)')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('FonctionCoffretValue','attributes','FonctionCoffretValue'); --GPKG

DROP TABLE IF EXISTS GeomCoffret;
CREATE TABLE GeomCoffret (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  Geometrie LINESTRING
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('GeomCoffret','features','GeomCoffret',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('GeomCoffret', 'Geometrie', 'LINESTRING', 2154, 0, 0); --GPKG

INSERT INTO GeomCoffret VALUES
  ('Default',ST_AddPoint(ST_AddPoint(ST_AddPoint(ST_AddPoint(MakeLine(ST_Point(0,0),ST_Point(0.25,0)),ST_Point(0.25,0.25)),ST_Point(-0.25,0.25)),ST_Point(-0.25,0)),ST_Point(0,0)))
;


DROP TABLE IF EXISTS RPD_Coffret_Reco;
CREATE TABLE RPD_Coffret_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_Coffret_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, ImplantationArmoire_href TEXT NOT NULL REFERENCES ImplantationArmoireValue (valeurs)
, TypeCoffret_href TEXT REFERENCES TypeCoffretValue (valeurs)
, FonctionCoffret_href TEXT REFERENCES FonctionCoffretValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, angle INTEGER --NOTE : hors reco star : permet de générer la géométrie supp orientée -- TODO : voir taille en fonction type coffret
, geometriesupplementaire_href TEXT NOT NULL DEFAULT (CreateUUID())
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Coffret_Reco','features','RPD_Coffret_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Coffret_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Coffret_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_Coffret_Reco_reseau_reseau;
CREATE VIEW RPD_Coffret_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_Coffret_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Coffret_Reco_reseau_reseau','attributes','RPD_Coffret_Reco_reseau_reseau'); --GPKG

DROP VIEW IF EXISTS RPD_Coffret_Reco_geometriesupplementaire;
CREATE VIEW RPD_Coffret_Reco_geometriesupplementaire as
select fid, c.ogr_pkid ogr_pkid, c.ogr_pkid parent_ogr_pkid
, geometriesupplementaire_href href
, cast(null as text) geometriesupplementair_rpd_geometriesupplementaire_reco_pkid
from RPD_Coffret_Reco c ;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Coffret_Reco_geometriesupplementaire','attributes','RPD_Coffret_Reco_geometriesupplementaire'); --GPKG

--XXX RPD_Support_Reco

DROP TABLE IF EXISTS ClasseSupportValue;
CREATE TABLE ClasseSupportValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ClasseSupportValue VALUES
  ('A',   'Ancien poteau béton simple')
, ('B',   'Ancien poteau béton simple')
, ('C',   'Ancien poteau béton simple')
, ('CFX', 'Contrefiché bois calé')
, ('CFY', 'Contrefiché bois')
, ('CFZ', 'Contrefiché bois')
, ('CH',  'Chevron bois')
, ('D',   'Béton simple rectangulaire')
, ('E',   'Béton simple carré')
, ('ER',  'Béton simple rond')
, ('HS',  'Haubanné bois')
, ('JA',  'Ancien poteau béton jumelé')
, ('JB',  'Ancien poteau béton jumelé')
, ('JC',  'Ancien poteau béton jumelé')
, ('JD',  'Béton rectangulaire jumelé')
, ('JE',  'Béton carré jumelé')
, ('JER', 'Béton rond jumelé')
, ('JS',  'Jumelé bois')
, ('M',   'Simple métallique')
, ('PA',  'Ancien portique béton')
, ('PB',  'Ancien portique béton')
, ('PC',  'Ancien portique béton')
, ('PCH', 'Portique chevron')
, ('PCHX','Portique chevron croisilloné')
, ('PD',  'Portique béton rectangulaire')
, ('PE',  'Portique béton carré')
, ('PER', 'Portique béton rond')
, ('PJA', 'Ancien portique jumelé béton')
, ('PJB', 'Ancien portique jumelé béton')
, ('PJC', 'Ancien portique jumelé béton')
, ('PJD', 'Portique jumelé béton rectang.')
, ('PJE', 'Portique jumelé béton carré.')
, ('PJER','Portique jumelé béton rond.')
, ('PJS', 'Portique jumelé bois')
, ('PJX', 'Portique bois jumelé croisillo')
, ('PM',  'Portique métallique')
, ('PS',  'Portique bois')
, ('PX',  'Portique bois croisilloné')
, ('S',   'Simple bois')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ClasseSupportValue','attributes','ClasseSupportValue'); --GPKG

DROP TABLE IF EXISTS NatureSupportValue;
CREATE TABLE NatureSupportValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO NatureSupportValue VALUES
  ('Poteau','Tous types de poteau dédié au supportage de réseau')
, ('Facade','Mur ou façade de bâti')
, ('Autre','Tout autre type de support')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('NatureSupportValue','attributes','NatureSupportValue'); --GPKG


DROP TABLE IF EXISTS MatiereValue;
CREATE TABLE MatiereValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO MatiereValue VALUES
  ('Autre','Autre')
, ('Beton','Béton')
, ('Bois','Bois')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('MatiereValue','attributes','MatiereValue'); --GPKG

DROP TABLE IF EXISTS RPD_Support_Reco;
CREATE TABLE RPD_Support_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_Support_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Classe_href TEXT REFERENCES ClasseSupportValue (valeurs) -- NOTE : NOT NULL sauf si NatureSupport = facade
, Effort INTEGER -- NOTE : NOT NULL sauf si NatureSupport = facade
, Effort_uom TEXT DEFAULT 'kN'
, HauteurPoteau INTEGER -- NOTE : NOT NULL sauf si NatureSupport = facade
, HauteurPoteau_uom TEXT DEFAULT 'm'
, NatureSupport_href TEXT REFERENCES NatureSupportValue (valeurs)
, Matiere_href TEXT NOT NULL REFERENCES MatiereValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
CHECK ((NatureSupport_href<>'Facade' AND Classe_href IS NOT NULL AND Effort IS NOT NULL AND HauteurPoteau IS NOT NULL) OR NatureSupport_href='Facade')
);
-- QGIS "Classe" constraint : ("NatureSupport_href" <> 'Facade' and  "Classe_href" is not null) or "NatureSupport_href" = 'Facade'
-- QGIS "Effort" constraint : ("NatureSupport_href" <> 'Facade' and  "Effort" is not null) or "NatureSupport_href" = 'Facade'
-- QGIS "HauteurPoteau" constraint : ("NatureSupport_href" <> 'Facade' and  "HauteurPoteau" is not null) or "NatureSupport_href" = 'Facade'

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Support_Reco','features','RPD_Support_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Support_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Support_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_Support_Reco_reseau_reseau;
CREATE VIEW RPD_Support_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_Support_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Support_Reco_reseau_reseau','attributes','RPD_Support_Reco_reseau_reseau'); --GPKG

DROP VIEW IF EXISTS Conteneur;
CREATE VIEW Conteneur as
with all_conso as (
  SELECT ogr_pkid, id, cast('BatimentTechnique' as text) type_conteneur, PrecisionXY, PrecisionZ, Geometrie FROM RPD_BatimentTechnique_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('EnceinteCloturee' as text) type_conteneur, PrecisionXY, PrecisionZ, Geometrie FROM RPD_EnceinteCloturee_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Coffret' as text) type_conteneur, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Coffret_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Support' as text) type_conteneur, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Support_Reco
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Conteneur','features','Conteneur',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Conteneur', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

--XXX RPD_GeometrieSupplementaire_Reco

DROP VIEW IF EXISTS RPD_GeometrieSupplementaire_Reco;
CREATE VIEW RPD_GeometrieSupplementaire_Reco as
with all_conso as (
  SELECT cast('RPD_BatimentTechnique_Reco_geomsupp_'||fid as text) ogr_pkid, geometriesupplementaire_href id, id conteneur_id, cast('BatimentTechnique' as text) type_conteneur, PrecisionXY, PrecisionZ
  , Geometrie "Ligne2.5D"
  , CASE  WHEN ST_IsClosed(Geometrie) THEN ST_MakePolygon(Geometrie)
          WHEN ST_NumPoints(Geometrie) > 3 THEN ST_MakePolygon(ST_AddPoint(Geometrie, ST_StartPoint(Geometrie)))
          ELSE NULL END "Surface2.5D"
  FROM RPD_BatimentTechnique_Reco_line
  UNION ALL
  SELECT cast('RPD_EnceinteCloturee_Reco_geomsupp_'||fid as text) ogr_pkid, geometriesupplementaire_href id, id conteneur_id, cast('EnceinteCloturee' as text) type_conteneur, PrecisionXY, PrecisionZ
  , Geometrie "Ligne2.5D"
  , CASE  WHEN ST_IsClosed(Geometrie) THEN ST_MakePolygon(Geometrie)
          WHEN ST_NumPoints(Geometrie) > 3 THEN ST_MakePolygon(ST_AddPoint(Geometrie, ST_StartPoint(Geometrie)))
          ELSE NULL END "Surface2.5D"
  FROM RPD_EnceinteCloturee_Reco_line
  UNION ALL
  SELECT cast('RPD_Coffret_Reco_geomsupp_'||fid as text) ogr_pkid, geometriesupplementaire_href id, id conteneur_id, cast('Coffret' as text) type_conteneur, PrecisionXY, PrecisionZ
  , ST_Translate(RotateCoordinates(CastToXYZ(g.Geometrie),coalesce(angle,0)), ST_X(c.Geometrie), ST_Y(c.Geometrie), ST_Z(c.Geometrie)) "Ligne2.5D"
  , ST_Translate(RotateCoordinates(CastToXYZ(ST_MakePolygon(g.Geometrie)),coalesce(angle,0)), ST_X(c.Geometrie), ST_Y(c.Geometrie), ST_Z(c.Geometrie)) "Surface2.5D"
  FROM RPD_Coffret_Reco c
  JOIN GeomCoffret g ON g.valeurs = 'Default'
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_GeometrieSupplementaire_Reco','features','RPD_GeometrieSupplementaire_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_GeometrieSupplementaire_Reco', 'Surface2.5D', 'MULTIPOLYGON', 2154, 1, 0); --GPKG

--XXX Noeud

--XXX RPD_JeuBarres_Reco

DROP TABLE IF EXISTS RPD_JeuBarres_Reco;
CREATE TABLE RPD_JeuBarres_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_JeuBarres_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_JeuBarres_Reco','features','RPD_JeuBarres_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_JeuBarres_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_JeuBarres_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_JeuBarres_Reco_reseau_reseau;
CREATE VIEW RPD_JeuBarres_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_JeuBarres_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_JeuBarres_Reco_reseau_reseau','attributes','RPD_JeuBarres_Reco_reseau_reseau'); --GPKG

--XXX RPD_Jonction_Reco

DROP TABLE IF EXISTS TypeJonctionValue;
CREATE TABLE TypeJonctionValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO TypeJonctionValue VALUES
  ('Derivation','Dérivation')
, ('ExtremiteReseau','Extrémité du réseau')
, ('Jonction','Jonction')
, ('RAS','Remontée aéro-souterraine')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('TypeJonctionValue','attributes','TypeJonctionValue'); --GPKG

DROP TABLE IF EXISTS RPD_Jonction_Reco;
CREATE TABLE RPD_Jonction_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_Jonction_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, DomaineTension TEXT NOT NULL REFERENCES DomaineTensionValue (valeurs)
, TypeJonction TEXT NOT NULL REFERENCES TypeJonctionValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Jonction_Reco','features','RPD_Jonction_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Jonction_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Jonction_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_Jonction_Reco_reseau_reseau;
CREATE VIEW RPD_Jonction_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_Jonction_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Jonction_Reco_reseau_reseau','attributes','RPD_Jonction_Reco_reseau_reseau'); --GPKG

--XXX RPD_Plage_Reco
-- NOTE : peut etre un enfant d'un RM ou JDB

DROP TABLE IF EXISTS RPD_Plage_Reco;
CREATE TABLE RPD_Plage_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_Plage_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Coupure BOOLEAN NOT NULL
, Protection BOOLEAN NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, conteneur_href TEXT -- REFERENCES Conteneur (id)
, noeudparent_href TEXT
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Plage_Reco','features','RPD_Plage_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Plage_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Plage_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_Plage_Reco_reseau_reseau;
CREATE VIEW RPD_Plage_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_Plage_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Plage_Reco_reseau_reseau','attributes','RPD_Plage_Reco_reseau_reseau'); --GPKG

--XXX RPD_OuvrageCollectifBranchement_Reco
-- NOTE : peut etre un enfant d'un RM ou JDB
-- IDEA: copier la liste des PRMs => création auto des OCB (JSON?)

DROP TABLE IF EXISTS RPD_OuvrageCollectifBranchement_Reco;
CREATE TABLE RPD_OuvrageCollectifBranchement_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_OuvrageCollectifBranchement_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_OuvrageCollectifBranchement_Reco','features','RPD_OuvrageCollectifBranchement_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_OuvrageCollectifBranchement_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_OuvrageCollectifBranchement_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_OuvrageCollectifBranchement_Reco_reseau_reseau;
CREATE VIEW RPD_OuvrageCollectifBranchement_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_OuvrageCollectifBranchement_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_OuvrageCollectifBranchement_Reco_reseau_reseau','attributes','RPD_OuvrageCollectifBranchement_Reco_reseau_reseau'); --GPKG

--XXX RPD_PointDeComptage_Reco
-- NOTE : peut etre un enfant d'un OCB, RM ou JDB

DROP TABLE IF EXISTS RPD_PointDeComptage_Reco;
CREATE TABLE RPD_PointDeComptage_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_PointDeComptage_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NumeroPRM INTEGER NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PointDeComptage_Reco','features','RPD_PointDeComptage_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PointDeComptage_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PointDeComptage_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_PointDeComptage_Reco_reseau_reseau;
CREATE VIEW RPD_PointDeComptage_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_PointDeComptage_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_PointDeComptage_Reco_reseau_reseau','attributes','RPD_PointDeComptage_Reco_reseau_reseau'); --GPKG

--XXX RPD_PosteElectrique_Reco

DROP TABLE IF EXISTS CategoriesPosteValue;
CREATE TABLE CategoriesPosteValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO CategoriesPosteValue VALUES
  ('Distribution','Poste de distribution')
, ('Manoeuvre','Poste de manœuvre')
, ('PosteSource','Poste source')
, ('RepartitionHTA','Poste de répartition HTA')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('CategoriesPosteValue','attributes','CategoriesPosteValue'); --GPKG

DROP TABLE IF EXISTS TypePosteValue;
CREATE TABLE TypePosteValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO TypePosteValue VALUES
  ('ACM','Armoire de Coupure Manuelle')
, ('ACMD','Armoire de Coupure Manuelle avec Dérivation')
, ('AC3M','Armoire de Coupure à 3 directions Manuelle')
, ('ACT','Armoire de Coupure Télécommandée')
, ('AC3T','Armoire de Coupure à 3 directions Télécommandée')
, ('CB','Cabine Basse')
, ('CC','Cabine de chantier')
, ('CH','Cabine haute')
, ('IM','En Immeuble')
, ('EN','En Terre')
, ('PSSA','Poste au Sol Simplifié de Type A')
, ('PSSB','Poste au Sol Simplifié de Type B')
, ('PRCS','Poste Rural Compact Socle')
, ('PUIE','Poste Urbain Intégré à son Environnement')
, ('H6','Poteau H61')
, ('PO','Poteau non H61')
, ('RC','Rural Compact')
, ('RS','Rural Socle')
, ('UC','Urbain Compact')
, ('UP','Urbain Portable (PAC)')
, ('HTEP','Poste Haute tension - Eclairage Public')
, ('GRSC','Poste Source Groupe SC Classification)')
, ('GR1','Poste Source Groupe 1')
, ('GR2A','Poste Source Groupe 2A')
, ('GR2B','Poste Source Groupe 2B')
, ('GR2C','Poste Source Groupe 2C')
, ('GR2D','Poste Source Groupe 2D')
, ('GR2E','Poste Source Groupe 2E')
, ('GR2F','Poste Source Groupe 2F GR3 Poste Source Groupe 3')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('TypePosteValue','attributes','TypePosteValue'); --GPKG

DROP TABLE IF EXISTS RPD_PosteElectrique_Reco;
CREATE TABLE RPD_PosteElectrique_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_PosteElectrique_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Categorie_href TEXT NOT NULL REFERENCES CategoriesPosteValue (valeurs)
, TypePoste_href TEXT NOT NULL REFERENCES TypePosteValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PosteElectrique_Reco','features','RPD_PosteElectrique_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PosteElectrique_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PosteElectrique_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_PosteElectrique_Reco_reseau_reseau;
CREATE VIEW RPD_PosteElectrique_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_PosteElectrique_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_PosteElectrique_Reco_reseau_reseau','attributes','RPD_PosteElectrique_Reco_reseau_reseau'); --GPKG

--XXX RPD_RaccordementModulaire_Reco

DROP TABLE IF EXISTS RPD_RaccordementModulaire_Reco;
CREATE TABLE RPD_RaccordementModulaire_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_RaccordementModulaire_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NombrePlages INTEGER NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_RaccordementModulaire_Reco','features','RPD_RaccordementModulaire_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_RaccordementModulaire_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_RaccordementModulaire_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_RaccordementModulaire_Reco_reseau_reseau;
CREATE VIEW RPD_RaccordementModulaire_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_RaccordementModulaire_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_RaccordementModulaire_Reco_reseau_reseau','attributes','RPD_RaccordementModulaire_Reco_reseau_reseau'); --GPKG

--XXX RPD_Terre_Reco

DROP TABLE IF EXISTS NatureTerreValue;
CREATE TABLE NatureTerreValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO NatureTerreValue VALUES
  ('TerreMasses','Terre des masses métalliques')
, ('TerreNeutre','Terre du neutre de la distribution')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('NatureTerreValue','attributes','NatureTerreValue'); --GPKG

DROP TABLE IF EXISTS RPD_Terre_Reco;
CREATE TABLE RPD_Terre_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_Terre_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NatureTerre_href TEXT NOT NULL REFERENCES NatureTerreValue (valeurs)
, Resistance INTEGER
, Resistance_uom TEXT DEFAULT 'ohms'
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- NOTE : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
, conteneur_href TEXT -- REFERENCES Conteneur (id)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Terre_Reco','features','RPD_Terre_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Terre_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Terre_Reco', 'Geometrie' );

DROP VIEW IF EXISTS RPD_Terre_Reco_reseau_reseau;
CREATE VIEW RPD_Terre_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_Terre_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_Terre_Reco_reseau_reseau','attributes','RPD_Terre_Reco_reseau_reseau'); --GPKG

DROP VIEW IF EXISTS Noeud;
CREATE VIEW Noeud as
with all_conso as (
  SELECT ogr_pkid, id, cast('Plage' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Plage_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('OuvrageCollectifBranchement' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_OuvrageCollectifBranchement_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('PointDeComptage' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PointDeComptage_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('PosteElectrique' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PosteElectrique_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('RaccordementModulaire' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_RaccordementModulaire_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('JeuBarres' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_JeuBarres_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Jonction' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Jonction_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Terre' as text) type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Terre_Reco
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Noeud','features','Noeud',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Noeud', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

--XXX RELATIONS CONTENEUR / NOEUD / CABLE

DROP VIEW IF EXISTS Conteneur_Noeud; --FIXME : a mettre dans attribut de la table Noeud lors de l'export : voir xsd
CREATE VIEW Conteneur_Noeud as
with all_conso as (
  SELECT n.id noeud_id, type_noeud, c.conteneur_id conteneur_id, type_conteneur
  FROM Noeud n
  JOIN RPD_GeometrieSupplementaire_Reco c ON PtDistWithin(c."Ligne2.5D", n."Geometrie", 0.002) OR PtDistWithin(c."Surface2.5D", n."Geometrie", 0.002)
  UNION ALL
  SELECT n.id noeud_id, type_noeud, c.id conteneur_id, type_conteneur
  FROM Noeud n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", n."Geometrie", 0.002)
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Conteneur_Noeud','attributes','Conteneur_Noeud'); --GPKG

DROP VIEW IF EXISTS Conteneur_Cable;
CREATE VIEW Conteneur_Cable as
with all_conso as (
  SELECT n.id cable_id, type_cable, cast('StartPoint' as text) connpt, c.conteneur_id conteneur_id, type_conteneur
  FROM Cable n
  JOIN RPD_GeometrieSupplementaire_Reco c ON PtDistWithin(c."Ligne2.5D", ST_StartPoint(n."Geometrie"), 0.002) OR PtDistWithin(c."Surface2.5D", ST_StartPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, cast('StartPoint' as text) connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", ST_StartPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, cast('EndPoint' as text) connpt, c.conteneur_id conteneur_id, type_conteneur
  FROM Cable n
  JOIN RPD_GeometrieSupplementaire_Reco c ON PtDistWithin(c."Ligne2.5D", ST_EndPoint(n."Geometrie"), 0.002) OR PtDistWithin(c."Surface2.5D", ST_EndPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, cast('EndPoint' as text) connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", ST_EndPoint(n."Geometrie"), 0.002)
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Conteneur_Cable','attributes','Conteneur_Cable'); --GPKG

DROP VIEW IF EXISTS Noeud_Cable;
CREATE VIEW Noeud_Cable as
with all_conso as (
  SELECT c.id cable_id, type_cable, cast('StartPoint' as text) connpt, n.id noeud_id, type_noeud
  FROM Noeud n
  JOIN Cable c ON PtDistWithin(n."Geometrie", ST_StartPoint(c."Geometrie"), 0.002)
  UNION ALL
  SELECT c.id cable_id, type_cable, cast('EndPoint' as text) connpt, n.id noeud_id, type_noeud
  FROM Noeud n
  JOIN Cable c ON PtDistWithin(n."Geometrie", ST_EndPoint(c."Geometrie"), 0.002)
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Noeud_Cable','attributes','Noeud_Cable'); --GPKG


DROP VIEW IF EXISTS CableElectrique_NoeudReseau;
CREATE VIEW CableElectrique_NoeudReseau AS
with uniiion as (
  select cast(c.id as text) cableelectrique_href
  , cast(n.noeud_id as text) noeudreseau_href
  , connpt
  , -1 dist
  FROM RPD_CableElectrique_Reco c
  JOIN Noeud_Cable n ON n.cable_id=c.id
  union all
  select cast(c.id as text) cableelectrique_href
  , cast(n.noeud_id as text) noeudreseau_href
  , connpt
  , ST_Distance(c.Geometrie, m.Geometrie)
  FROM RPD_CableElectrique_Reco c
  JOIN Conteneur_Cable h ON h.cable_id=c.id
  JOIN Conteneur_Noeud n ON n.conteneur_id=h.conteneur_id
  JOIN Noeud m on m.id = n.noeud_id
)
, diiistinct as (
select cableelectrique_href, noeudreseau_href, connpt
from uniiion a
WHERE NOT EXISTS (SELECT 1 FROM uniiion b WHERE b.cableelectrique_href=a.cableelectrique_href and b.connpt=a.connpt and b.dist < a.dist)
)
SELECT
  cast(ROW_NUMBER () OVER () as int) fid
, 'CableElectrique_NoeudReseau_'||ROW_NUMBER () OVER () ogr_pkid
, (CreateUUID()) id
, *
, cast(null as text) noeudreseau_noeudreseau_rpd_pointdecomptage_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_posteelectrique_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_terre_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_jeubarres_reco_pkid
, cast(null as text) noeudres_noeudreseau_rpd_ouvragecollectifbrancheme_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_plage_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_raccordementmodulaire_reco_pkid
, cast(null as text) noeudreseau_noeudreseau_rpd_jonction_reco_pkid
, cast(null as text) cableelectriqu_cableelectrique_rpd_cableelectrique_reco_pkid
from diiistinct
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('CableElectrique_NoeudReseau','attributes','CableElectrique_NoeudReseau'); --GPKG

--XXX RPD_PointLeveOuvrageReseau_Reco

DROP TABLE IF EXISTS LeveTypeValue;
CREATE TABLE LeveTypeValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO LeveTypeValue VALUES
  ('AltitudeGeneratrice','Altitude à la génératrice') -- z gs
, ('ChargeGeneratrice','Charge à la génératrice') -- profondeur gs
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('LeveTypeValue','attributes','LeveTypeValue'); --GPKG

DROP TABLE IF EXISTS RPD_PointLeveOuvrageReseau_Reco;
CREATE TABLE RPD_PointLeveOuvrageReseau_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT DEFAULT ('RPD_PointLeveOuvrageReseau_Reco_0')
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NumeroPoint TEXT NOT NULL
, CodeOuvrage TEXT NOT NULL --NOTE : hors reco star => permet de tracer les lignes en auto
, Leve NUMERIC NOT NULL -- ZGS ou Profondeur
, Leve_uom TEXT DEFAULT 'm'
, TypeLeve TEXT NOT NULL REFERENCES LeveTypeValue (valeurs)
, Producteur TEXT NOT NULL
, Geometrie POINTZ NOT NULL --UNIQUE
, PrecisionXYnum INTEGER NOT NULL
, PrecisionZnum INTEGER NOT NULL
, UNIQUE (Geometrie, CodeOuvrage)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PointLeveOuvrageReseau_Reco','features','RPD_PointLeveOuvrageReseau_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PointLeveOuvrageReseau_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PointLeveOuvrageReseau_Reco', 'Geometrie' );

--TODO :
-- voir les calculs de relation pour les cables de terre
-- probleme des doubles géométries des geom suppp qui sortent en polygone
