-- ============================================
-- Exercice 4 : Agregations et statistiques
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- 1. Nombre total de streams par streamer, meme si le streamer n'a aucun stream.
SELECT
    s.pseudo,
    COUNT(st.id_stream) AS nb_streams
FROM streamer s
LEFT JOIN stream st ON st.id_streamer = s.id_streamer
GROUP BY s.id_streamer, s.pseudo
ORDER BY nb_streams DESC, s.pseudo;

-- 2. Montant total des paliers de defis par etat de validation.
SELECT
    CASE
        WHEN etat_validation THEN 'VALIDE'
        ELSE 'NON_VALIDE'
    END AS statut_validation,
    SUM(montant_palier) AS total_paliers
FROM defi
GROUP BY etat_validation
ORDER BY statut_validation;

-- 3. Streamers ayant au moins 2 defis.
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis
FROM streamer s
INNER JOIN participation_defi pd ON pd.id_streamer = s.id_streamer
GROUP BY s.id_streamer, s.pseudo
HAVING COUNT(pd.id_defi) >= 2
ORDER BY nb_defis DESC, s.pseudo;

-- 4. Duree de chaque stream et duree moyenne globale.
SELECT
    st.titre,
    ROUND((EXTRACT(EPOCH FROM (st.heure_fin - st.heure_debut)) / 3600)::numeric, 2) AS duree_heures,
    ROUND((AVG(EXTRACT(EPOCH FROM (st.heure_fin - st.heure_debut)) / 3600) OVER())::numeric, 2) AS duree_moyenne_globale
FROM stream st
ORDER BY st.heure_debut;

-- 5. Streamers ayant effectivement lance au moins un stream.
SELECT
    s.pseudo,
    st.titre,
    st.heure_debut
FROM streamer s
INNER JOIN stream st ON st.id_streamer = s.id_streamer
ORDER BY s.pseudo, st.heure_debut;

