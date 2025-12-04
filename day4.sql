-- https://adventofcode.com/2025/day/4
DROP SCHEMA IF EXISTS day4 CASCADE;
CREATE SCHEMA day4;

-- Seed
CREATE TABLE day4.raw (
    x SERIAL PRIMARY KEY,
    row VARCHAR NOT NULL
);

COPY day4.raw (row)
FROM '/Users/loic/aoc25/day4.txt';

CREATE TABLE day4.scrolls (
    x INTEGER NOT NULL,
    y INTEGER NOT NULL,
    f INTEGER NOT NULL
);

INSERT INTO day4.scrolls (x, y, f)
    SELECT x, y, 1
    FROM day4.raw
    JOIN LATERAL string_to_table(row, NULL) WITH ORDINALITY AS _(scroll, y) ON true
    WHERE scroll = '@';

-- Part 1
CREATE TABLE day4.scrolls_nbgs (
    x INTEGER NOT NULL,
    y INTEGER NOT NULL,
    neighbourgs INTEGER NOT NULL
);

INSERT INTO day4.scrolls_nbgs (x, y, neighbourgs)
    SELECT s.x, s.y, coalesce(tl.f, 0) + coalesce(tc.f, 0) + coalesce(tr.f, 0) + coalesce(cl.f, 0) + coalesce(cr.f, 0) + coalesce(bl.f, 0) + coalesce(bc.f, 0) + coalesce(br.f, 0)
    FROM day4.scrolls s
    LEFT OUTER JOIN day4.scrolls tl ON (tl.x, tl.y) = (s.x - 1, s.y - 1)
    LEFT OUTER JOIN day4.scrolls tc ON (tc.x, tc.y) = (s.x    , s.y - 1)
    LEFT OUTER JOIN day4.scrolls tr ON (tr.x, tr.y) = (s.x + 1, s.y - 1)
    LEFT OUTER JOIN day4.scrolls cl ON (cl.x, cl.y) = (s.x - 1, s.y    )
    LEFT OUTER JOIN day4.scrolls cr ON (cr.x, cr.y) = (s.x + 1, s.y    )
    LEFT OUTER JOIN day4.scrolls bl ON (bl.x, bl.y) = (s.x - 1, s.y + 1)
    LEFT OUTER JOIN day4.scrolls bc ON (bc.x, bc.y) = (s.x    , s.y + 1)
    LEFT OUTER JOIN day4.scrolls br ON (br.x, br.y) = (s.x + 1, s.y + 1);

SELECT COUNT(*) FROM day4.scrolls_nbgs WHERE neighbourgs < 4;

-- Part 2
CREATE TYPE day4.scroll AS (
    x INTEGER,
    y INTEGER,
    f INTEGER
);

WITH RECURSIVE cte (scrolls, n)
AS (
    SELECT array_agg((s.x, s.y, s.f)::day4.scroll), COUNT(*) FROM day4.scrolls s
    UNION ALL
    SELECT sq2.scrolls, sq2.new_n
    FROM (
        SELECT array_agg(sq.scr) scrolls, any_value(sq.n) old_n, COUNT(*) new_n
        FROM (
            SELECT
                (s.x, s.y, s.f)::day4.scroll scr,
                coalesce(tl.f, 0) + coalesce(tc.f, 0) + coalesce(tr.f, 0) + coalesce(cl.f, 0) + coalesce(cr.f, 0) + coalesce(bl.f, 0) + coalesce(bc.f, 0) + coalesce(br.f, 0) neighbourgs,
                cte.n
            FROM cte
            JOIN unnest(cte.scrolls) s ON true
            LEFT OUTER JOIN unnest(cte.scrolls) tl ON (tl.x, tl.y) = (s.x - 1, s.y - 1)
            LEFT OUTER JOIN unnest(cte.scrolls) tc ON (tc.x, tc.y) = (s.x    , s.y - 1)
            LEFT OUTER JOIN unnest(cte.scrolls) tr ON (tr.x, tr.y) = (s.x + 1, s.y - 1)
            LEFT OUTER JOIN unnest(cte.scrolls) cl ON (cl.x, cl.y) = (s.x - 1, s.y    )
            LEFT OUTER JOIN unnest(cte.scrolls) cr ON (cr.x, cr.y) = (s.x + 1, s.y    )
            LEFT OUTER JOIN unnest(cte.scrolls) bl ON (bl.x, bl.y) = (s.x - 1, s.y + 1)
            LEFT OUTER JOIN unnest(cte.scrolls) bc ON (bc.x, bc.y) = (s.x    , s.y + 1)
            LEFT OUTER JOIN unnest(cte.scrolls) br ON (br.x, br.y) = (s.x + 1, s.y + 1)
        ) sq
        WHERE sq.neighbourgs >= 4
    ) sq2
    WHERE sq2.new_n < sq2.old_n
)
SELECT max(n) - min(n)
FROM cte;
