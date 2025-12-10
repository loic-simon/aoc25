-- https://adventofcode.com/2025/day/10
DROP SCHEMA IF EXISTS day10 CASCADE;
CREATE SCHEMA day10;

-- Seed
CREATE TABLE day10.raw (
    id SERIAL NOT NULL,
    machine VARCHAR NOT NULL
);

COPY day10.raw (machine)
FROM '/Users/loic/aoc25/day10.txt';

CREATE TABLE day10.lights (
    machine_id INTEGER PRIMARY KEY,
    mask BIT VARYING NOT NULL
);
CREATE TABLE day10.button (
    machine_id INTEGER NOT NULL,
    button_id INTEGER NOT NULL,
    i INTEGER NOT NULL
);
CREATE TABLE day10.joltage (
    machine_id INTEGER NOT NULL,
    jolts INTEGER[] NOT NULL
);

INSERT INTO day10.lights (machine_id, mask)
    SELECT r.id, translate(trim(regexp_substr(r.machine, '\[(.+)\]'), '[]'), '.#', '01')::bit varying
    FROM day10.raw r;

INSERT INTO day10.button (machine_id, button_id, i)
    SELECT r.id, b.id, bb.i::integer
    FROM day10.raw r
    JOIN regexp_matches(r.machine, '\((.+?)\)', 'g') WITH ORDINALITY b(lights, id) ON true
    JOIN string_to_table(b.lights[1], ',') bb(i) ON true;

INSERT INTO day10.joltage (machine_id, jolts)
    SELECT r.id, regexp_substr(r.machine, '{.+?}')::integer[]
    FROM day10.raw r;

-- Part 1
CREATE TABLE day10.button_mask (
    machine_id INTEGER NOT NULL,
    mask BIT VARYING
);

INSERT INTO day10.button_mask (machine_id, mask)
    SELECT
        l.machine_id,
        string_agg(CASE WHEN b.i IS NULL THEN '0' ELSE '1' END, '' ORDER BY ll.light_id)::bit varying
    FROM day10.lights l
    JOIN string_to_table(l.mask::text, NULL) WITH ORDINALITY ll(_, light_id) ON true
    JOIN (
        SELECT DISTINCT machine_id, button_id FROM day10.button
    ) b0 ON b0.machine_id = l.machine_id
    LEFT OUTER JOIN day10.button b ON b.machine_id = l.machine_id AND b.button_id = b0.button_id AND b.i = ll.light_id - 1
    GROUP BY l.machine_id, b0.button_id;

SELECT sum(min_ops) FROM (
    WITH RECURSIVE cte (machine_id, n_ops, state) AS (
        SELECT machine_id, 0, mask::text FROM day10.lights
        UNION
        SELECT x.machine_id, x.n_ops, x.state
        FROM (
            SELECT
                cte.machine_id,
                cte.n_ops + 1 n_ops,
                (cte.state::bit varying # b.mask)::text state,
                any_value(cte.state)
                    FILTER(WHERE bit_count(cte.state::bit varying) = 0)
                    OVER(PARTITION BY cte.machine_id)
                    IS NOT NULL finished
            FROM cte
            JOIN day10.button_mask b ON b.machine_id = cte.machine_id
        ) x
        WHERE NOT x.finished
    )
    SELECT max(n_ops) min_ops FROM cte
    GROUP BY machine_id
) s;
