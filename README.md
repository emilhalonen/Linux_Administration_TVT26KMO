# Linux Administration TVT26KMO

Course assignments for the Linux Administration course will be found here. The server runs Ubuntu 24.04 on CSC cPouta.

## Week 2: Python Web App and Database

A Flask web application with a visit counter stored in MySQL, served behind Nginx.

- **Live page:** http://195.148.21.192/viikko2/
- **Stack:** Nginx (reverse proxy) --> Gunicorn --> Flask --> MySQL 8.0
- **Autostart:** the app runs as a systemd service

### Files

|File|Purpose|
|---|---|
|`viikko2/app.py`|Flask app: increments and reads the counter from MySQL|
|`viikko2/templates/index.html`|Page template|
|`viikko2/requirements.txt`|Python dependencies|
|`viikko2/deploy/viikko2.service`|systemd service for Gunicorn|
|`viikko2/deploy/nginx-viikko2.conf`|Nginx reverse proxy config for `/viikko2/`|

Database credentials are kept in a `.env` file on the server and are not visible or stored in this repository for safety reasons.
