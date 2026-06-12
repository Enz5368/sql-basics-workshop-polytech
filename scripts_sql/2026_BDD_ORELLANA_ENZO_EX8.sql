-- ============================================
-- Exercice 8 : Performance et indexation
-- Realise par : ORELLANA Enzo
-- Date : 2026-06-12
-- ============================================

-- Etape 1 : charger des donnees massives.
TRUNCATE TABLE stream, participation_defi, creneau, defi, streamer RESTART IDENTITY CASCADE;

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO streamer (pseudo, url_twitch)
        VALUES ('pseudo_' || i, 'https://twitch.tv/pseudo_' || i);
    END LOOP;
END $$;

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO defi (intitule, montant_palier, etat_validation)
        VALUES (
            'defi_' || i,
            (random() * 50000)::DECIMAL(12,2) + 500,
            (random() < 0.5)
        );
    END LOOP;
END $$;

DO $$
BEGIN
    FOR i IN 1..250000 LOOP
        INSERT INTO participation_defi (id_streamer, id_defi)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 50000 + 1)::INT
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00' + (random() * 48)::INT * INTERVAL '1 hour';
        end_date := start_date + (random() * 4 + 1)::INT * INTERVAL '1 hour';
        INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            start_date,
            end_date
        );
    END LOOP;
END $$;

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
    effective_end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00' + (random() * 48)::INT * INTERVAL '1 hour';
        end_date := start_date + (random() * 4 + 1)::INT * INTERVAL '1 hour';
        effective_end_date := CASE
            WHEN random() < 0.7 THEN end_date
            ELSE end_date + (random() * 3)::INT * INTERVAL '1 hour'
        END;
        INSERT INTO stream (id_streamer, id_creneau, titre, heure_debut, heure_fin, date_fin_effective)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 100000 + 1)::INT,
            'Stream caritatif ' || i,
            start_date,
            end_date,
            effective_end_date
        );
    END LOOP;
END $$;

-- Etape 2 : statistiques a jour avant l'analyse.
ANALYZE streamer;
ANALYZE defi;
ANALYZE participation_defi;
ANALYZE creneau;
ANALYZE stream;

-- Etape 3 : requete complexe sans index ajoutes.
EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) AS nb_depassements
FROM streamer s
JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
JOIN defi d ON pd.id_defi = d.id_defi
LEFT JOIN stream st ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY s.id_streamer, s.pseudo, d.id_defi, d.intitule
ORDER BY s.pseudo, d.intitule;

-- Observations avant index :
-- Planning Time releve : A COMPLETER ms
-- Execution Time releve : A COMPLETER ms
-- Seq Scan observes : A COMPLETER
-- Operations couteuses : A COMPLETER

-- Etape 5 : creation des index.
CREATE INDEX IF NOT EXISTS idx_participation_defi_id_streamer
    ON participation_defi(id_streamer);

CREATE INDEX IF NOT EXISTS idx_participation_defi_id_defi
    ON participation_defi(id_defi);

CREATE INDEX IF NOT EXISTS idx_stream_id_streamer
    ON stream(id_streamer);

CREATE INDEX IF NOT EXISTS idx_stream_date_fin_effective
    ON stream(date_fin_effective);

CREATE INDEX IF NOT EXISTS idx_stream_id_streamer_date_fin_effective
    ON stream(id_streamer, date_fin_effective);

ANALYZE participation_defi;
ANALYZE stream;

-- Etape 6 : meme requete apres index.
EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) AS nb_depassements
FROM streamer s
JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
JOIN defi d ON pd.id_defi = d.id_defi
LEFT JOIN stream st ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY s.id_streamer, s.pseudo, d.id_defi, d.intitule
ORDER BY s.pseudo, d.intitule;

-- Observations apres index :
-- Planning Time releve : A COMPLETER ms
-- Execution Time releve : A COMPLETER ms
-- Scans observes : A COMPLETER
-- Gain de performance : ((temps_avant - temps_apres) / temps_avant) * 100

-- Bonus : index trigram pour optimiser les recherches LIKE.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_streamer_pseudo_trgm
    ON streamer USING gin (pseudo gin_trgm_ops);

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis
FROM streamer s
LEFT JOIN participation_defi pd ON s.id_streamer = pd.id_streamer
WHERE s.pseudo LIKE '%pseudo%1%'
GROUP BY s.id_streamer, s.pseudo;

-- Conclusion :
-- Les index sur participation_defi(id_streamer) et participation_defi(id_defi)
-- sont les plus importants car la table de liaison contient beaucoup de lignes
-- et sert aux jointures M:N.
--
-- Sans index, PostgreSQL doit parcourir beaucoup de lignes avec des Seq Scan.
-- Avec index, il peut acceder plus rapidement aux lignes utiles pour les jointures.
--
-- Le filtre (s.id_streamer + 0) < 5000 peut limiter l'utilisation directe
-- d'un index B-tree classique sur id_streamer. Il faut donc commenter le plan
-- reel observe dans PgAdmin apres execution.

