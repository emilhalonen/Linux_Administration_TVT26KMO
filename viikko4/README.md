# Week 4: Server Cloning, Backups and Database Replication

Server B is a clone of server A. It pulls hourly backups of A's website files
and keeps a read-only MySQL replica of the week 2 visit counter.

- **Server A (counter, +1 on every load):** http://195.148.21.192/viikko2/
- **Server B (read-only replica):** http://128.214.255.14/viikko4/

| Server | Hostname | Public IP | Internal IP | Role |
|---|---|---|---|---|
| A | `week2` | 195.148.21.192 | 192.168.1.228 | MySQL source, week 1–3 pages |
| B | `server-b` | 128.214.255.14 | 192.168.1.118 | Backups, MySQL replica, week 4 page |

## Files
| File | Installed on | Purpose |
|---|---|---|
| `backup/website-backup.sh` | B: `/usr/local/sbin/website-backup.sh` (root, 750) | Pulls `/var/www/html` from A over SSH into a timestamped `.tar.gz` |
| `backup/website-backup.cron` | B: `/etc/cron.d/website-backup` (root, 644) | Runs the backup every hour at minute 30 |
| `mysql/server-a-replication.cnf` | A: `/etc/mysql/mysql.conf.d/replication.cnf` | Binary log, `server-id = 1` |
| `mysql/server-b-replication.cnf` | B: `/etc/mysql/mysql.conf.d/replication.cnf` | Replica settings, `super_read_only = ON` |
| `mysql/setup-replication.sql` | – | SQL commands used to set up replication (passwords removed) |
| `app.py`, `templates/index.html` | B | Flask app that only reads the counter |
| `deploy/viikko4.service` | B: `/etc/systemd/system/` | Gunicorn on 127.0.0.1:5001 |
| `deploy/nginx-viikko4.conf` | B: `/etc/nginx/snippets/viikko4.conf` | Nginx reverse proxy for `/viikko4/` |

## Backups
- Stored on B in `/var/backups/website-from-a/` (root only, mode 700), outside the web root.
- Each run logs `OK` or `FAILED` to `/var/log/website-backup.log`.
- The 48 newest archives (two days) are kept.

## Replication
MySQL 8.0 is used instead of MariaDB, because the servers already ran MySQL from week 2.
Only the `viikko2` database is replicated. The replication user on A can only log in from
B's internal IP, and MySQL on A does not listen on the public IP.

Replication is not a backup: a mistake on A, such as a deleted table, is copied to B immediately.

## Not in this repository
Passwords, SSH keys, `/etc/viikko4.env`, SQL dumps and backup archives are kept only on the servers.