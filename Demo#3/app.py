import streamlit as st
import anthropic
import pandas as pd
from pypdf import PdfReader
import io

st.title("Invoice Extractor")
st.write("Upload a PDF invoice to extract structured data.")

uploaded_file = st.file_uploader("Choose a PDF invoice", type="pdf")

if uploaded_file is not None:
    if st.button("Extract"):
        with st.spinner("Extracting data..."):

            # Extract text from PDF
            reader = PdfReader(io.BytesIO(uploaded_file.read()))
            invoice_text = ""
            for page in reader.pages:
                invoice_text += page.extract_text()

            # Define tool
            tool = {
                "name": "extract_invoice",
                "description": "Extract fields from PDF invoice",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "vendor_name": {"type": "string"},
                        "invoice_date": {"type": "string"},
                        "invoice_number": {"type": "string"},
                        "total_amount": {"type": "number"},
                        "currency": {"type": "string"},
                        "line_items": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "item_name": {"type": "string"},
                                    "quantity": {"type": "number"},
                                    "unit_price": {"type": "number"}
                                }
                            }
                        }
                    },
                    "required": ["vendor_name", "invoice_date", "invoice_number", "total_amount", "currency", "line_items"]
                }
            }

            # Call Claude
            client = anthropic.Anthropic()
            response = client.messages.create(
                model="claude-opus-4-6",
                max_tokens=1000,
                tools=[tool],
                tool_choice={"type": "any"},
                messages=[{"role": "user", "content": f"Extract all fields from this invoice:\n\n{invoice_text}"}]
            )

            # Parse response
            result = response.content[0].input
            rows = []
            for item in result["line_items"]:
                rows.append({
                    "vendor_name": result["vendor_name"],
                    "invoice_date": result["invoice_date"],
                    "invoice_number": result["invoice_number"],
                    "total_amount": result["total_amount"],
                    "currency": result["currency"],
                    "item_name": item["item_name"],
                    "quantity": item["quantity"],
                    "unit_price": item["unit_price"]
                })

            df = pd.DataFrame(rows)

            # Show table
            st.success("Extraction complete!")
            st.dataframe(df)

            # Download button
            csv = df.to_csv(index=False)
            st.download_button(
                label="Download CSV",
                data=csv,
                file_name="invoice_data.csv",
                mime="text/csv"
            )