-- https://adventofcode.com/2025/day/2
DROP SCHEMA IF EXISTS day2 CASCADE;
CREATE SCHEMA day2;

-- Seed
CREATE TABLE day2.raw (
    csr VARCHAR NOT NULL
);

COPY day2.raw (csr)
FROM '/Users/loic/aoc25/day2.txt';

CREATE TABLE day2.ranges (
    start BIGINT NOT NULL,
    stop BIGINT NOT NULL
);

INSERT INTO day2.ranges (start, stop)
    SELECT split_part(rng, '-', 1)::BIGINT, split_part(rng, '-', 2)::BIGINT
    FROM (
        SELECT string_to_table(csr, ',') rng FROM day2.raw
    );

-- Part 1
CREATE TABLE day2.ids (
    id BIGINT NOT NULL,
    id_str VARCHAR NOT NULL,
    n INTEGER NOT NULL
);

INSERT INTO day2.ids (id, id_str, n)
    SELECT id, id::text, length(id::text)
    FROM (
        SELECT generate_series(start, stop) as id
        FROM day2.ranges
    );

SELECT sum(id)
FROM day2.ids
WHERE n % 2 = 0 AND left(id_str, n / 2) = right(id_str, n / 2);

-- Part 2
CREATE TABLE day2.combs (
    id BIGINT NOT NULL,
    substrs VARCHAR[] NOT NULL
);

INSERT INTO day2.combs (id, substrs)
    SELECT id, array_agg(DISTINCT substr(id_str, (y * x) + 1, x))
    FROM day2.ids
    JOIN generate_series(1, n - 1) x ON (n % x = 0)
    JOIN generate_series(0, (n / x) - 1) y ON true
    WHERE n > 1
    GROUP BY id, n, x;

SELECT sum(DISTINCT id)
FROM day2.combs
WHERE array_length(substrs, 1) = 1;
