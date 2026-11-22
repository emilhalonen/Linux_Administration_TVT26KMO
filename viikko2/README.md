# Week 2: Python Web App and Database
A Flask web application with a visit counter stored in MySQL, served behind Nginx.

- **Live page:** http://195.148.21.192/viikko2/
- **Stack:** Nginx (reverse proxy) --> Gunicorn --> Flask --> MySQL 8.0
- **Autostart:** the app runs as a systemd service

## Files
|File|Purpose|
|---|---|
|`app.py`|Flask app: increments and reads the counter from MySQL|
|`templates/index.html`|Page template|
|`requirements.txt`|Python dependencies|
|`deploy/viikko2.service`|systemd service for Gunicorn|
|`deploy/nginx-viikko2.conf`|Nginx reverse proxy config for `/viikko2/`|

Database credentials are kept in a `.env` file on the server and are not visible or stored in this repository for safety reasons.