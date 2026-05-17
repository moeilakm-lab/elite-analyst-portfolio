## Template 1 — Zero-shot to specific
Role: You are a senior data analyst.
Context: [table name, columns, key findings]
Question: [specific business question]
Format: [numbered list / 2 sentences / etc.]

## Template 2 — Role prompt
Role: You are a senior data analyst at an Irish tech company 
reviewing a junior analyst's work.
Task: [what to review or explain]
Format: [tone + length]

## Template 3 — Context + format prompt
Role: You are a senior data analyst.
Context: I have a table called [TABLE] with columns 
[COLUMNS]. Key finding: [YOUR FINDING].
Question: [SPECIFIC BUSINESS QUESTION]
Format: numbered list, one sentence each, business language.

## Day 4 — Negative Prompting

**WITH negative instructions:**
"Write a SQL query to find total profit by category. 
Do not explain the code. Do not use subqueries. Just give the query."

Result: Clean query only — no explanation.

---

**WITHOUT negative instructions:**
"Write a SQL query to find total profit by category."

Result: Query + full line-by-line explanation.

---

**Key lesson:** Negative instructions remove noise. 
Use when you want output only.

**Template:** "[task]. Do not [X]. Do not [Y]. Just [what you want]."
