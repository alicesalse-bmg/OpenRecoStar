-- select load_extension("/usr/local/lib/mod_spatialite.dylib");
-- SELECT EnableGpkgMode(); --GPKG
--XXX Noeud

--XXX RPD_JeuBarres_Reco

DROP TABLE IF EXISTS RPD_JeuBarres_Reco;
CREATE TABLE RPD_JeuBarres_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_JeuBarres_Reco','features','RPD_JeuBarres_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_JeuBarres_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_JeuBarres_Reco', 'Geometrie' );

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, DomaineTension TEXT NOT NULL REFERENCES DomaineTensionValue (valeurs)
, TypeJonction TEXT NOT NULL REFERENCES TypeJonctionValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Jonction_Reco','features','RPD_Jonction_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Jonction_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Jonction_Reco', 'Geometrie' );

--XXX RPD_Plage_Reco
-- NOTE : peut etre un enfant d'un RM ou JDB

DROP TABLE IF EXISTS RPD_Plage_Reco;
CREATE TABLE RPD_Plage_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Coupure BOOLEAN NOT NULL
, Protection BOOLEAN NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Plage_Reco','features','RPD_Plage_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Plage_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Plage_Reco', 'Geometrie' );

--XXX RPD_OuvrageCollectifBranchement_Reco
-- NOTE : peut etre un enfant d'un RM ou JDB

DROP TABLE IF EXISTS RPD_OuvrageCollectifBranchement_Reco;
CREATE TABLE RPD_OuvrageCollectifBranchement_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_OuvrageCollectifBranchement_Reco','features','RPD_OuvrageCollectifBranchement_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_OuvrageCollectifBranchement_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_OuvrageCollectifBranchement_Reco', 'Geometrie' );

--XXX RPD_PointDeComptage_Reco
-- NOTE : peut etre un enfant d'un OCB, RM ou JDB

DROP TABLE IF EXISTS RPD_PointDeComptage_Reco;
CREATE TABLE RPD_PointDeComptage_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NumeroPRM INTEGER NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PointDeComptage_Reco','features','RPD_PointDeComptage_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PointDeComptage_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PointDeComptage_Reco', 'Geometrie' );

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Categorie TEXT NOT NULL REFERENCES CategoriesPosteValue (valeurs)
, TypePoste TEXT NOT NULL REFERENCES TypePosteValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PosteElectrique_Reco','features','RPD_PosteElectrique_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PosteElectrique_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PosteElectrique_Reco', 'Geometrie' );

--XXX RPD_RaccordementModulaire_Reco

DROP TABLE IF EXISTS RPD_RaccordementModulaire_Reco;
CREATE TABLE RPD_RaccordementModulaire_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NombrePlages INTEGER NOT NULL
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_RaccordementModulaire_Reco','features','RPD_RaccordementModulaire_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_RaccordementModulaire_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_RaccordementModulaire_Reco', 'Geometrie' );

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NatureTerre TEXT NOT NULL REFERENCES NatureTerreValue (valeurs)
, Resistance INTEGER
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, PrecisionZ TEXT REFERENCES ClassePrecisionReseauValue (valeurs) -- FIXME : NOT NULL si pas dans conteneur ou noeud parent
, Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Terre_Reco','features','RPD_Terre_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Terre_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Terre_Reco', 'Geometrie' );

DROP VIEW IF EXISTS Noeud;
CREATE VIEW Noeud as
with all_conso as (
  SELECT id, 'Plage' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Plage_Reco
  UNION ALL
  SELECT id, 'OuvrageCollectifBranchement' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_OuvrageCollectifBranchement_Reco
  UNION ALL
  SELECT id, 'PointDeComptage' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PointDeComptage_Reco
  UNION ALL
  SELECT id, 'PosteElectrique' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PosteElectrique_Reco
  UNION ALL
  SELECT id, 'RaccordementModulaire' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_RaccordementModulaire_Reco
  UNION ALL
  SELECT id, 'JeuBarres' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_JeuBarres_Reco
  UNION ALL
  SELECT id, 'Jonction' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Jonction_Reco
  UNION ALL
  SELECT id, 'Terre' type_noeud, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Terre_Reco
) select ROW_NUMBER () OVER () pkid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Noeud','features','Noeud',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Noeud', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

---XXX Conteneur

--XXX RPD_BatimentTechnique_Reco

DROP TABLE IF EXISTS RPD_BatimentTechnique_Reco;
CREATE TABLE RPD_BatimentTechnique_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie MULTILINESTRINGZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_BatimentTechnique_Reco','features','RPD_BatimentTechnique_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_BatimentTechnique_Reco', 'Geometrie', 'MULTILINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_BatimentTechnique_Reco', 'Geometrie' );

--XXX RPD_EnceinteCloturee_Reco

DROP TABLE IF EXISTS RPD_EnceinteCloturee_Reco;
CREATE TABLE RPD_EnceinteCloturee_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Geometrie MULTILINESTRINGZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_EnceinteCloturee_Reco','features','RPD_EnceinteCloturee_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_EnceinteCloturee_Reco', 'Geometrie', 'MULTILINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_EnceinteCloturee_Reco', 'Geometrie' );

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

-- TODO : EXECUTER DANS QGIS
-- INSERT INTO GeomCoffret VALUES
--   ('Default',ST_AddPoint(ST_AddPoint(ST_AddPoint(ST_AddPoint(MakeLine(ST_Point(0,0),ST_Point(0.25,0)),ST_Point(0.25,0.25)),ST_Point(-0.25,0.25)),ST_Point(-0.25,0)),ST_Point(0,0)))
-- ;


DROP TABLE IF EXISTS RPD_Coffret_Reco;
CREATE TABLE RPD_Coffret_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, ImplantationArmoire TEXT NOT NULL REFERENCES ImplantationArmoireValue (valeurs)
, TypeCoffret TEXT REFERENCES TypeCoffretValue (valeurs)
, FonctionCoffret TEXT REFERENCES FonctionCoffretValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, angle INTEGER --NOTE : hors reco star : permet de générer la géométrie supp orientée -- TODO : voir taille en fonction type coffret
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Coffret_Reco','features','RPD_Coffret_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Coffret_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Coffret_Reco', 'Geometrie' );

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Classe TEXT REFERENCES ClasseSupportValue (valeurs) -- NOTE : NOT NULL sauf si NatureSupport = facade
, Effort INTEGER --QUESTION: UNITE? -- NOTE : NOT NULL sauf si NatureSupport = facade
, HauteurPoteau INTEGER --QUESTION: UNITE? -- NOTE : NOT NULL sauf si NatureSupport = facade
, NatureSupport TEXT REFERENCES NatureSupportValue (valeurs)
, Matiere TEXT NOT NULL REFERENCES MatiereValue (valeurs)
, Geometrie POINTZ NOT NULL UNIQUE
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, angle INTEGER --NOTE : hors reco star : permet d'améliorer le dessin
CHECK ((NatureSupport<>'Facade' AND Classe IS NOT NULL AND Effort IS NOT NULL AND HauteurPoteau IS NOT NULL) OR NatureSupport='Facade')
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Support_Reco','features','RPD_Support_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Support_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Support_Reco', 'Geometrie' );

DROP VIEW IF EXISTS Conteneur;
CREATE VIEW Conteneur as
with all_conso as (
  SELECT id, 'BatimentTechnique' type_conteneur, PrecisionXY, PrecisionZ, ST_Centroid(Geometrie) Geometrie FROM RPD_BatimentTechnique_Reco
  UNION ALL
  SELECT id, 'EnceinteCloturee' type_conteneur, PrecisionXY, PrecisionZ, ST_Centroid(Geometrie) Geometrie FROM RPD_EnceinteCloturee_Reco
  UNION ALL
  SELECT id, 'Coffret' type_conteneur, PrecisionXY, PrecisionZ, ST_Centroid(Geometrie) Geometrie FROM RPD_Coffret_Reco
  UNION ALL
  SELECT id, 'Support' type_conteneur, PrecisionXY, PrecisionZ, ST_Centroid(Geometrie) Geometrie FROM RPD_Support_Reco
) select ROW_NUMBER () OVER () pkid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Conteneur','features','Conteneur',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Conteneur', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG

--XXX RPD_GeometrieSupplementaire_Conteneur_Reco

DROP VIEW IF EXISTS RPD_GeometrieSupplementaire_Conteneur_Reco;
CREATE VIEW RPD_GeometrieSupplementaire_Conteneur_Reco as
with all_conso as (
  SELECT id, 'BatimentTechnique' type_conteneur, PrecisionXY, PrecisionZ
  , Geometrie "Ligne2.5D"
  , CASE  WHEN ST_IsClosed(Geometrie) THEN ST_MakePolygon(Geometrie)
          WHEN ST_NumPoints(Geometrie) > 3 THEN ST_MakePolygon(ST_AddPoint(Geometrie, ST_StartPoint(Geometrie)))
          ELSE NULL END "Surface2.5D"
  FROM RPD_BatimentTechnique_Reco
  UNION ALL
  SELECT id, 'EnceinteCloturee' type_conteneur, PrecisionXY, PrecisionZ
  , Geometrie "Ligne2.5D"
  , CASE  WHEN ST_IsClosed(Geometrie) THEN ST_MakePolygon(Geometrie)
          WHEN ST_NumPoints(Geometrie) > 3 THEN ST_MakePolygon(ST_AddPoint(Geometrie, ST_StartPoint(Geometrie)))
          ELSE NULL END "Surface2.5D"
  FROM RPD_EnceinteCloturee_Reco
  UNION ALL
  SELECT id, 'Coffret' type_conteneur, PrecisionXY, PrecisionZ
  , ST_Translate(RotateCoordinates(CastToXYZ(g.Geometrie),coalesce(angle,0)), ST_X(c.Geometrie), ST_Y(c.Geometrie), ST_Z(c.Geometrie)) "Ligne2.5D"
  , ST_Translate(RotateCoordinates(CastToXYZ(ST_MakePolygon(g.Geometrie)),coalesce(angle,0)), ST_X(c.Geometrie), ST_Y(c.Geometrie), ST_Z(c.Geometrie)) "Surface2.5D"
  FROM RPD_Coffret_Reco c
  JOIN GeomCoffret g ON g.valeurs = 'Default'
) select ROW_NUMBER () OVER () pkid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_GeometrieSupplementaire_Conteneur_Reco','features','RPD_GeometrieSupplementaire_Conteneur_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_GeometrieSupplementaire_Conteneur_Reco', 'Surface2.5D', 'MULTIPOLYGON', 2154, 1, 0); --GPKG

--XXX RELATIONS CONTENEUR / NOEUD / CABLE

DROP VIEW IF EXISTS Conteneur_Noeud; --FIXME : a mettre dans attribut de la table Noeud lors de l'export : voir xsd
CREATE VIEW Conteneur_Noeud as
with all_conso as (
  SELECT n.id noeud_id, type_noeud, c.id conteneur_id, type_conteneur
  FROM Noeud n
  JOIN RPD_GeometrieSupplementaire_Conteneur_Reco c ON PtDistWithin(c."Ligne2.5D", n."Geometrie", 0.002) OR PtDistWithin(c."Surface2.5D", n."Geometrie", 0.002)
  UNION ALL
  SELECT n.id noeud_id, type_noeud, c.id conteneur_id, type_conteneur
  FROM Noeud n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", n."Geometrie", 0.002)
) select ROW_NUMBER () OVER () pkid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Conteneur_Noeud','attributes','Conteneur_Noeud'); --GPKG

DROP VIEW IF EXISTS Conteneur_Cable;
CREATE VIEW Conteneur_Cable as
with all_conso as (
  SELECT n.id cable_id, type_cable, 'StartPoint' connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN RPD_GeometrieSupplementaire_Conteneur_Reco c ON PtDistWithin(c."Ligne2.5D", ST_StartPoint(n."Geometrie"), 0.002) OR PtDistWithin(c."Surface2.5D", ST_StartPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, 'StartPoint' connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", ST_StartPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, 'EndPoint' connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN RPD_GeometrieSupplementaire_Conteneur_Reco c ON PtDistWithin(c."Ligne2.5D", ST_EndPoint(n."Geometrie"), 0.002) OR PtDistWithin(c."Surface2.5D", ST_EndPoint(n."Geometrie"), 0.002)
  UNION ALL
  SELECT n.id cable_id, type_cable, 'EndPoint' connpt, c.id conteneur_id, type_conteneur
  FROM Cable n
  JOIN Conteneur c ON c.type_conteneur = 'Support' AND PtDistWithin(c."Geometrie", ST_EndPoint(n."Geometrie"), 0.002)
) select ROW_NUMBER () OVER () pkid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Conteneur_Cable','attributes','Conteneur_Cable'); --GPKG

DROP VIEW IF EXISTS Noeud_Cable;
CREATE VIEW Noeud_Cable as
with all_conso as (
  SELECT c.id cable_id, type_cable, 'StartPoint' connpt, n.id noeud_id, type_noeud
  FROM Noeud n
  JOIN Cable c ON PtDistWithin(n."Geometrie", ST_StartPoint(c."Geometrie"), 0.002)
  UNION ALL
  SELECT c.id cable_id, type_cable, 'EndPoint' connpt, n.id noeud_id, type_noeud
  FROM Noeud n
  JOIN Cable c ON PtDistWithin(n."Geometrie", ST_EndPoint(c."Geometrie"), 0.002)
) select ROW_NUMBER () OVER () pkid, * from all_conso;
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Noeud_Cable','attributes','Noeud_Cable'); --GPKG

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, NumeroPoint TEXT NOT NULL
, CodeOuvrage TEXT NOT NULL --NOTE : hors reco star => permet de tracer les lignes en auto
, Leve NUMERIC NOT NULL -- ZGS ou Profondeur
, TypeLeve TEXT NOT NULL REFERENCES LeveTypeValue (valeurs)
, Producteur TEXT NOT NULL
, Geometrie POINTZ NOT NULL --UNIQUE
, PrecisionXY INTEGER NOT NULL
, PrecisionZ INTEGER NOT NULL
, UNIQUE (Geometrie, CodeOuvrage)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PointLeveOuvrageReseau_Reco','features','RPD_PointLeveOuvrageReseau_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PointLeveOuvrageReseau_Reco', 'Geometrie', 'POINT', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PointLeveOuvrageReseau_Reco', 'Geometrie' );


-- TODO : intégrer les valeurs de mesures uom
