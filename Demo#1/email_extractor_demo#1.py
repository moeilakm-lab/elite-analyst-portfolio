#raw email     → str
#call API      → Message object   (not str)
#.text          Message → str    (route)   .content[0].text
#strip fences  → str
#json.loads    → dict   ← the only transformation
#check fields  → dict passes, or verdict
#check types   → dict passes, or verdict


import json
import anthropic

email = """
Hi there,

 my name is Ahmed Ali and i am interested in buying 5 coffee machines from your store for my recently opened coffee shop , i would
like to know the price of each one of them , the delievey timeline and is there any dicsounts available for bulk purchases.
"""

client = anthropic.Anthropic()
system_prompt = """You are an agent and your job to extract the content of the email into json only code with the following fields:
customer_name : name of the client  
-product_name : name of the product customer purchased 
-quantity : the quantity purchased by customer  
- delivery_timeframe :  how many days it will take to deliver the product
-price: price of the product , if any of these fileds are not given in the email or not clear enough to extract , 
you should return null for that field and do not make any assumptions about the content of the email."""

response=client.messages.create(
    model="claude-opus-4-6",
    max_tokens = 500,
    temperature = 0,
    system=system_prompt,
    messages=[{"role": "user", "content": email }]
)
raw = response.content[0].text
cleaned=raw.strip()
cleaned=cleaned.removeprefix("```json")
cleaned=cleaned.removesuffix("```")
cleaned=cleaned.strip()


try:
    data=json.loads(cleaned)
except json.JSONDecodeError:
    print("skipping: invalid JSON")
    exit()

if isinstance(data, dict):
    data=[data] 
elif isinstance(data, list):
    pass
else:
    print("shape: unexpected")


required_fields=["customer_name", "product_name", "quantity", "price", "delivery_timeframe"]
expected_types={"customer_name": str, "product_name":str, "quantity":int , "price":float, "delivery_timeframe":int}
def check_fields(record, required):
    missing=[]
    for items in required:
        if items not in record:
            missing.append(items)
    return missing
def check_type(record, expected_types):
            
            for item in expected_types:
                if record[item] is None:
                    continue
                if not isinstance((record[item]),(expected_types[item])):
                    return False

            return True

for product in data:
    missing=check_fields(product,required_fields)
    if missing:
        print("skipping record, missing fields: ",missing)
    else:
        type_ok=check_type(product,expected_types)
        if not type_ok:
            print("skipping record, wrong types")
        else:
            #print("record ok: ",product)

           
            agent_prompt = """you are customer service agent got information extracted from customer email and filled in product , 
            your job is to reply to this email in text format by begining with greeting the customer by his name and thank him for contacting us"""

            response=client.messages.create(
                model="claude-opus-4-6",
                max_tokens = 500,
                temperature = 0.5,
                system=agent_prompt,
                messages=[{"role": "user", "content": str(product) }]
            )
            print(response.content[0].text)
            
        


 




