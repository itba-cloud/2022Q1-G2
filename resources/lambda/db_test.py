import sys
import boto3
import logging
import urllib.parse
from pip._internal import main  # install pg8000
import os

main(['install', '-I', '-q', 'pg8000', '--target', '/tmp/', '--no-cache-dir', '--disable-pip-version-check'])
sys.path.insert(0, '/tmp/')

import pg8000


def main_handler(event, context):
    sql = """SELECT current_timestamp"""

    conn = pg8000.connect(
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASS'],
        host=os.environ['DB_ENDPOINT'],
        port=os.environ['DB_PORT'],
        ssl_context=True
    )

    dbcur = conn.cursor()
    dbcur.execute(sql)
    results = dbcur.fetchall()
    dbcur.close()

    return str(results)
