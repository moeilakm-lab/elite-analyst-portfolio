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

