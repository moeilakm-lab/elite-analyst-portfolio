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

## 3-step analyst chain

**Step 1 — Prompt AI to write the SQL**
Open a new Claude chat. Send this prompt:
You are a senior data analyst. I have a PostgreSQL table called 
superstore with columns: order_id, product_name, category, 
sub_category, sales, profit, region, segment, customer_name.

Business question: Which 3 sub-categories had the highest 
profit margin (profit/sales) in the West region?

Write the SQL query only. No explanation.

**AI Answer:**
```sql
SELECT 
    sub_category,
    SUM(profit) / SUM(sales) AS profit_margin
FROM superstore
WHERE region = 'West'
GROUP BY sub_category
ORDER BY profit_margin DESC
LIMIT 3;
```
**Step 2 — Paste the result, ask for the business insight**
Take your actual DBeaver output numbers and send this prompt:
You are a senior data analyst. Here are the results of a 
profit margin query for the West region: [paste your numbers].

Write a 2-sentence finding a sales director would understand. 
No SQL. No technical language. 

You are a senior data analyst. Here are the results of a 
profit margin query for the West region: 
Envelopes    0.46350566
Paper    0.45452124
Labels    0.45348442.
Write a 2-sentence finding a sales director would understand. 
No SQL. No technical language.
**AI Answer**
In the West region, Envelopes, Paper, and Labels are the standout performers, turning approximately 45–46 cents of every dollar sold into pure profit. Doubling down on these three sub-categories — through targeted promotions or expanded inventory — represents one of the clearest, lowest-risk ways to grow the West region's bottom line.

## Prompt Templates
ROLE: You are a [role].
CONTEXT: [situation/background]
TASK: [what to do]
FORMAT: [how to respond]
CONSTRAINT: [what to avoid]

**Help me debug a SQL query that's giving wrong results**
ROLE: You are a senior SQL analyst.

CONTEXT: I have a query that runs without error but returns wrong results.
Query: [SQL_QUERY]
Expected result: ___________
Actual result: ___________

TASK: Identify why the results are wrong and fix the query.

FORMAT: technical 

CONSTRAINT: no business explaination only give me the correct sql code

**Template 2 — Business Summary**
ROLE : You are senior SQL analyst
CONTEXT: I have created SQL query applied on a retail store dataset and got the below restult : 
[result in table]
TASK : [BUSINESS_QUESTION] 
FORMAT : the answer shoul be in plain english understandable by [AUDIENCE]
CONSTRAINT : avoid any technical terms or any sql code

**Explain a SQL concept to me like I'm learning it for the first time**
ROLE / CONTEXT / TASK / FORMAT / CONSTRAINT

ROLE: you are SQL trainer 
CONTEXT : [CONCEPT]
TASK: explain this concept to me like i am learning it for the first time
FORMAT: explain it in educational format supported with examples
CONSTRAINT: avoid any complexity or assuming that i know terms or concepts before

## Prompt Engineering — Week 3, Day 2: Prompt Chaining

**Design a chain for this scenario: you have a list of SQL queries you wrote this week. You want to turn them into a portfolio README section.**
##### Chain: SQL queries → portfolio README
Write all 3 prompts. Don't run them yet — just design the chain. Show me your 3 prompts.

Prompt 1: "You are a SQL trainer. Here are my queries: [SQL]. Review and debug them. Return only the corrected queries with a one-line note on what you fixed."


Prompt 2: "Here are my corrected queries: [Prompt 1 output]. Explain what each query does and when an analyst would use it. One paragraph per query."


Prompt 3: "Here are my query explanations: [Prompt 2 output]. Turn these into a portfolio README section. Use markdown. Keep it professional and concise."

## Python/pandas help

You are a senior data analyst.
I have a pandas dataframe with these column types:
[PASTE df.dtypes OUTPUT HERE]

Task: [DESCRIBE EXACTLY WHAT YOU WANT]
Return only the code, no explanation.

## Data Storytelling Template

You are a senior data analyst presenting findings to a business audience.

Given this data: [PASTE DATA OR QUERY RESULT]

Tell the story in this structure:
1. One-sentence headline — the single most important finding
2. Supporting evidence — 2-3 numbers that back it up
3. The so-what — why does this matter to the business?
4. One question this raises that needs further investigation

Tone: clear, confident, no jargon. Write for a non-technical manager.
Note: Always verify any percentages or 
derived numbers before presenting. 
Raw query output only — no estimates.

## SQL Debugging Template
**Role**: senior data analyst specialised in SQL queries 
**Business question** : [Business Question] 
**My query** : [SQL] 
**The problem** : [type the error message] 
**Expected output**: [describe what the query should have returned]
**What I need**: Don't fix it for me. Explain what's wrong and give me one hint so I can fix it myself.