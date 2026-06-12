-- ============================================
-- Exercice 1 : Creation et population de la base
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

DROP TABLE IF EXISTS participation_defi;
DROP TABLE IF EXISTS stream;
DROP TABLE IF EXISTS creneau;
DROP TABLE IF EXISTS defi;
DROP TABLE IF EXISTS streamer;

CREATE TABLE streamer (
    id_streamer SERIAL PRIMARY KEY,
    pseudo VARCHAR(100) NOT NULL UNIQUE,
    url_twitch VARCHAR(255)
);

CREATE TABLE creneau (
    id_creneau SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    date_debut_autorisee TIMESTAMP NOT NULL,
    date_fin_autorisee TIMESTAMP NOT NULL,
    CONSTRAINT fk_creneau_streamer
        FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,
    CONSTRAINT chk_creneau_dates
        CHECK (date_fin_autorisee > date_debut_autorisee)
);

CREATE TABLE defi (
    id_defi SERIAL PRIMARY KEY,
    intitule VARCHAR(255) NOT NULL,
    montant_palier DECIMAL(12,2) NOT NULL,
    etat_validation BOOLEAN DEFAULT FALSE,
    CONSTRAINT chk_defi_montant
        CHECK (montant_palier > 0)
);

CREATE TABLE stream (
    id_stream SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    id_creneau INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    heure_debut TIMESTAMP NOT NULL,
    heure_fin TIMESTAMP NOT NULL,
    date_fin_effective TIMESTAMP,
    CONSTRAINT fk_stream_streamer
        FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,
    CONSTRAINT fk_stream_creneau
        FOREIGN KEY (id_creneau) REFERENCES creneau(id_creneau)
        ON DELETE CASCADE,
    CONSTRAINT chk_stream_dates
        CHECK (heure_fin > heure_debut)
);

CREATE TABLE participation_defi (
    id_streamer INT NOT NULL,
    id_defi INT NOT NULL,
    PRIMARY KEY (id_streamer, id_defi),
    CONSTRAINT fk_participation_streamer
        FOREIGN KEY (id_streamer) REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,
    CONSTRAINT fk_participation_defi
        FOREIGN KEY (id_defi) REFERENCES defi(id_defi)
        ON DELETE CASCADE
);

-- Dictionnaire streamer :
-- pseudo : nom public du streamer, unique et obligatoire.
-- url_twitch : adresse de la chaine Twitch.
INSERT INTO streamer (pseudo, url_twitch) VALUES
('ZeratoR', 'https://www.twitch.tv/zerator'),
('BagheraJones', 'https://www.twitch.tv/bagherajones'),
('Etoiles', 'https://www.twitch.tv/etoiles'),
('JoueurDuGrenier', 'https://www.twitch.tv/joueur_du_grenier'),
('Ultia', 'https://www.twitch.tv/ultia'),
('Ponce', 'https://www.twitch.tv/ponce'),
('Maghla', 'https://www.twitch.tv/maghla'),
('AngleDroit', 'https://www.twitch.tv/angledroit'),
('Domingo', 'https://www.twitch.tv/domingo'),
('MisterMV', 'https://www.twitch.tv/mistermv');

-- Dictionnaire creneau :
-- chaque ligne indique une periode autorisee pour un streamer.
INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee) VALUES
(1, '2025-09-05 18:00:00', '2025-09-06 01:00:00'),
(1, '2025-09-06 14:00:00', '2025-09-06 22:00:00'),
(1, '2025-09-07 10:00:00', '2025-09-07 18:00:00'),
(2, '2025-09-05 19:00:00', '2025-09-06 02:00:00'),
(2, '2025-09-06 11:00:00', '2025-09-06 19:00:00'),
(3, '2025-09-05 20:00:00', '2025-09-06 03:00:00'),
(3, '2025-09-06 09:00:00', '2025-09-06 17:00:00'),
(4, '2025-09-05 21:00:00', '2025-09-06 04:00:00'),
(4, '2025-09-06 15:00:00', '2025-09-06 23:00:00'),
(5, '2025-09-05 18:30:00', '2025-09-06 00:30:00'),
(5, '2025-09-06 13:00:00', '2025-09-06 21:00:00'),
(6, '2025-09-05 22:00:00', '2025-09-06 05:00:00'),
(6, '2025-09-06 10:00:00', '2025-09-06 18:00:00'),
(7, '2025-09-05 17:00:00', '2025-09-06 00:00:00'),
(7, '2025-09-06 16:00:00', '2025-09-07 00:00:00'),
(8, '2025-09-05 18:00:00', '2025-09-06 02:00:00'),
(8, '2025-09-06 12:00:00', '2025-09-06 20:00:00'),
(9, '2025-09-05 19:30:00', '2025-09-06 03:30:00'),
(9, '2025-09-06 14:30:00', '2025-09-06 22:30:00'),
(10, '2025-09-05 20:30:00', '2025-09-06 04:30:00'),
(10, '2025-09-06 08:30:00', '2025-09-06 16:30:00');

-- Dictionnaire defi :
-- montant_palier est stocke en DECIMAL pour eviter les erreurs d'arrondi.
INSERT INTO defi (intitule, montant_palier, etat_validation) VALUES
('Karaoke geant en live', 750.00, TRUE),
('Speedrun surprise', 1200.00, FALSE),
('Tournoi Mario Kart', 2500.00, TRUE),
('Live horreur de nuit', 6000.00, FALSE),
('Cosplay pendant 24h', 8500.00, TRUE),
('Quiz culture generale', 10000.00, FALSE),
('Session cuisine improbable', 15000.00, TRUE),
('Blind test communautaire', 22000.00, FALSE),
('Grande roue des gages', 50000.00, TRUE),
('Defi final collectif', 100000.00, FALSE);

-- Correspondances streamer / defi : certains defis sont solos, d'autres collectifs.
INSERT INTO participation_defi (id_streamer, id_defi) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(1, 10),
(2, 10),
(3, 10),
(4, 9),
(5, 9),
(6, 9),
(7, 4),
(8, 4),
(9, 3),
(10, 3);

-- Dictionnaire stream :
-- date_fin_effective vaut NULL quand la session n'est pas encore terminee.
INSERT INTO stream (id_streamer, id_creneau, titre, heure_debut, heure_fin, date_fin_effective) VALUES
(1, 1, 'Ouverture officielle du ZEvent', '2025-09-05 18:15:00', '2025-09-06 00:30:00', '2025-09-06 00:45:00'),
(2, 4, 'Debut cozy et discussions', '2025-09-05 19:15:00', '2025-09-06 01:30:00', '2025-09-06 01:30:00'),
(3, 6, 'Culture generale et anecdotes', '2025-09-05 20:15:00', '2025-09-06 02:30:00', NULL),
(4, 8, 'Retro gaming caritatif', '2025-09-05 21:30:00', '2025-09-06 03:30:00', '2025-09-06 03:50:00'),
(5, 10, 'Just Dance avec le chat', '2025-09-05 19:00:00', '2025-09-06 00:00:00', '2025-09-06 00:00:00'),
(6, 12, 'Blind test musical', '2025-09-05 22:15:00', '2025-09-06 04:45:00', NULL),
(7, 14, 'Horreur de minuit', '2025-09-05 17:30:00', '2025-09-05 23:30:00', '2025-09-05 23:40:00'),
(8, 16, 'Debat dons et associations', '2025-09-05 18:20:00', '2025-09-06 01:20:00', '2025-09-06 01:20:00'),
(9, 18, 'Talk show caritatif', '2025-09-05 20:00:00', '2025-09-06 03:00:00', NULL),
(10, 20, 'Piano et jeux independants', '2025-09-05 21:00:00', '2025-09-06 04:00:00', '2025-09-06 04:15:00'),
(1, 2, 'Tournoi communautaire', '2025-09-06 14:15:00', '2025-09-06 21:00:00', '2025-09-06 21:00:00'),
(2, 5, 'Atelier doublage improvise', '2025-09-06 11:30:00', '2025-09-06 18:30:00', NULL),
(3, 7, 'Quiz impossible du samedi', '2025-09-06 09:30:00', '2025-09-06 16:00:00', '2025-09-06 16:05:00'),
(5, 11, 'Cosplay et defis viewers', '2025-09-06 13:30:00', '2025-09-06 20:30:00', '2025-09-06 20:30:00'),
(8, 17, 'Revue des meilleurs dons', '2025-09-06 12:15:00', '2025-09-06 19:45:00', NULL);

SELECT * FROM streamer ORDER BY id_streamer;
SELECT * FROM creneau ORDER BY id_creneau;
SELECT * FROM defi ORDER BY id_defi;
SELECT * FROM participation_defi ORDER BY id_streamer, id_defi;
SELECT * FROM stream ORDER BY id_stream;

