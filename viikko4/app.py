import os

import pymysql
from flask import Flask, render_template

app = Flask(__name__)


def get_connection():
    return pymysql.connect(
        unix_socket="/var/run/mysqld/mysqld.sock",
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
    )


def read_replica():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT visits FROM counter WHERE id = 1")
            visits = cur.fetchone()[0]
            cur.execute(
                "SELECT @@hostname, @@server_id, @@super_read_only, "
                "DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')"
            )
            hostname, server_id, super_read_only, queried_at = cur.fetchone()
        return {
            "visits": visits,
            "hostname": hostname,
            "server_id": server_id,
            "super_read_only": "ON" if super_read_only else "OFF",
            "queried_at": queried_at,
        }
    finally:
        conn.close()

@app.route("/")
def index():
    data = read_replica()
    response = app.make_response(render_template("index.html", **data))
    # The browser must ask for a fresh value every time.
    response.headers["Cache-Control"] = "no-store"
    return response

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001)
