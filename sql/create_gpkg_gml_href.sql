-- SCRIPTS A EXECUTER avant chaque EXPORT GML dans QGIS !
-- Permet de mettre à jour les relations entre les objets

--XXX UPDATE parent_ogr_pkid
UPDATE ReseauUtilite SET ogr_pkid = 'ReseauUtilite_'||fid;
UPDATE RPD_Galerie_Reco SET ogr_pkid = 'RPD_Galerie_Reco_'||fid;
UPDATE RPD_PleineTerre_Reco_line SET ogr_pkid = 'RPD_PleineTerre_Reco_line_'||fid;
UPDATE RPD_ProtectionMecanique_Reco SET ogr_pkid = 'RPD_ProtectionMecanique_Reco_'||fid;
UPDATE RPD_Aerien_Reco_line SET ogr_pkid = 'RPD_Aerien_Reco_line_'||fid;
UPDATE RPD_CableElectrique_Reco SET ogr_pkid = 'RPD_CableElectrique_Reco_'||fid;
UPDATE RPD_CableTerre_Reco SET ogr_pkid = 'RPD_CableTerre_Reco_'||fid;
UPDATE RPD_Fourreau_Reco SET ogr_pkid = 'RPD_Fourreau_Reco_'||fid;
UPDATE RPD_JeuBarres_Reco SET ogr_pkid = 'RPD_JeuBarres_Reco_'||fid;
UPDATE RPD_Jonction_Reco SET ogr_pkid = 'RPD_Jonction_Reco_'||fid;
UPDATE RPD_Plage_Reco SET ogr_pkid = 'RPD_Plage_Reco_'||fid;
UPDATE RPD_OuvrageCollectifBranchement_Reco SET ogr_pkid = 'RPD_OuvrageCollectifBranchement_Reco_'||fid;
UPDATE RPD_PointDeComptage_Reco SET ogr_pkid = 'RPD_PointDeComptage_Reco_'||fid;
UPDATE RPD_PosteElectrique_Reco SET ogr_pkid = 'RPD_PosteElectrique_Reco_'||fid;
UPDATE RPD_RaccordementModulaire_Reco SET ogr_pkid = 'RPD_RaccordementModulaire_Reco_'||fid;
UPDATE RPD_Terre_Reco SET ogr_pkid = 'RPD_Terre_Reco_'||fid;
UPDATE RPD_PointLeveOuvrageReseau_Reco SET ogr_pkid = 'RPD_PointLeveOuvrageReseau_Reco_'||fid;
UPDATE RPD_BatimentTechnique_Reco_line SET ogr_pkid = 'RPD_BatimentTechnique_Reco_'||fid;
UPDATE RPD_EnceinteCloturee_Reco_line SET ogr_pkid = 'RPD_EnceinteCloturee_Reco_'||fid;
UPDATE RPD_Coffret_Reco SET ogr_pkid = 'RPD_Coffret_Reco_'||fid;
UPDATE RPD_Support_Reco SET ogr_pkid = 'RPD_Support_Reco_'||fid;

--XXX VM Cheminement RPD_PleineTerre_Reco
DROP TABLE IF EXISTS RPD_PleineTerre_Reco;
CREATE TABLE RPD_PleineTerre_Reco as
with uniiion as (
select * from RPD_PleineTerre_Reco_line
union all
select * from RPD_PleineTerre_Reco_virt
)
select cast(ROW_NUMBER () OVER () as int) fid, ogr_pkid, id, CoupeType, EtatCoupeType, Geometrie, ProfondeurMinNonReg, ProfondeurMinNonReg_uom, PrecisionXY, PrecisionZ
from uniiion
;

--XXX VM Cheminement RPD_Aerien_Reco
DROP TABLE IF EXISTS RPD_Aerien_Reco;
CREATE TABLE RPD_Aerien_Reco as
with uniiion as (
select * from RPD_Aerien_Reco_line
union all
select * from RPD_Aerien_Reco_virt
)
select cast(ROW_NUMBER () OVER () as int) fid, ogr_pkid, id, ModePose, Geometrie, ProfondeurMinNonReg, ProfondeurMinNonReg_uom, PrecisionXY, PrecisionZ
from uniiion
;

--XXX Relations Conteneur / Noeud
UPDATE RPD_PosteElectrique_Reco SET conteneur_href = null;
UPDATE RPD_Jonction_Reco SET conteneur_href = null;
UPDATE RPD_JeuBarres_Reco SET conteneur_href = null;
UPDATE RPD_RaccordementModulaire_Reco SET conteneur_href = null;
UPDATE RPD_Plage_Reco SET conteneur_href = null;
UPDATE RPD_PointDeComptage_Reco SET conteneur_href = null;
UPDATE RPD_OuvrageCollectifBranchement_Reco SET conteneur_href = null;
UPDATE RPD_Terre_Reco SET conteneur_href = null;

UPDATE RPD_PosteElectrique_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_Jonction_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_JeuBarres_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_RaccordementModulaire_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_Plage_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_PointDeComptage_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_OuvrageCollectifBranchement_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
UPDATE RPD_Terre_Reco SET conteneur_href = h.conteneur_id FROM Conteneur_Noeud h WHERE h.noeud_id = id;
