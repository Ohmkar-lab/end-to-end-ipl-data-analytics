import mysql.connector
import pandas as pd

# 1. MySQL connection
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="MyNewPassword123",
    database="ipl"
)

cursor = conn.cursor()

# 2. Load CSV
csv_path = r"C:\Users\OHMKAR\Downloads\archive (1)\deliveries.csv"
df = pd.read_csv(csv_path)

print("CSV loaded. Rows:", len(df))

# 3. Insert row by row
insert_query = """
INSERT INTO deliveries VALUES (
%s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
%s, %s, %s, %s, %s, %s, %s
)
"""

cursor.executemany(insert_query, df.values.tolist())

conn.commit()

print("Data inserted successfully!")

cursor.close()
conn.close()


