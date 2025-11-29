-- Day 1 of AOC 2024, just for setting everything up before Dec 1st

DROP SCHEMA IF EXISTS day0 CASCADE;
CREATE SCHEMA day0;

CREATE TABLE day0.loc (
    col1 INTEGER NOT NULL,
    col2 INTEGER NOT NULL
);

-- Pre-transform step: sed -i '' 's/   /\t/g' day0.txt
COPY day0.loc
FROM '/Users/loic/aoc25/day0.txt'

-- Part 1
SELECT sum(abs(l1.col1 - l2.col2)) FROM (
    SELECT row_number() OVER(ORDER BY col1) rn, col1 FROM day0.loc
) l1
JOIN (
    SELECT row_number() OVER(ORDER BY col2) rn, col2 FROM day0.loc
) l2
ON l1.rn = l2.rn

-- Part 2
SELECT sum(sim) FROM (
    SELECT l1.col1 * COUNT(*) sim FROM day0.loc l1
    JOIN day0.loc l2 ON l1.col1 = l2.col2
    GROUP BY l1.col1
) x
