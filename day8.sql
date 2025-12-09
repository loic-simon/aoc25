-- https://adventofcode.com/2025/day/8
DROP SCHEMA IF EXISTS day8 CASCADE;
CREATE SCHEMA day8;

-- Seed
CREATE TABLE day8.boxes (
    id SERIAL PRIMARY KEY,
    x INTEGER NOT NULL,
    y INTEGER NOT NULL,
    z INTEGER NOT NULL
);

COPY day8.boxes (x, y, z)
FROM '/Users/loic/aoc25/day8.txt'
DELIMITER ',';

-- Part 1
CREATE TABLE day8.pairs (
    id SERIAL PRIMARY KEY,
    box1 INTEGER NOT NULL,
    box2 INTEGER NOT NULL,
    dist NUMERIC NOT NULL
);

INSERT INTO day8.pairs (box1, box2, dist)
    SELECT s.box1, s.box2, s.dist FROM (
        SELECT
            b1.id box1,
            b2.id box2,
            sqrt((b1.x - b2.x)^2 + (b1.y - b2.y)^2 + (b1.z - b2.z)^2) dist
        FROM day8.boxes b1
        JOIN day8.boxes b2 ON b1.id < b2.id
    ) s
    ORDER BY s.dist ASC;


CREATE TABLE day8.primary_circuits (
    id SERIAL PRIMARY KEY,
    circuit INTEGER[] NOT NULL
);

CREATE TYPE day8._c AS (circuit INTEGER[]);

SELECT round(exp(sum(ln(sq.x)))) FROM (
    WITH RECURSIVE cte(i, circuit)
    AS (
        SELECT 0, array[]::integer[] circuit
        UNION
        SELECT any_value(z.id) + 1, array_agg(DISTINCT zzz.box) circuit
        FROM (
            SELECT
                any_value(y.id) id,
                coalesce(array_agg(y.c1), array[]::day8._c[]) || coalesce(array_agg(y.c2), array[]::day8._c[]) circuits
            FROM (
                SELECT x.id, ROW(x.circuit)::day8._c c1, ROW(nullif(array_remove(ARRAY[p.box1, p.box2], NULL), ARRAY[]::integer[]))::day8._c c2
                FROM (
                    SELECT max(x0.id) OVER() id, x0.circuit
                    FROM (
                        SELECT cte.i id, cte.circuit FROM cte
                        UNION
                        SELECT 0, NULL
                    ) x0
                ) x
                LEFT OUTER JOIN day8.pairs p
                    ON p.id = x.id + 1
                    AND (x.circuit IS NULL OR ARRAY[p.box1, p.box2] && x.circuit)
            ) y
            GROUP BY coalesce((y.c2).circuit, (y.c1).circuit)
        ) z
        JOIN unnest(z.circuits) zz(circuit) ON true
        JOIN unnest(zz.circuit) zzz(box) ON true
        WHERE z.id <= 1000
        GROUP BY z.circuits
    )
    SELECT array_length(circuit, 1) x
    FROM cte
    WHERE i = 1000
    ORDER BY array_length(circuit, 1) DESC
    LIMIT 3
) sq;

-- Part 2
SELECT b1.x * b2.x
FROM (
    WITH RECURSIVE cte(i, circuit)
    AS (
        SELECT 0, array[]::integer[] circuit
        UNION
        SELECT any_value(z.id) + 1, array_agg(DISTINCT zzz.box) circuit
        FROM (
            SELECT
                any_value(y.id) id,
                coalesce(array_agg(y.c1), array[]::day8._c[]) || coalesce(array_agg(y.c2), array[]::day8._c[]) circuits
            FROM (
                SELECT x.id, ROW(x.circuit)::day8._c c1, ROW(nullif(array_remove(ARRAY[p.box1, p.box2], NULL), ARRAY[]::integer[]))::day8._c c2
                FROM (
                    SELECT max(x0.id) OVER() id, x0.circuit
                    FROM (
                        SELECT cte.i id, cte.circuit FROM cte
                        UNION
                        SELECT 0, NULL
                    ) x0
                ) x
                LEFT OUTER JOIN day8.pairs p
                    ON p.id = x.id + 1
                    AND (x.circuit IS NULL OR ARRAY[p.box1, p.box2] && x.circuit)
            ) y
            GROUP BY coalesce((y.c2).circuit, (y.c1).circuit)
        ) z
        JOIN unnest(z.circuits) zz(circuit) ON true
        JOIN unnest(zz.circuit) zzz(box) ON true
        GROUP BY z.circuits
    )
    SELECT i
    FROM cte
    WHERE array_length(circuit, 1) = 1000
    LIMIT 1
) sq
JOIN day8.pairs p ON p.id = sq.i
JOIN day8.boxes b1 ON b1.id = p.box1
JOIN day8.boxes b2 ON b2.id = p.box2;
