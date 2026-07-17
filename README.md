# e-Vote Zambia

A tamper-evident digital voting system built for the JETS 2026 National Science Fair.

**School:** Itezhi Tezhi Boarding Secondary School

## The problem

Zambian elections rely on paper ballots moved across long distances between polling stations and collation centres — a process vulnerable to delay, error, and dispute. e-Vote Zambia proposes a digital chain of custody: every ballot is cryptographically linked to the one before it, so any alteration after the fact is mathematically detectable.

## How it works

1. **Register** — each voter is issued a unique NRC-style ID and assigned to a polling station.
2. **Vote** — casting a ballot checks the ID hasn't voted before, then hashes the vote together with the previous block's hash using SHA-256, forming a tamper-evident chain.
3. **Verify** — anyone can recompute every hash in the chain to confirm nothing has been altered.
4. **Results** — live results and turnout update in real time, with turnout tracked per polling station without ever revealing who a voter chose — preserving the secret ballot even at small stations.

## Files

| File | Purpose |
|---|---|
| `evote-zambia-live.html` | Full working website, connected to a live Supabase database |
| `evote-zambia.html` | Standalone version with in-browser (non-persistent) storage |
| `evote-schema.sql` | Database schema — run this first in a fresh Supabase project |
| `add_ts_ms.sql` | Small follow-up migration required for the hash chain |
| `fix_policies.sql` | Row-level security policies (re-run if data access issues occur) |

## Tech

- React (via CDN, no build step required)
- Supabase (PostgreSQL) for live, online data storage
- Native Web Crypto API (SHA-256) for the tamper-evident ledger — no external crypto library

## Roadmap (not yet built, future scope)

Two-factor authentication, QR-code voter check-in, offline sync, multi-language support, and an AI assistant for voter questions — scoped out for this version to prioritize a fully working core system over a longer feature list.

## Note

Candidate names and parties in this demo are fictional.
