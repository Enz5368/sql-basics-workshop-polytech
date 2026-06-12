-- ============================================
-- Exercice 3 : Jointures simples
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- 1. Streamers et leurs creneaux.
SELECT
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM streamer s
INNER JOIN creneau c ON c.id_streamer = s.id_streamer
ORDER BY s.pseudo, c.date_debut_autorisee;

-- 2. Streams avec informations du streamer et du creneau.
SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM stream st
INNER JOIN streamer s ON s.id_streamer = st.id_streamer
INNER JOIN creneau c ON c.id_creneau = st.id_creneau
WHERE DATE(c.date_debut_autorisee) IN ('2025-09-05', '2025-09-06')
   OR DATE(c.date_fin_autorisee) IN ('2025-09-05', '2025-09-06')
ORDER BY c.date_debut_autorisee, s.pseudo;

-- 3. Defis et leurs participants.
SELECT
    d.intitule,
    s.pseudo,
    d.montant_palier
FROM defi d
INNER JOIN participation_defi pd ON pd.id_defi = d.id_defi
INNER JOIN streamer s ON s.id_streamer = pd.id_streamer
ORDER BY d.intitule, s.pseudo;

