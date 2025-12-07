-- https://adventofcode.com/2025/day/7
DROP SCHEMA IF EXISTS day7 CASCADE;
CREATE SCHEMA day7;

-- Seed
CREATE TABLE day7.raw (
    id SERIAL NOT NULL,
    row VARCHAR NOT NULL
);

COPY day7.raw (row)
FROM '/Users/loic/aoc25/day7.txt';

CREATE TABLE day7.matrix (
    y INTEGER NOT NULL,
    x INTEGER NOT NULL,
    char VARCHAR NOT NULL
);

INSERT INTO day7.matrix (y, x, char)
    SELECT r.id, s.x, s.char
    FROM day7.raw r
    JOIN string_to_table(r.row, NULL) WITH ORDINALITY s(char, x) ON true;

-- Part 1
SELECT count(*) FROM (
    WITH RECURSIVE cte (y, x, from_split)
    AS (
        SELECT m.y, m.x, false FROM day7.matrix m WHERE m.y = 1 AND m.char = 'S'
        UNION
        SELECT cte.y + 1,
               CASE m.char WHEN '.' THEN m.x ELSE mv.x END,
               CASE m.char WHEN '.' THEN false ELSE mv.x < m.x END
            FROM cte
            JOIN day7.matrix m ON m.y = cte.y + 1 AND m.x = cte.x
            LEFT OUTER JOIN day7.matrix mv ON mv.y = cte.y + 1 AND (mv.x = cte.x - 1 OR mv.x = cte.x + 1)
            WHERE m.char = '.' OR (m.char = '^' AND mv.char = '.')
    )
    SELECT * FROM cte
) s
WHERE s.from_split;

-- Part 2
SELECT sum(sq.mul) FROM (
    WITH RECURSIVE cte (y, x, mul)
    AS (
        SELECT m.y, m.x, 1::bigint FROM day7.matrix m WHERE m.y = 1 AND m.char = 'S'
        UNION ALL
        SELECT s.y, s.x, sum(s.mul)::bigint
        FROM (
            SELECT DISTINCT
                cte.y + 1 y,
                CASE m.char WHEN '.' THEN m.x ELSE mv.x END x,
                cte.mul,
                cte.x orig_x
            FROM cte
            JOIN day7.matrix m ON m.y = cte.y + 1 AND m.x = cte.x
            LEFT OUTER JOIN day7.matrix mv ON mv.y = cte.y + 1 AND (mv.x = cte.x - 1 OR mv.x = cte.x + 1)
            WHERE m.char = '.' OR (m.char = '^' AND mv.char = '.')
        ) s
        GROUP BY s.y, s.x
    )
    SELECT * FROM cte
) sq
WHERE sq.y = (SELECT max(y) FROM day7.matrix)
