-- ============================================
-- Exercice 6 : Requetes avancees M:N
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- 1. Streamers ayant au moins un defi.
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis
FROM streamer s
INNER JOIN participation_defi pd ON pd.id_streamer = s.id_streamer
GROUP BY s.id_streamer, s.pseudo
ORDER BY nb_defis DESC, s.pseudo;

-- 2. Defis n'ayant aucun participant.
SELECT
    d.intitule,
    d.montant_palier
FROM defi d
LEFT JOIN participation_defi pd ON pd.id_defi = d.id_defi
WHERE pd.id_streamer IS NULL
ORDER BY d.intitule;

-- 3. Defis ayant plus de 2 participants.
SELECT
    d.intitule,
    d.montant_palier,
    COUNT(pd.id_streamer) AS nb_participants
FROM defi d
LEFT JOIN participation_defi pd ON pd.id_defi = d.id_defi
GROUP BY d.id_defi, d.intitule, d.montant_palier
HAVING COUNT(pd.id_streamer) > 2
ORDER BY nb_participants DESC, d.intitule;

-- 4. Nombre de defis par streamer avec montant total engage.
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total
FROM streamer s
LEFT JOIN participation_defi pd ON pd.id_streamer = s.id_streamer
LEFT JOIN defi d ON d.id_defi = pd.id_defi
GROUP BY s.id_streamer, s.pseudo
ORDER BY montant_total DESC, s.pseudo;

-- 5. Streamers et creneaux avec nombre de streams effectues par creneau.
SELECT
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    COUNT(st.id_stream) AS nb_streams
FROM streamer s
INNER JOIN creneau c ON c.id_streamer = s.id_streamer
LEFT JOIN stream st ON st.id_creneau = c.id_creneau
GROUP BY s.id_streamer, s.pseudo, c.id_creneau, c.date_debut_autorisee, c.date_fin_autorisee
ORDER BY s.pseudo, c.date_debut_autorisee;

