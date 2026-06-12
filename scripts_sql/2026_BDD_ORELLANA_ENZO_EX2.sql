-- ============================================
-- Exercice 2 : Requetes SELECT simples
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- 1. Tous les streamers avec leur URL Twitch, ordonnes par pseudo.
SELECT pseudo, url_twitch
FROM streamer
ORDER BY pseudo;

-- 2. Les creneaux du samedi 2025-09-06.
SELECT id_creneau, id_streamer, date_debut_autorisee, date_fin_autorisee
FROM creneau
WHERE DATE(date_debut_autorisee) = '2025-09-06'
   OR DATE(date_fin_autorisee) = '2025-09-06'
ORDER BY date_debut_autorisee;

-- 3. Les defis valides ayant un montant palier superieur a 5000 euros.
SELECT intitule, montant_palier, etat_validation
FROM defi
WHERE etat_validation = TRUE
  AND montant_palier > 5000
ORDER BY montant_palier DESC;

-- 4. Les streams non termines.
SELECT id_stream, titre, heure_debut, heure_fin, date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL
ORDER BY heure_debut;

