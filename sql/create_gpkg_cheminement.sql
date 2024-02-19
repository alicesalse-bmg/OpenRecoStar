select load_extension("/usr/local/lib/mod_spatialite.dylib");
SELECT EnableGpkgMode(); --GPKG
SELECT gpkgCreateBaseTables(); --GPKG
SELECT gpkgInsertEpsgSRID(2154); --GPKG

DROP TABLE IF EXISTS generate_series;
CREATE TABLE generate_series(
  value
);

WITH RECURSIVE
  cnt(x) AS (VALUES(1) UNION ALL SELECT x+1 FROM cnt WHERE x<1000)
INSERT INTO generate_series SELECT x FROM cnt;

SELECT value FROM generate_series;

--XXX ReseauUtilite

DROP TABLE IF EXISTS ReseauUtilite;
CREATE TABLE ReseauUtilite (
    fid INTEGER PRIMARY KEY AUTOINCREMENT
  , ogr_pkid TEXT GENERATED ALWAYS AS ('ReseauUtilite_'||fid) VIRTUAL
  , id TEXT NOT NULL UNIQUE
  , Mention TEXT
  , Nom TEXT
  , Responsable TEXT
  , Theme TEXT
);

INSERT INTO ReseauUtilite (id, Mention, Nom, Responsable, Theme)
  VALUES ('Reseau','Test export GML OpenRecoStar','Réseau public de distribution','Enedis','ELECTRD')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ReseauUtilite','attributes','ReseauUtilite'); --GPKG

DROP VIEW IF EXISTS Reseau;
CREATE VIEW Reseau as
select cast(ROW_NUMBER () OVER () as int) fid
  , cast('Reseau_'||ROW_NUMBER () OVER () as text) ogr_pkid
  , cast(id as text) href, cast(null as text) reseauutilite_pkid from ReseauUtilite;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Reseau','attributes','Reseau'); --GPKG

--XXX Cheminement

DROP TABLE IF EXISTS ProtectionMaterialTypeValueReco;
CREATE TABLE ProtectionMaterialTypeValueReco (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ProtectionMaterialTypeValueReco VALUES
  ('CastIron','Fonte')
, ('Concrete','Béton')
, ('Masonry','Maçonnerie')
, ('Other','Autre')
, ('PE','Polyéthylène (PE)')
, ('PEX','Polyéthylène réticulé à haute densité (PEX)')
, ('PVC','PVC')
, ('Steel','Acier')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ProtectionMaterialTypeValueReco','attributes','ProtectionMaterialTypeValueReco'); --GPKG

DROP TABLE IF EXISTS ClassePrecisionReseauValue;
CREATE TABLE ClassePrecisionReseauValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ClassePrecisionReseauValue VALUES
  ('A','Classe A')
, ('B','Classe B')
, ('C','Classe C')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ClassePrecisionReseauValue','attributes','ClassePrecisionReseauValue'); --GPKG

DROP TABLE IF EXISTS EtatCoupeTypeValueReco;
CREATE TABLE EtatCoupeTypeValueReco (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO EtatCoupeTypeValueReco VALUES
  ('Provisoire','Provisoire')
, ('Definitive','Définitive')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('EtatCoupeTypeValueReco','attributes','EtatCoupeTypeValueReco'); --GPKG

--XXX RPD_Fourreau_Reco

DROP TABLE IF EXISTS RPD_Fourreau_Reco;
CREATE TABLE RPD_Fourreau_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_Fourreau_Reco_'||fid) VIRTUAL
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
--, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
, Materiau TEXT NOT NULL REFERENCES ProtectionMaterialTypeValueReco (valeurs)
, DiametreDuFourreau INTEGER NOT NULL
, DiametreDuFourreau_uom TEXT DEFAULT 'mm'
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
, ProfondeurMinNonReg_uom TEXT DEFAULT 'm' -- REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Fourreau_Reco','features','RPD_Fourreau_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Fourreau_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Fourreau_Reco', 'Geometrie' );

--XXX RPD_Galerie_Reco

DROP TABLE IF EXISTS RPD_Galerie_Reco;
CREATE TABLE RPD_Galerie_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_Galerie_Reco_'||fid) VIRTUAL
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
--, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
, Hauteur INTEGER NOT NULL
, Hauteur_uom TEXT DEFAULT 'm'
, Largeur INTEGER NOT NULL
, Largeur_uom TEXT DEFAULT 'm'
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
, ProfondeurMinNonReg_uom TEXT DEFAULT 'm' -- REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Galerie_Reco','features','RPD_Galerie_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Galerie_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Galerie_Reco', 'Geometrie' );

--XXX RPD_PleineTerre_Reco

DROP TABLE IF EXISTS RPD_PleineTerre_Reco_line;
CREATE TABLE RPD_PleineTerre_Reco_line(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_PleineTerre_Reco_line_'||fid) VIRTUAL
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
--, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
, ProfondeurMinNonReg_uom TEXT DEFAULT 'm' -- REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PleineTerre_Reco_line','features','RPD_PleineTerre_Reco_line',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PleineTerre_Reco_line', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PleineTerre_Reco_line', 'Geometrie' );

--XXX RPD_ProtectionMecanique_Reco

DROP TABLE IF EXISTS RPD_ProtectionMecanique_Reco;
CREATE TABLE RPD_ProtectionMecanique_Reco(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_ProtectionMecanique_Reco_'||fid) VIRTUAL
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
--, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
, Materiau TEXT NOT NULL REFERENCES ProtectionMaterialTypeValueReco (valeurs)
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
, ProfondeurMinNonReg_uom TEXT DEFAULT 'm' -- REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_ProtectionMecanique_Reco','features','RPD_ProtectionMecanique_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_ProtectionMecanique_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_ProtectionMecanique_Reco', 'Geometrie' );

--XXX RPD_Aerien_Reco

DROP TABLE IF EXISTS ModePoseValue;
CREATE TABLE ModePoseValue  (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ModePoseValue VALUES
  ('EnFacade','En façade')
, ('Supporte','Supporté')
, ('SurLeSol','Sur le sol')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ModePoseValue','attributes','ModePoseValue'); --GPKG

DROP TABLE IF EXISTS RPD_Aerien_Reco_line;
CREATE TABLE RPD_Aerien_Reco_line(
  fid INTEGER PRIMARY KEY AUTOINCREMENT
, ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_Aerien_Reco_line_'||fid) VIRTUAL
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
--, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
, ModePose TEXT NOT NULL REFERENCES ModePoseValue (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
, ProfondeurMinNonReg_uom TEXT DEFAULT 'm' -- REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Aerien_Reco_line','features','RPD_Aerien_Reco_line',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Aerien_Reco_line', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Aerien_Reco_line', 'Geometrie' );

DROP VIEW IF EXISTS Cheminement;
CREATE VIEW Cheminement as
with all_conso as (
  SELECT ogr_pkid, id, cast('Fourreau' as text) type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Fourreau_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Galerie' as text) type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Galerie_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('PleineTerre' as text) type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PleineTerre_Reco_line
  UNION ALL
  SELECT ogr_pkid, id, cast('ProtectionMecanique' as text) type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_ProtectionMecanique_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('Aerien' as text) type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Aerien_Reco_line
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Cheminement','features','Cheminement',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Cheminement', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

--XXX Cable

-- XXX RPD_CableElectrique_Reco

DROP TABLE IF EXISTS DomaineTensionValue;
CREATE TABLE DomaineTensionValue  (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO DomaineTensionValue VALUES
  ('BT','Basse Tension')
, ('HTA','Haute Tension A')
, ('HTB','Haute Tension B')
, ('Inconnu','Tension inconnue (ouvrages désaffectés par exemple)')
, ('TBT','Très Basse Tension')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('DomaineTensionValue','attributes','DomaineTensionValue'); --GPKG


DROP TABLE IF EXISTS FonctionCableElectriqueValue;
CREATE TABLE	FonctionCableElectriqueValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO FonctionCableElectriqueValue VALUES
  ('Autre','Autre')
, ('Communication','Communication')
, ('DistributionEnergie','Distribution d''énergie')
, ('MiseTerre','Mise à la terre')
, ('Equipotentialité','Equipotentialité')
, ('MaltEquipot','Mise à la terre & équipotentialité')
, ('ProtectionCathodique','Protection cathodique')
, ('TransportEnergie','Transport de l''énergie')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('FonctionCableElectriqueValue','attributes','FonctionCableElectriqueValue'); --GPKG

DROP TABLE IF EXISTS IsolantValueReco;
CREATE TABLE	IsolantValueReco (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO IsolantValueReco VALUES
  ('Thermodurcissable', 'Isolation thermodurcissable')
, ('Reticulee', 'Isolation réticulée')
, ('Nu', 'Câble sans isolant')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('IsolantValueReco','attributes','IsolantValueReco'); --GPKG

DROP TABLE IF EXISTS CableMaterialTypeValue;
CREATE TABLE	CableMaterialTypeValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO CableMaterialTypeValue VALUES
  ('Alu', 'Aluminium')
, ('Cuivre', 'Cuivre')
, ('Alm','Almélec (câble uniforme d''alliage d''aluminium AAAC)')
, ('AluAcier','Alu-Acier (câble bimétallique ACSR)')
, ('AlmAcier','Alm-Acier (câble bimétallique AACSR)')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('CableMaterialTypeValue','attributes','CableMaterialTypeValue'); --GPKG

DROP TABLE IF EXISTS HierarchieBTValue;
CREATE TABLE	HierarchieBTValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO HierarchieBTValue VALUES
  ('Reseau', 'Réseau')
, ('LiaisonReseau', 'Liaison Réseau du branchement')
, ('DerivationIndividuelle', 'Dérivation Individuelle du branchement')
, ('TronconCommun', 'Tronçon Commun du collectif')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('HierarchieBTValue','attributes','HierarchieBTValue'); --GPKG

DROP TABLE IF EXISTS ConditionOfFacilityValueReco;
CREATE TABLE	ConditionOfFacilityValueReco (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ConditionOfFacilityValueReco VALUES
  ('Decommissioned', 'Hors service')
, ('Dismantled', 'Déposé')
, ('Functional', 'En service')
, ('UnderCommissionning', 'En attente de mise en service')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ConditionOfFacilityValueReco','attributes','ConditionOfFacilityValueReco'); --GPKG

DROP TABLE IF EXISTS TypePoseValue; --NOTE : hors reco star
CREATE TABLE TypePoseValue  (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO TypePoseValue VALUES
  ('EnFacade','En façade')
, ('Supporte','Supporté')
, ('SurLeSol','Sur le sol')
, ('Enterre','Enterré')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('TypePoseValue','attributes','TypePoseValue'); --GPKG

DROP TABLE IF EXISTS RPD_CableElectrique_Reco;
CREATE TABLE RPD_CableElectrique_Reco(
    fid INTEGER PRIMARY KEY AUTOINCREMENT
  , ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_CableElectrique_Reco_'||fid) VIRTUAL
  , id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
  --, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
  , DomaineTension TEXT NOT NULL REFERENCES DomaineTensionValue (valeurs)
  , FonctionCable_href TEXT NOT NULL REFERENCES FonctionCableElectriqueValue (valeurs)
  , NombreConducteurs INTEGER NOT NULL
  , Section INTEGER NOT NULL
  , Section_uom TEXT DEFAULT 'mm-2'
  , SectionNeutre INTEGER
  , SectionNeutre_uom TEXT DEFAULT 'mm-2'
  , Isolant TEXT NOT NULL REFERENCES IsolantValueReco (valeurs)
  , Materiau TEXT NOT NULL REFERENCES CableMaterialTypeValue (valeurs)
  , HierarchieBT TEXT REFERENCES HierarchieBTValue (valeurs)  -- NOTE : NOT NULL si DomaineTension = BT
  , Commentaire TEXT
  , Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
  -- Cheminement
  , TypePose TEXT NOT NULL REFERENCES TypePoseValue (valeurs) --NOTE : hors reco star => ModePose pour aérien ou PleineTerre (Enterre)
  , Geometrie LINESTRINGZ NOT NULL UNIQUE
  , PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  , PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  CHECK ((DomaineTension='BT' AND HierarchieBT IS NOT NULL) OR DomaineTension <> 'BT')
);
-- QGIS "HierarchieBT" constraint : ("DomaineTension" = 'BT' and  "HierarchieBT" is not null) or "DomaineTension" <> 'BT'

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_CableElectrique_Reco','features','RPD_CableElectrique_Reco'); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_CableElectrique_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS RPD_CableElectrique_Reco_reseau_reseau;
CREATE VIEW RPD_CableElectrique_Reco_reseau_reseau as
select cast(ROW_NUMBER () OVER () as int) fid, c.ogr_pkid parent_pkid, r.ogr_pkid child_pkid from RPD_CableElectrique_Reco c, Reseau r;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_CableElectrique_Reco_reseau_reseau','attributes','RPD_CableElectrique_Reco_reseau_reseau'); --GPKG

--XXX RPD_CableTerre_Reco

DROP TABLE IF EXISTS ConducteurProtectionValue;
CREATE TABLE	ConducteurProtectionValue (
  valeurs text NOT NULL UNIQUE PRIMARY KEY,
  alias text
);

INSERT INTO ConducteurProtectionValue VALUES
  ('CuivreNu','Cuivre nu')
, ('CuivreIsol','Cuivre isolé')
, ('Sans','Sans')
, ('VertJaune','Vert-jaune')
;

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('ConducteurProtectionValue','attributes','ConducteurProtectionValue'); --GPKG

DROP TABLE IF EXISTS RPD_CableTerre_Reco;
CREATE TABLE RPD_CableTerre_Reco(
    fid INTEGER PRIMARY KEY AUTOINCREMENT
  , ogr_pkid TEXT GENERATED ALWAYS AS ('RPD_CableElectrique_Reco_'||fid) VIRTUAL
  , id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
  --, reseau_href TEXT NOT NULL DEFAULT 'Reseau' REFERENCES ReseauUtilite (id)
  , FonctionCable_href TEXT NOT NULL REFERENCES FonctionCableElectriqueValue (valeurs)
  , NatureCableTerre_href TEXT NOT NULL REFERENCES ConducteurProtectionValue (valeurs)
  , Section INTEGER NOT NULL
  , Section_uom TEXT DEFAULT 'mm-2'
  , Commentaire TEXT
  , Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
  -- Cheminement
  , TypePose TEXT NOT NULL REFERENCES TypePoseValue (valeurs) --NOTE : hors reco star => ModePose pour aérien ou PleineTerre (Enterre)
  , Geometrie LINESTRINGZ NOT NULL UNIQUE
  , PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  , PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  , noeudreseau_href TEXT --TODO : UUID noeud QUESTION : quel noeud?
);

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_CableTerre_Reco','features','RPD_CableTerre_Reco'); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_CableTerre_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS Cable;
CREATE VIEW Cable as
with all_conso as (
  SELECT ogr_pkid, id, cast('CableElectrique' as text) type_cable, TypePose, FonctionCable_href FonctionCable, Section, Commentaire, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_CableElectrique_Reco
  UNION ALL
  SELECT ogr_pkid, id, cast('CableTerre' as text) type_cable, TypePose, FonctionCable_href FonctionCable, Section, Commentaire, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_CableTerre_Reco
) select cast(ROW_NUMBER () OVER () as int) fid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Cable','features','Cable',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Cable', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

--XXX Cheminement par defaut

DROP VIEW IF EXISTS RPD_PleineTerre_Reco_virt;
CREATE VIEW RPD_PleineTerre_Reco_virt as
with difference as (
SELECT c.id, coalesce(ST_Difference(c."Geometrie", ST_Union(h."Geometrie")), c."Geometrie") Geometrie, c.PrecisionXY,c.PrecisionZ
FROM Cable c
LEFT JOIN Cheminement h ON ST_Within(h."Geometrie", c."Geometrie")
WHERE TypePose = 'Enterre'
group by c.id, c.PrecisionXY, c.PrecisionZ, c."Geometrie"
)
select cast(ROW_NUMBER () OVER () as int) fid, cast('RPD_PleineTerre_Reco_virt_'||ROW_NUMBER () OVER () as text) ogr_pkid, cast((CreateUUID()) as text) id
, cast(Null as text) CoupeType, cast(Null as text) EtatCoupeType, ST_GeometryN(c.Geometrie, s.value) Geometrie
, cast(Null as double) ProfondeurMinNonReg, cast('mm-2' as text) ProfondeurMinNonReg_uom, c.PrecisionXY, c.PrecisionZ
from difference c
, generate_series s ON s.value <= ST_NumGeometries(c.Geometrie)
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PleineTerre_Reco_virt','features','RPD_PleineTerre_Reco_virt',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PleineTerre_Reco_virt', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP TABLE IF EXISTS RPD_PleineTerre_Reco;
CREATE TABLE RPD_PleineTerre_Reco as --TODO: VM à rafraichir avant chaque export
with uniiion as (
select * from RPD_PleineTerre_Reco_line
union all
select * from RPD_PleineTerre_Reco_virt
)
select cast(ROW_NUMBER () OVER () as int) fid, ogr_pkid, id, CoupeType, EtatCoupeType, Geometrie, ProfondeurMinNonReg, ProfondeurMinNonReg_uom, PrecisionXY, PrecisionZ
from uniiion
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PleineTerre_Reco','features','RPD_PleineTerre_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PleineTerre_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS RPD_Aerien_Reco_virt;
CREATE VIEW RPD_Aerien_Reco_virt as
with difference as (
SELECT c.id, coalesce(ST_Difference(c."Geometrie", ST_Union(h."Geometrie")), c."Geometrie") Geometrie, c.PrecisionXY,c.PrecisionZ
FROM Cable c
LEFT JOIN Cheminement h ON ST_Within(h."Geometrie", c."Geometrie")
WHERE NOT TypePose = 'Enterre'
group by c.id, c.PrecisionXY, c.PrecisionZ, c."Geometrie"
)
select cast(ROW_NUMBER () OVER () as int) fid, cast('RPD_Aerien_Reco_virt'||ROW_NUMBER () OVER () as text) ogr_pkid, cast((CreateUUID()) as text) id
, cast(Null as text) ModePose, ST_GeometryN(c.Geometrie, s.value) Geometrie
, cast(Null as double) ProfondeurMinNonReg, cast('mm-2' as text) ProfondeurMinNonReg_uom, c.PrecisionXY, c.PrecisionZ
from difference c
, generate_series s ON s.value <= ST_NumGeometries(c.Geometrie)
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Aerien_Reco_virt','features','RPD_Aerien_Reco_virt',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Aerien_Reco_virt', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP TABLE IF EXISTS RPD_Aerien_Reco;
CREATE TABLE RPD_Aerien_Reco as --TODO: VM à rafraichir avant chaque export
with uniiion as (
select * from RPD_Aerien_Reco_line
union all
select * from RPD_Aerien_Reco_virt
)
select cast(ROW_NUMBER () OVER () as int) fid, ogr_pkid, id, ModePose, Geometrie, ProfondeurMinNonReg, ProfondeurMinNonReg_uom, PrecisionXY, PrecisionZ
from uniiion
;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Aerien_Reco','features','RPD_Aerien_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Aerien_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

--XXX RELATIONS CHEMINEMENT / CABLE
DROP VIEW IF EXISTS Cheminement_Cables;
CREATE VIEW Cheminement_Cables AS
with uniiion as (
  select cast(c.id as text) cables_href
  , cast(h.id as text) cheminement_href
  FROM Cable c
  JOIN RPD_Fourreau_Reco h ON ST_Within(h."Geometrie", c."Geometrie")
  union all
  select cast(c.id as text) cables_href
  , cast(h.id as text) cheminement_href
  FROM Cable c
  JOIN RPD_ProtectionMecanique_Reco h ON ST_Within(h."Geometrie", c."Geometrie")
  union all
  select cast(c.id as text) cables_href
  , cast(h.id as text) cheminement_href
  FROM Cable c
  JOIN RPD_Galerie_Reco h ON ST_Within(h."Geometrie", c."Geometrie")
  union all
  select cast(c.id as text) cables_href
  , cast(h.id as text) cheminement_href
  FROM Cable c
  JOIN RPD_PleineTerre_Reco h ON ST_Within(h."Geometrie", c."Geometrie")
  union all
  select cast(c.id as text) cables_href
  , cast(h.id as text) cheminement_href
  FROM Cable c
  JOIN RPD_Aerien_Reco h ON ST_Within(h."Geometrie", c."Geometrie")
)
select cast(ROW_NUMBER () OVER () as int) fid
, 'Cheminement_Cables_'||ROW_NUMBER () OVER () ogr_pkid
, (CreateUUID()) id
, cast(null as text) cables_cables_rpd_cableelectrique_reco_pkid
, cast(null as text) cables_cables_rpd_cableterre_reco_pkid
, cast(null as text) cheminement_cheminement_rpd_aerien_reco_pkid
, cast(null as text) cheminement_cheminement_rpd_fourreau_reco_pkid
, cast(null as text) cheminement_cheminement_rpd_galerie_reco_pkid
, cast(null as text) cheminement_cheminement_rpd_pleineterre_reco_pkid
, cast(null as text) cheminement_cheminement_rpd_protectionmecanique_reco_pkid
, * from uniiion
;
--
INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Cheminement_Cables','attributes','Cheminement_Cables'); --GPKG
