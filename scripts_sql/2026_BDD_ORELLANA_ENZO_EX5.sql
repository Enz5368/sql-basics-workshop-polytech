-- ============================================
-- Exercice 5 : UPDATE et DELETE
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- Partie A : UPDATE

-- 1. Augmenter de 10% le montant palier du defi "Karaoke geant en live".
UPDATE defi
SET montant_palier = montant_palier * 1.10
WHERE intitule = 'Karaoke geant en live';

SELECT intitule, montant_palier
FROM defi
WHERE intitule = 'Karaoke geant en live';

-- 2. Valider tous les defis non valides ayant au moins 3 participants.
UPDATE defi
SET etat_validation = TRUE
WHERE etat_validation = FALSE
  AND id_defi IN (
      SELECT id_defi
      FROM participation_defi
      GROUP BY id_defi
      HAVING COUNT(id_streamer) >= 3
  );

SELECT
    d.intitule,
    d.etat_validation,
    COUNT(pd.id_streamer) AS nb_participants
FROM defi d
LEFT JOIN participation_defi pd ON pd.id_defi = d.id_defi
GROUP BY d.id_defi, d.intitule, d.etat_validation
ORDER BY nb_participants DESC, d.intitule;

-- Partie B : DELETE

-- 3. Supprimer les streams non termines.
SELECT id_stream, titre, date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL;

DELETE FROM stream
WHERE date_fin_effective IS NULL;

SELECT id_stream, titre, date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL;

-- 4. Supprimer les creneaux passes.
-- Remarque : comme les donnees de test sont en 2025, cette suppression
-- effacera les creneaux si le script est execute apres 2025.
SELECT id_creneau, date_fin_autorisee
FROM creneau
WHERE date_fin_autorisee < CURRENT_DATE;

DELETE FROM creneau
WHERE date_fin_autorisee < CURRENT_DATE;

