-- ============================================================
-- e-Vote Zambia — Database Schema
-- JETS 2026 Innovation Project
-- Written for PostgreSQL (works as-is on Supabase, free & online)
-- ============================================================

-- Every election run is tagged with the school and student who built it.
-- This is what identifies your submission if judges look at the database directly.
CREATE TABLE elections (
    id            SERIAL PRIMARY KEY,
    school_name   TEXT NOT NULL,
    student_name  TEXT NOT NULL,
    title         TEXT NOT NULL DEFAULT 'e-Vote Zambia',
    status        TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Polling stations belong to one election.
CREATE TABLE stations (
    id            TEXT PRIMARY KEY,
    election_id   INTEGER NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
    name          TEXT NOT NULL
);

-- Candidates standing in one election.
CREATE TABLE candidates (
    id            TEXT PRIMARY KEY,
    election_id   INTEGER NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
    name          TEXT NOT NULL,
    party         TEXT NOT NULL,
    color         TEXT NOT NULL DEFAULT '#1F4D3A',
    position      TEXT NOT NULL DEFAULT 'President',
    manifesto     TEXT
);

-- Registered voters. `voted` flips once, enforced by the app logic
-- and doubly enforced here so no client can cheat past it.
CREATE TABLE voters (
    id            TEXT PRIMARY KEY,          -- NRC-style ID shown to the voter
    election_id   INTEGER NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
    name          TEXT NOT NULL,
    station_id    TEXT NOT NULL REFERENCES stations(id),
    voted         BOOLEAN NOT NULL DEFAULT FALSE,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- The tamper-evident ledger. Each row is a "block": it hashes together
-- its own contents and the previous block's hash, so editing any row
-- breaks every hash that comes after it. voter_id is hashed before
-- storage (never stored in plain text) so a vote can never be traced
-- back to a specific voter, even by someone with database access.
CREATE TABLE ballots (
    block_index   INTEGER NOT NULL,
    election_id   INTEGER NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
    voter_hash    TEXT NOT NULL,
    candidate_id  TEXT NOT NULL REFERENCES candidates(id),
    prev_hash     TEXT NOT NULL,
    block_hash    TEXT NOT NULL,
    cast_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (election_id, block_index)
);

-- Helpful indexes for the dashboards / results screens.
CREATE INDEX idx_voters_election   ON voters(election_id);
CREATE INDEX idx_voters_station    ON voters(station_id);
CREATE INDEX idx_ballots_election  ON ballots(election_id);
CREATE INDEX idx_ballots_candidate ON ballots(candidate_id);

-- ============================================================
-- Access for the demo: Supabase's public "anon" key is meant to be
-- used in client-side code (it's not a secret) but every table needs
-- Row Level Security policies, or the anon key can't touch it at all.
-- These policies allow the demo website to read/write everything —
-- fine for a JETS demo, NOT how you'd configure a production system.
-- ============================================================
ALTER TABLE elections  ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE voters     ENABLE ROW LEVEL SECURITY;
ALTER TABLE ballots    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read elections"  ON elections  FOR SELECT USING (true);
CREATE POLICY "public read stations"   ON stations   FOR SELECT USING (true);
CREATE POLICY "public read candidates" ON candidates FOR SELECT USING (true);
CREATE POLICY "public read voters"     ON voters     FOR SELECT USING (true);
CREATE POLICY "public write voters"    ON voters     FOR INSERT WITH CHECK (true);
CREATE POLICY "public update voters"   ON voters     FOR UPDATE USING (true);
CREATE POLICY "public read ballots"    ON ballots    FOR SELECT USING (true);
CREATE POLICY "public write ballots"   ON ballots    FOR INSERT WITH CHECK (true);

-- ============================================================
-- Seed data: one election tagged with your school + name,
-- default candidates and stations to match the website.
-- Edit the two values below before running this file.
-- ============================================================
INSERT INTO elections (school_name, student_name, title)
VALUES ('Your School Name Here', 'Your Name Here', 'e-Vote Zambia')
RETURNING id;

-- After running the insert above, note the returned id (likely 1)
-- and use it in place of `1` below if it differs.

INSERT INTO stations (id, election_id, name) VALUES
    ('s1', 1, 'Lusaka Central Hall'),
    ('s2', 1, 'Kitwe Community Centre'),
    ('s3', 1, 'Livingstone Civic Centre'),
    ('s4', 1, 'Ndola Trade Fair Grounds');

INSERT INTO candidates (id, election_id, name, party, color, position, manifesto) VALUES
    ('c1', 1, 'Chileshe Mumba', 'Green Alliance', '#1F4D3A', 'President',
        'Focused on rural electrification and expanding community health posts.'),
    ('c2', 1, 'Bwalya Tembo', 'Copper Front', '#B8622A', 'President',
        'A mining-sector economist promising to renegotiate export terms.'),
    ('c3', 1, 'Natasha Chola', 'Unity Movement', '#C99A3B', 'President',
        'Former teacher running on free secondary education and digital skills.'),
    ('c4', 1, 'Emmanuel Zulu', 'Harvest Party', '#4C5B76', 'President',
        'Agricultural cooperative organiser pushing irrigation subsidies.');

-- ============================================================
-- Handy queries you can show judges directly in the SQL editor
-- ============================================================

-- Turnout by station (never reveals who a voter chose):
-- SELECT s.name, COUNT(*) FILTER (WHERE v.voted) AS voted, COUNT(*) AS registered
-- FROM voters v JOIN stations s ON s.id = v.station_id
-- WHERE v.election_id = 1 GROUP BY s.name;

-- Live results:
-- SELECT c.name, c.party, COUNT(b.*) AS votes
-- FROM candidates c LEFT JOIN ballots b ON b.candidate_id = c.id AND b.election_id = c.election_id
-- WHERE c.election_id = 1 GROUP BY c.name, c.party ORDER BY votes DESC;

-- Verify chain integrity (checks every block links to the one before it):
-- SELECT block_index, prev_hash, block_hash,
--        LAG(block_hash) OVER (PARTITION BY election_id ORDER BY block_index) AS expected_prev
-- FROM ballots WHERE election_id = 1 ORDER BY block_index;
