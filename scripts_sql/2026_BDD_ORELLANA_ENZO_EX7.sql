-- ============================================
-- Exercice 7 : Validations avec CASE
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- Partie A : validation des streams par rapport aux creneaux.
SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_creneau
FROM stream st
INNER JOIN streamer s ON s.id_streamer = st.id_streamer
INNER JOIN creneau c ON c.id_creneau = st.id_creneau
ORDER BY s.pseudo, st.heure_debut;

-- 2. Streams invalides uniquement.
SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin
FROM stream st
INNER JOIN streamer s ON s.id_streamer = st.id_streamer
INNER JOIN creneau c ON c.id_creneau = st.id_creneau
WHERE st.heure_debut < c.date_debut_autorisee
   OR st.heure_fin > c.date_fin_autorisee
ORDER BY s.pseudo, st.heure_debut;

-- Partie B : detection des depassements de fin.
SELECT
    st.titre,
    s.pseudo,
    st.heure_fin AS heure_fin_prevue,
    st.date_fin_effective,
    CASE
        WHEN st.date_fin_effective IS NULL THEN 'NON_TERMINE'
        WHEN st.date_fin_effective <= st.heure_fin THEN 'OK'
        ELSE 'DEPASSEMENT'
    END AS statut_depassement,
    CASE
        WHEN st.date_fin_effective > st.heure_fin
        THEN ROUND((EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric, 2)
        ELSE 0
    END AS depassement_minutes
FROM stream st
INNER JOIN streamer s ON s.id_streamer = st.id_streamer
ORDER BY s.pseudo, st.heure_fin;

-- 4. Resume des retards.
SELECT
    COUNT(*) AS nb_streams_en_retard,
    ROUND(AVG(EXTRACT(EPOCH FROM (date_fin_effective - heure_fin)) / 60)::numeric, 2) AS retard_moyen_minutes
FROM stream
WHERE date_fin_effective > heure_fin;

-- Vue complete : respect du creneau + depassement de fin.
SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    st.date_fin_effective,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_creneau,
    CASE
        WHEN st.date_fin_effective IS NULL THEN 'NON_TERMINE'
        WHEN st.date_fin_effective <= st.heure_fin THEN 'OK'
        ELSE 'DEPASSEMENT'
    END AS statut_depassement,
    CASE
        WHEN st.date_fin_effective > st.heure_fin
        THEN ROUND((EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric, 2)
        ELSE 0
    END AS depassement_minutes
FROM stream st
INNER JOIN streamer s ON s.id_streamer = st.id_streamer
INNER JOIN creneau c ON c.id_creneau = st.id_creneau
ORDER BY s.pseudo, st.heure_debut;

