import os
import anthropic
import json
import pandas as pd
from pypdf import PdfReader

reader = PdfReader(r"D:\The future\6 weeks plan\scripts\product\Demo#3\sample_invoice_2.pdf")
invoice_text = ""
for item in reader.pages:
    invoice_text += item.extract_text()
anthropic_client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
tool={
    "name":"extract_invoice",
    "description":"Extract fields from PDF invoice",
    "input_schema":{
        "type":"object",
        "properties":{
            "vendor_name":{"type":"string"},
            "invoice_date":{"type":"string"},
            "invoice_number":{"type":"string"},
            "total_amount":{"type":"number"},
            "currency":{"type":"string"},
            "line_items":{
                "type":"array",
                "items":{
                "type":"object",
                "properties":{
                    "item_name":{"type":"string"},
                    "quantity":{"type":"number"},
                    "unit_price":{"type":"number"}
                            }
                        }
                    }
                 },
                 "required": ["vendor_name", "invoice_date", "invoice_number", "total_amount", "currency", "line_items"]
                }
}

response = anthropic_client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1000,
    tools=[tool],
    tool_choice={"type":"any"},
    messages=[
        {"role":"user","content": f"Extract the invoice fields from this text:\n\n{invoice_text}"}
    ]
)
print(response.content)
extracted = response.content[0].input
rows=[]
for item in extracted['line_items']:
    row={
        'vendor_name': extracted['vendor_name'],
        'invoice_date': extracted['invoice_date'],
        'invoice_number': extracted['invoice_number'],
        'total_amount':extracted['total_amount'],
        'currency':extracted['currency'],
        'item_name': item['item_name'],
        'quantity': item['quantity'],
        'unit_price': item['unit_price']
    }
    rows.append(row)
#print(extracted)
print(rows)
df=pd.DataFrame(rows)
df.to_csv(r"D:\The future\6 weeks plan\scripts\lab\invoice_output2.csv", index=False)