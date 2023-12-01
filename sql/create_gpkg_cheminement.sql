select load_extension("/usr/local/lib/mod_spatialite.dylib");
SELECT EnableGpkgMode(); --GPKG
SELECT gpkgCreateBaseTables(); --GPKG
SELECT gpkgInsertEpsgSRID(2154); --GPKG

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
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Materiau TEXT NOT NULL REFERENCES ProtectionMaterialTypeValueReco (valeurs)
, DiametreDuFourreau INTEGER NOT NULL
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
-- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Fourreau_Reco','features','RPD_Fourreau_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Fourreau_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Fourreau_Reco', 'Geometrie' );

--XXX RPD_Galerie_Reco

DROP TABLE IF EXISTS RPD_Galerie_Reco;
CREATE TABLE RPD_Galerie_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Hauteur INTEGER NOT NULL
, Largeur INTEGER NOT NULL
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
-- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Galerie_Reco','features','RPD_Galerie_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Galerie_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Galerie_Reco', 'Geometrie' );

--XXX RPD_PleineTerre_Reco

DROP TABLE IF EXISTS RPD_PleineTerre_Reco;
CREATE TABLE RPD_PleineTerre_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
-- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PleineTerre_Reco','features','RPD_PleineTerre_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PleineTerre_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_PleineTerre_Reco', 'Geometrie' );

--XXX RPD_ProtectionMecanique_Reco

DROP TABLE IF EXISTS RPD_ProtectionMecanique_Reco;
CREATE TABLE RPD_ProtectionMecanique_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, Materiau TEXT NOT NULL REFERENCES ProtectionMaterialTypeValueReco (valeurs)
, CoupeType TEXT
, EtatCoupeType TEXT REFERENCES EtatCoupeTypeValueReco (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
-- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
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

DROP TABLE IF EXISTS RPD_Aerien_Reco;
CREATE TABLE RPD_Aerien_Reco(
  pkid INTEGER PRIMARY KEY AUTOINCREMENT
, id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
, ModePose TEXT NOT NULL REFERENCES ModePoseValue (valeurs)
, Geometrie LINESTRINGZ NOT NULL UNIQUE
, ProfondeurMinNonReg DOUBLE
-- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
, PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
, PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Aerien_Reco','features','RPD_Aerien_Reco',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Aerien_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG
SELECT gpkgAddSpatialIndex('RPD_Aerien_Reco', 'Geometrie' );

DROP VIEW IF EXISTS Cheminement;
CREATE VIEW Cheminement as
with all_conso as (
  SELECT id, 'Fourreau' type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Fourreau_Reco
  UNION ALL
  SELECT id, 'Galerie' type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Galerie_Reco
  UNION ALL
  SELECT id, 'PleineTerre' type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_PleineTerre_Reco
  UNION ALL
  SELECT id, 'ProtectionMecanique' type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_ProtectionMecanique_Reco
  UNION ALL
  SELECT id, 'Aerien' type_cheminement, ProfondeurMinNonReg, PrecisionXY, PrecisionZ, Geometrie FROM RPD_Aerien_Reco
) select ROW_NUMBER () OVER () pkid, * from all_conso;

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
    pkid INTEGER PRIMARY KEY AUTOINCREMENT
  , id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
  , DomaineTension TEXT NOT NULL REFERENCES DomaineTensionValue (valeurs)
  , FonctionCable TEXT NOT NULL REFERENCES FonctionCableElectriqueValue (valeurs)
  , NombreConducteurs INTEGER NOT NULL
  , Section INTEGER NOT NULL
  , SectionNeutre INTEGER
  , Isolant TEXT NOT NULL REFERENCES IsolantValueReco (valeurs)
  , Materiau TEXT NOT NULL REFERENCES CableMaterialTypeValue (valeurs)
  , HierarchieBT TEXT REFERENCES HierarchieBTValue (valeurs)
  , Commentaire TEXT
  , Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
  -- Cheminement
  , TypePose TEXT NOT NULL REFERENCES TypePoseValue (valeurs) --NOTE : hors reco star => ModePose pour aérien ou PleineTerre (Enterre)
  , Geometrie LINESTRINGZ NOT NULL UNIQUE
  -- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
  , PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  , PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_CableElectrique_Reco','features','RPD_CableElectrique_Reco'); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_CableElectrique_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

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
    pkid INTEGER PRIMARY KEY AUTOINCREMENT
  , id TEXT NOT NULL UNIQUE DEFAULT (CreateUUID())
  , FonctionCable TEXT NOT NULL REFERENCES FonctionCableElectriqueValue (valeurs)
  , NatureCableTerre TEXT NOT NULL REFERENCES ConducteurProtectionValue (valeurs)
  , Section INTEGER NOT NULL
  , Commentaire TEXT
  , Statut TEXT NOT NULL REFERENCES ConditionOfFacilityValueReco (valeurs)
  -- Cheminement
  , TypePose TEXT NOT NULL REFERENCES TypePoseValue (valeurs) --NOTE : hors reco star => ModePose pour aérien ou PleineTerre (Enterre)
  , Geometrie LINESTRINGZ NOT NULL UNIQUE
  -- , ProfondeurMinNonReg_uom TEXT REFERENCES ProfondeurMinNonReg_uomValue (valeurs)
  , PrecisionXY TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
  , PrecisionZ TEXT NOT NULL REFERENCES ClassePrecisionReseauValue (valeurs)
);

INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('RPD_CableTerre_Reco','features','RPD_CableTerre_Reco'); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_CableTerre_Reco', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS Cable;
CREATE VIEW Cable as
with all_conso as (
  SELECT id, 'CableElectrique' type_cable, TypePose, FonctionCable, Section, Commentaire, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_CableElectrique_Reco
  UNION ALL
  SELECT id, 'CableTerre' type_cable, TypePose, FonctionCable, Section, Commentaire, Statut, PrecisionXY, PrecisionZ, Geometrie FROM RPD_CableTerre_Reco
) select ROW_NUMBER () OVER () pkid, * from all_conso;

INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('Cable','features','Cable',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('Cable', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

--XXX Cheminement par defaut

DROP VIEW IF EXISTS RPD_PleineTerre_Reco_virt;
CREATE VIEW RPD_PleineTerre_Reco_virt as --FIXME : Spliter les MULTILINESTRING pour l'export
SELECT ROW_NUMBER () OVER () pkid, c.id, coalesce(ST_Difference(c."Geometrie", ST_Union(h."Geometrie")), c."Geometrie") Geometrie, Null ProfondeurMinNonReg, c.PrecisionXY,c.PrecisionZ
FROM Cable c
LEFT JOIN Cheminement h ON ST_Within(h."Geometrie", c."Geometrie")
WHERE TypePose = 'Enterre'
group by c.id, c.PrecisionXY, c.PrecisionZ, c."Geometrie"
;
INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_PleineTerre_Reco_virt','features','RPD_PleineTerre_Reco_virt',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_PleineTerre_Reco_virt', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

DROP VIEW IF EXISTS RPD_Aerien_Reco_virt;
CREATE VIEW RPD_Aerien_Reco_virt as --FIXME : Spliter les MULTILINESTRING pour l'export
SELECT ROW_NUMBER () OVER () pkid, c.id, coalesce(ST_Difference(c."Geometrie", ST_Union(h."Geometrie")), c."Geometrie") Geometrie, Null ProfondeurMinNonReg, c.PrecisionXY,c.PrecisionZ
FROM Cable c
LEFT JOIN Cheminement h ON ST_Within(h."Geometrie", c."Geometrie")
WHERE NOT TypePose = 'Enterre'
group by c.id, c.PrecisionXY, c.PrecisionZ, c."Geometrie"
;
INSERT INTO gpkg_contents (table_name, data_type, identifier, srs_id) values ('RPD_Aerien_Reco_virt','features','RPD_Aerien_Reco_virt',2154); --GPKG
INSERT INTO gpkg_geometry_columns (table_name, column_name, geometry_type_name, srs_id, z, m) values ('RPD_Aerien_Reco_virt', 'Geometrie', 'LINESTRING', 2154, 1, 0); --GPKG

--XXX RELATIONS CHEMINEMENT / CABLE
-- TODO :transformer en vue selon intersect et spliter les MULTILINESTRING avec uuid distinct
-- DROP TABLE IF EXISTS Cheminement_Cables;
-- CREATE TABLE Cheminement_Cables( --TODO : voir xsd pour les noms des attributs
--   base_id INTEGER NOT NULL REFERENCES Cable (id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
-- , related_id INTEGER NOT NULL UNIQUE REFERENCES Cheminement (id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
-- );
--
-- INSERT INTO gpkg_contents (table_name, data_type, identifier) values ('Cheminement_Cables','attributes','Cheminement_Cables'); --GPKG


-- TODO : intégrer les valeurs de mesures uom
