
import os
import anthropic
import json
import chromadb
import re


from pypdf import PdfReader

reader = PdfReader(r"D:\The future\6 weeks plan\scripts\product\Demo#2\northshop_faq.pdf")

raw_text=""
for page in reader.pages:
    raw_text += page.extract_text()


chunks = re.split(r'\n(?=[A-Z][^\n]*\?)', raw_text)  # show the code where to split the chunks 
chunks = [chunk for chunk in chunks if "?" in chunk] # clean the chunks to remove the headers 


from openai import OpenAI
anthropic_client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))  
openai_client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY")) #call OpenAI API

def get_embedding(chunk):
 
    response=openai_client.embeddings.create(        
        model="text-embedding-3-small",             
        input=chunk                                  
    )
   
    return response.data[0].embedding          
    pass 



embeddings = []
for chunk in chunks:
    embedding = get_embedding(chunk)
    embeddings.append(embedding)




chroma_client = chromadb.Client()
collection = chroma_client.create_collection(name="northshop_faq")

collection.add(
    documents=chunks,
    embeddings=embeddings,
    ids=[str(i) for i in range(len(chunks))]
)


question = input("Ask a question: ")

question_embedding = get_embedding(question)

results = collection.query(
    query_embeddings=[question_embedding],
    n_results=3                                 
)



anthropic_client = anthropic.Anthropic()

context = "\n\n".join(results["documents"][0])  

answer = anthropic_client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="You are a customer service agent. You will receive a client query and related excerpts from the company policy. Find the best answer that matches the client question and reply to the client professionally.",
    messages=[
        {"role": "user", "content": f"Question: {question}\n\nContext:\n{context}"}
    ]
)

print(answer.content[0].text)



