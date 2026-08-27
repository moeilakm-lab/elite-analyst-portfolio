# Invoice / Document Extractor

Turn a PDF invoice into clean, structured CSV rows — no manual data entry, no copy-pasting line items into a spreadsheet.

## The problem

Small businesses and agencies get invoices as PDFs. Getting that data into a spreadsheet or accounting system usually means someone typing it in by hand — line by line, invoice by invoice. It's slow and error-prone, and it's exactly the kind of repetitive task that shouldn't need a human.

## What it does

Point the script at a PDF invoice and it:

1. Extracts the raw text from the PDF
2. Sends that text to Claude with a defined schema, asking for structured fields back
3. Flattens the result — one row per line item, with the invoice-level details repeated on each row
4. Writes everything out to a CSV, ready to open in Excel or import anywhere else

It's been tested on invoices in different currencies and with different numbers of line items, with no changes to the code required between runs.

### Fields extracted

**Invoice-level (repeated on every row):**
- Invoice number
- Invoice date
- Vendor name
- Customer name
- Currency
- Total amount

**Line-item level (one row per item):**
- Description
- Quantity
- Unit price
- Line total

## How to run it

**Requirements:**
- Python 3
- An Anthropic API key

**Setup:**

```bash
pip install -r requirements.txt
export ANTHROPIC_API_KEY="your-api-key-here"
```

**Run:**

```bash
python invoice_extractor.py sample_invoice.pdf
```

This produces a CSV file with one row per line item, invoice details repeated across each row for that invoice.

## Example output

| invoice_number | invoice_date | vendor_name | customer_name | currency | total_amount | description | quantity | unit_price | line_total |
|---|---|---|---|---|---|---|---|---|---|
| INV-1042 | 2026-06-14 | Acme Supplies | Northshop Ltd | EUR | 458.00 | Widget A | 10 | 12.50 | 125.00 |
| INV-1042 | 2026-06-14 | Acme Supplies | Northshop Ltd | EUR | 458.00 | Widget B | 5 | 45.00 | 225.00 |

## Notes

- Works across currencies and varying numbers of line items without code changes.
- Built as part of a portfolio of AI automation demos — see the other demos in this repo for related work (email drafting, document Q&A).
