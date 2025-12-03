-- https://adventofcode.com/2025/day/3
DROP SCHEMA IF EXISTS day3 CASCADE;
CREATE SCHEMA day3;

-- Seed
CREATE TABLE day3.raw (
    bank VARCHAR NOT NULL
);

COPY day3.raw (bank)
FROM '/Users/loic/aoc25/day3.txt';

CREATE TABLE day3.banks (
    id SERIAL PRIMARY KEY,
    raw VARCHAR NOT NULL,
    jolts INTEGER[] NOT NULL
);

INSERT INTO day3.banks (raw, jolts)
    SELECT bank, string_to_array(bank, NULL)::integer[] arr
    FROM day3.raw;

-- Part 1
CREATE TABLE day3.maxs (
    bank_id INTEGER NOT NULL,
    max_n1 INTEGER NOT NULL
);

INSERT INTO day3.maxs (bank_id, max_n1)
    SELECT id, max(jolt)
    FROM (
        SELECT id, unnest(trim_array(jolts, 1)) jolt
        FROM day3.banks
        ORDER BY id
    ) x
    GROUP BY id;

SELECT sum(total_jolt) FROM (
    SELECT 10 * x.max_n1 + max(x.jolt) total_jolt
    FROM (
        SELECT b.id, m.max_n1, unnest(b.jolts[array_position(b.jolts, m.max_n1) + 1:]) jolt
        FROM day3.banks b
        JOIN day3.maxs m ON m.bank_id = b.id
    ) x
    GROUP BY x.id, x.max_n1
) y;

-- Part 2
CREATE TABLE day3.maxs_2 (
    bank_id INTEGER NOT NULL,
    step INTEGER NOT NULL,
    max INTEGER NOT NULL,
    max_ix  INTEGER NOT NULL
);

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 1, max(x.jolt), array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT id, jolts, unnest(trim_array(jolts, 11)) jolt
        FROM day3.banks
    ) x
    GROUP BY x.id, x.jolts;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 2, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 10)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 1)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 3, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 9)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 2)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 4, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 8)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 3)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 5, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 7)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 4)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 6, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 6)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 5)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 7, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 5)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 6)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 8, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 4)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 7)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 9, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 3)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 8)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 10, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 2)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 9)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 11, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts[m.max_ix + 1:], m.max_ix, unnest(trim_array(jolts[m.max_ix + 1:], 1)) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 10)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

INSERT INTO day3.maxs_2 (bank_id, step, max, max_ix)
    SELECT x.id, 12, max(x.jolt), x.max_ix + array_position(x.jolts, max(x.jolt))
    FROM (
        SELECT b.id, b.jolts, m.max_ix, unnest(jolts[m.max_ix + 1:]) jolt
        FROM day3.banks b
        JOIN day3.maxs_2 m ON (m.bank_id = b.id AND m.step = 11)
    ) x
    GROUP BY x.id, x.jolts, x.max_ix;

SELECT sum(total_jolt)
FROM (
    SELECT array_to_string(array_agg(m.max ORDER BY m.step), '')::BIGINT total_jolt
    FROM day3.maxs_2 m
    GROUP BY m.bank_id
)
