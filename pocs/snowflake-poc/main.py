import snowflake.connector
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric import dsa
from cryptography.hazmat.primitives import serialization

# Load the private key from a file
with open("rsa_key.p8", "rb") as key:
    p_key = serialization.load_pem_private_key(
        key.read(),
        password=None,
        backend=default_backend()
    )

# Convert the private key to bytes
pkb = p_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption()
)

# Connect to Snowflake
ctx = snowflake.connector.connect(
    user='zshapiro',
    account='jn35134.us-central1.gcp',
    private_key=pkb
)

# Create a cursor
cs = ctx.cursor()

# Example query
try:
    cs.execute("select current_user()")
    result = cs.fetchone()
    print(result)
finally:
    cs.close()
    ctx.close()