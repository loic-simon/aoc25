-- https://adventofcode.com/2025/day/6
DROP SCHEMA IF EXISTS day6 CASCADE;
CREATE SCHEMA day6;

-- Seed
CREATE TABLE day6.raw (
    id SERIAL NOT NULL,
    row VARCHAR NOT NULL
);

COPY day6.raw (row)
FROM '/Users/loic/aoc25/day6.txt';

CREATE TABLE day6.operators (
    pb INTEGER PRIMARY KEY,
    op VARCHAR NOT NULL
);

INSERT INTO day6.operators (pb, op)
    SELECT s.id, s.op
    FROM day6.raw
    JOIN regexp_split_to_table(trim(row), '\s+') WITH ORDINALITY s(op, id) ON true
    WHERE s.op IN ('+', '*');

-- Part 1
CREATE TABLE day6.numbers (
    pb INTEGER NOT NULL,
    num INTEGER NOT NULL
);

INSERT INTO day6.numbers (pb, num)
    SELECT s.id, s.num::integer
    FROM day6.raw
    JOIN regexp_split_to_table(trim(row), '\s+') WITH ORDINALITY s(num, id) ON true
    WHERE s.num NOT IN ('+', '*');

SELECT sum(x.result)
FROM (
    SELECT CASE o.op WHEN '+' THEN sum(n.num) ELSE round(exp(sum(ln(n.num)))) END result
    FROM day6.operators o
    JOIN day6.numbers n ON n.pb = o.pb
    GROUP BY o.pb
) x;

-- Part 2
CREATE TABLE day6.rows (
    id SERIAL NOT NULL,
    num INTEGER NOT NULL
);

INSERT INTO day6.rows (id, num)
    SELECT s.id, string_agg(s.char, '' ORDER BY r.id)::integer
    FROM day6.raw r
    JOIN string_to_table(row, NULL) WITH ORDINALITY s(char, id) ON true
    WHERE s.char NOT IN ('+', '*', ' ')
    GROUP BY s.id;

CREATE TABLE day6.numbers_ceph (
    pb INTEGER NOT NULL,
    num INTEGER NOT NULL
);

CREATE SEQUENCE day6.group_seq;
INSERT INTO day6.numbers_ceph (pb, num)
    SELECT
        CASE WHEN r2.id IS NULL THEN nextval('day6.group_seq') ELSE currval('day6.group_seq') END,
        r.num
    FROM day6.rows r
    LEFT OUTER JOIN day6.rows r2 ON r2.id = r.id - 1;

SELECT sum(x.result)
FROM (
    SELECT CASE o.op WHEN '+' THEN sum(n.num) ELSE round(exp(sum(ln(n.num)))) END result
    FROM day6.operators o
    JOIN day6.numbers_ceph n ON n.pb = o.pb
    GROUP BY o.pb
) x;
