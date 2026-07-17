-- Run this in the Supabase SQL Editor. Safe to run even if some of
-- this already exists — it drops and recreates each policy cleanly.

ALTER TABLE elections  ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE voters     ENABLE ROW LEVEL SECURITY;
ALTER TABLE ballots    ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public read elections"  ON elections;
DROP POLICY IF EXISTS "public read stations"   ON stations;
DROP POLICY IF EXISTS "public read candidates" ON candidates;
DROP POLICY IF EXISTS "public read voters"     ON voters;
DROP POLICY IF EXISTS "public write voters"    ON voters;
DROP POLICY IF EXISTS "public update voters"   ON voters;
DROP POLICY IF EXISTS "public read ballots"    ON ballots;
DROP POLICY IF EXISTS "public write ballots"   ON ballots;

CREATE POLICY "public read elections"  ON elections  FOR SELECT USING (true);
CREATE POLICY "public read stations"   ON stations   FOR SELECT USING (true);
CREATE POLICY "public read candidates" ON candidates FOR SELECT USING (true);
CREATE POLICY "public read voters"     ON voters     FOR SELECT USING (true);
CREATE POLICY "public write voters"    ON voters     FOR INSERT WITH CHECK (true);
CREATE POLICY "public update voters"   ON voters     FOR UPDATE USING (true);
CREATE POLICY "public read ballots"    ON ballots    FOR SELECT USING (true);
CREATE POLICY "public write ballots"   ON ballots    FOR INSERT WITH CHECK (true);

-- Quick check: this should return your one election row.
SELECT * FROM elections;
