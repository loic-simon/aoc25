-- https://adventofcode.com/2025/day/9
DROP SCHEMA IF EXISTS day9 CASCADE;
CREATE SCHEMA day9;

-- Seed
CREATE TABLE day9.tiles (
    id SERIAL PRIMARY KEY,
    x BIGINT NOT NULL,
    y BIGINT NOT NULL
);

COPY day9.tiles (x, y)
FROM '/Users/loic/aoc25/day9.sample.txt'
DELIMITER ',';

-- Part 1
SELECT max((abs(t1.x - t2.x) + 1) * (abs(t1.y - t2.y) + 1))
FROM day9.tiles t1
JOIN day9.tiles t2 ON t2.id > t1.id;

-- Part 2
WITH pol AS (
    SELECT ('(' || string_agg(point(t.x, t.y)::text, ',' ORDER BY t.id ASC) || ')')::polygon pol
    FROM day9.tiles t
)
SELECT max((abs(t1.x - t2.x) + 1) * (abs(t1.y - t2.y) + 1))
FROM day9.tiles t1
JOIN day9.tiles t2 ON t2.id > t1.id
JOIN pol ON true
WHERE pol.pol @> polygon(box(point(t1.x, t1.y), point(t2.x, t2.y)));
