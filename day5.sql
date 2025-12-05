-- https://adventofcode.com/2025/day/5
DROP SCHEMA IF EXISTS day5 CASCADE;
CREATE SCHEMA day5;

-- Seed
CREATE TABLE day5.raw (
    row VARCHAR NOT NULL
);

COPY day5.raw (row)
FROM '/Users/loic/aoc25/day5.txt';

CREATE TABLE day5.ranges (
    range int8range NOT NULL
);
CREATE TABLE day5.ingredients (
    id int8 NOT NULL
);

INSERT INTO day5.ranges (range)
    SELECT int8range(
        split_part(row, '-', 1)::int8,
        split_part(row, '-', 2)::int8,
        '[]'
    )
    FROM day5.raw
    WHERE row LIKE '%-%';

INSERT INTO day5.ingredients (id)
    SELECT row::int8
    FROM day5.raw
    WHERE row NOT LIKE '%-%' AND row != '';

-- Part 1
SELECT COUNT(DISTINCT i.id)
FROM day5.ingredients i
JOIN day5.ranges r ON r.range @> i.id;

-- Part 2
SELECT SUM(upper(mr.r) - lower(mr.r))
FROM (
    SELECT range_agg(r.range) mr
    FROM day5.ranges r
) x
JOIN unnest(x.mr) AS mr(r) ON true
