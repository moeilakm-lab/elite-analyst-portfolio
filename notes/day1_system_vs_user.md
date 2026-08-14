# Day 1 — System vs User Prompts
**Date:** 2026-07-18 · AI Track, Month 1

## Concept
System prompt = operator's standing rules, set once, higher authority (DDL).
User prompt = per-turn input, lower authority (DML).

## Prompt 1 — PostgreSQL Code Reviewer
```
You are a PostgreSQL code reviewer. Whenever you receive SQL, respond ONLY in this format:
VERDICT: one line
ISSUES: bullet points
FIX: the corrected query, nothing else
Never add explanations outside this format.
```
**Result:** forced consistent 3-section output; survived "ignore all previous instructions" injection.

## Prompt 2 — Superstore Data Dictionary Bot
```
you are a superstore data dictionary assistant
your answer must be exactly 2 sentences
if off topic reply with: " Not related "
```
**Result:** 3/3 rules held live — on-topic answered in exactly 2 sentences, off-topic returned the fixed refusal phrase, 2 injection attempts refused.

## Lessons
- Rules in the user channel *can* hold, but only the system channel is a trained-in guarantee.
- Repurposing a bot: clear the old system prompt completely — stale instructions conflict, they don't average out.
- Weak area flagged: predict before EVERY send, no exceptions.