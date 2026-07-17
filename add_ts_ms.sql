-- Run this in the Supabase SQL Editor (New query) — one-time addition
-- to the schema you already ran. It adds a precise integer timestamp
-- used inside the tamper-evident hash, avoiding formatting mismatches
-- that a text/date timestamp can introduce when read back from the DB.

ALTER TABLE ballots ADD COLUMN IF NOT EXISTS ts_ms BIGINT NOT NULL DEFAULT 0;
