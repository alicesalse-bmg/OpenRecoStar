-- SCRIPTS A EXECUTER avant chaque EXPORT GML
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
UPDATE RPD_PosteElectrique_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_Jonction_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_JeuBarres_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_RaccordementModulaire_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_Plage_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_PointDeComptage_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_OuvrageCollectifBranchement_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;

UPDATE RPD_Terre_Reco
SET conteneur_href = h.conteneur_id
FROM Conteneur_Noeud h
WHERE h.noeud_id = id;
