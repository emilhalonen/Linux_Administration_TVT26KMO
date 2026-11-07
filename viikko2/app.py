import os

import pymysql
from flask import Flask, render_template

app = Flask(__name__)


def get_connection():
    # Connect to MySQL through the server's local Unix socket.
    # Credentials are read from environment variables (.env), not from the code.
    return pymysql.connect(
        unix_socket="/var/run/mysqld/mysqld.sock",
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        autocommit=True,
    )


def increment_visits():
    # Increase the counter by one and return the new value.
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE counter SET visits = visits + 1 WHERE id = 1")
            cur.execute("SELECT visits FROM counter WHERE id = 1")
            return cur.fetchone()[0]
    finally:
        conn.close()


@app.route("/")
def index():
    visits = increment_visits()
    return render_template("index.html", visits=visits)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)