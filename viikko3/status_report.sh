#!/usr/bin/env bash
#Week3: server status report
#collects server information and writes it as an html page
#that nginx serves at /viikko3/

set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-/var/www/html/viikko3}"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

generated_at=$(date '+%Y-%m-%d %H:%M:%S')
timezone=$(date '+%Z (UTC%:z)')
uptime_text=$(uptime -p | sed 's/^up //')
booted_at=$(uptime -s)

disk_percent=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_size=$(df -h / | awk 'NR==2 {print $2}')

ram_total=$(free -m | awk '/^Mem:/ {print $2}')
ram_available=$(free -m | awk '/^Mem:/ {print $7}')




mkdir -p "$OUTPUT_DIR"
tmp_file=$(mktemp "$OUTPUT_DIR/.index.XXXXXX")

cat > "$tmp_file" << HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Week 3: Server Status Report</title>
</head>
<body>
    <h1>Week 3: Server Status Report</h1>

    <h2>Status</h2>
    <table>
        <tr><th>Report generated</th><td>${generated_at}</td></tr>
        <tr><th>Time zone</th><td>${timezone}</td></tr>
        <tr><th>Uptime</th><td>${uptime_text} (booted ${booted_at})</td></tr>
        <tr><th>Disk usage (/)</th><td>${disk_percent} % (${disk_used} of ${disk_size})</td></tr>
        <tr><th>Total RAM</th><td>${ram_total} MB</td></tr>
        <tr><th>Available RAM</th><td>${ram_available} MB</td></tr>
    </table>
</body>
</html>
HTML

chmod 644 "$tmp_file"
mv "$tmp_file" "$OUTPUT_FILE"