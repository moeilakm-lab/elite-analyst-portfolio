import numpy as np
import os
from openai import OpenAI

openai_client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

text = """
NorthShop accepts returns within 30 days of the delivery date. Items must be unused and in original packaging. 
Sale items are not eligible for return. To start a return, log in to your account and select Request Return. 
You will receive a prepaid label within 24 hours. Refunds are processed within 3 to 5 business days after we receive the item. 
Bank processing may add 2 to 3 additional days. Exchanges are available for different sizes or colours subject to stock availability. 
Damaged items must be reported within 7 days with a photo attached.
"""

# ── Strategy 1 — Fixed size chunks ──────────────────────────────────────────
# Simplest approach — cut every 100 characters, no understanding of content
chunk_size = 100
chunk_fixed = [text[i:i+chunk_size]
               for i in
               range(0, len(text), chunk_size)]

print(f"Number of chunks: {len(chunk_fixed)}")
print("---------------")
for i, chunk in enumerate(chunk_fixed):
    print(f"Chunk {i}: {chunk}")
    print("---------------")


# ── Strategy 2 — Fixed size with overlap ────────────────────────────────────
# Same as fixed, but each chunk starts earlier than the last one ended
# Overlap = smaller step between chunk starts, not smaller chunk size
# Each chunk is still 100 chars — but starts only 80 chars after the previous one
chunk_size = 100
chunk_overlap = 20
chunk_fixed_overlap = [text[i:i+chunk_size]
                       for i in
                       range(0, len(text), chunk_size - chunk_overlap)]

print(f"Number of chunks: {len(chunk_fixed_overlap)}")
print("------------------")
for i, chunk in enumerate(chunk_fixed_overlap):
    print(f"Chunk {i}: {chunk}")
    print("------------------------")


# ── Strategy 3 — Semantic chunking ──────────────────────────────────────────
# Splits by meaning, not by character count
# Uses embeddings to detect when the topic shifts between sentences

def get_embedding(text):
    # Call OpenAI API — returns a list of 1,536 numbers representing the meaning of the text
    response = openai_client.embeddings.create(
        model="text-embedding-3-small",
        input=text
    )
    return response.data[0].embedding


def cosine_similarity(a, b):
    # Measures how similar two embeddings are
    # Output: number between 0 and 1 — close to 1 = same topic, close to 0 = different topic
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))


def semantic_chunking(text, threshold=0.3):
    # Step 1 — split text into sentences on periods, strip whitespace, remove empty strings
    sentences = [s.strip() for s in text.split(".") if s.strip()]

    chunks = []                          # final list of chunks to return
    current_chunk = [sentences[0]]       # start first chunk with the first sentence

    for i in range(1, len(sentences)):
        # Step 2 — embed the current sentence and the one before it
        emb_current = get_embedding(sentences[i])
        emb_previous = get_embedding(sentences[i-1])

        # Step 3 — measure how similar the two sentences are
        similarity = cosine_similarity(emb_current, emb_previous)

        # Step 4 — decide: same chunk or new chunk?
        if similarity > threshold:
            # Topics are similar — keep building the current chunk
            current_chunk.append(sentences[i])
        else:
            # Topic shifted — save the current chunk and start a new one
            chunks.append(" ".join(current_chunk))
            current_chunk = [sentences[i]]

    # Step 5 — loop ends but last chunk is still in memory, save it
    chunks.append(" ".join(current_chunk))

    return chunks


# ── Run semantic chunking and print results ──────────────────────────────────
print("\n--- Semantic Chunking ---")
chunks = semantic_chunking(text)
for i, chunk in enumerate(chunks):
    print(f"Chunk {i}: {chunk}")
    print("------------------------")