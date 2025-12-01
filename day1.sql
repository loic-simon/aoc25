-- https://adventofcode.com/2025/day/1
DROP SCHEMA IF EXISTS day1 CASCADE;
CREATE SCHEMA day1;

CREATE TABLE day1.raw (
    step SERIAL PRIMARY KEY,
    instr VARCHAR NOT NULL
);

-- Seed
COPY day1.raw (instr)
FROM '/Users/loic/aoc25/day1.txt';

CREATE TABLE day1.instr (
    step SERIAL PRIMARY KEY,
    instr INTEGER NOT NULL
);
INSERT INTO day1.instr (step, instr) VALUES (0, 50);
INSERT INTO day1.instr (instr)
    SELECT replace(replace(instr, 'L', '-'), 'R', '')::integer
    FROM day1.raw
    ORDER BY step;

-- Part 1
CREATE TABLE day1.cum (
    step SERIAL PRIMARY KEY,
    pos INTEGER NOT NULL
);
INSERT INTO day1.cum (pos)
    SELECT SUM(instr) OVER (ORDER BY step) AS pos
    FROM day1.instr
    ORDER BY step;

SELECT count(*) FROM day1.cum WHERE pos % 100 = 0;

-- Part 2
CREATE TABLE day1.mov (
    step SERIAL PRIMARY KEY,
    start numeric,
    stop numeric
);
INSERT INTO day1.mov (start, stop)
    SELECT x.start_stop[1], x.start_stop[2]
    FROM (
        SELECT array_agg(pos) OVER (ORDER BY step ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) start_stop
        FROM day1.cum
        ORDER BY step
    ) x
    WHERE array_length(x.start_stop, 1) = 2;

SELECT sum(abs(
    floor((CASE WHEN start > stop THEN start - 1 ELSE start END) / 100)
  - floor((CASE WHEN start > stop THEN stop - 1 ELSE stop END) / 100)
))
FROM day1.mov;
