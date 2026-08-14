# Demo #2 — RAG Pipeline (Chat with Your Docs)

## What it does
Converts a PDF into a question-answering bot using RAG (Retrieval Augmented Generation).

The pipeline:
1. Reads a PDF and extracts raw text
2. Splits the text into chunks (one Q&A pair per chunk)
3. Embeds each chunk using OpenAI (text-embedding-3-small)
4. Stores chunks and embeddings in ChromaDB
5. Takes a user question and embeds it
6. Finds the 3 closest chunks in the document
7. Sends the chunks + question to Claude to generate a sourced answer

## Demo document
NorthShop FAQ — a realistic e-commerce policy document covering returns, shipping, payments, and account support.

## How to run
1. Set your API keys as environment variables:
   - OPENAI_API_KEY
   - ANTHROPIC_API_KEY
2. Run: `python rag_demo.py`

## Stack
- pypdf — PDF text extraction
- OpenAI API — embeddings
- ChromaDB — vector storage and search
- Anthropic API — answer generation