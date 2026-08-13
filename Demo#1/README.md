AI Email Assistant — Demo #1

This script automates the handling of customer enquiry emails for an electronics store. It takes a raw email as input, extracts key information (customer name, product, quantity, price, delivery timeframe) using the Anthropic API, validates the extracted data for missing fields and incorrect types, and generates a professional reply to the customer — asking for any missing details if needed.

If the email produces malformed JSON, missing required fields, or wrong data types, the script prints a specific error message and skips that record rather than crashing.

How to run:

Set your Anthropic API key as an environment variable: ANTHROPIC_API_KEY=your_key
Run: python excercise.py

What it demonstrates: end-to-end AI automation — LLM extraction, structured validation, and reply generation in a single Python pipeline.