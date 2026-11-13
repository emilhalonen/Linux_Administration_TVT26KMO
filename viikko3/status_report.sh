#!/usr/bin/env bash
#   ./status_report.sh    /normal run, uses actual disk usage
#   ./status_report.sh 90 /test run, uses 90% as the disk usage

set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-/var/www/html/viikko3}"
OUTPUT_FILE="$OUTPUT_DIR/index.html"
WARNING_LIMIT=80

disk_status() {
    local usage=$1
    if [ "$usage" -ge "$WARNING_LIMIT" ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

generated_at=$(date '+%Y-%m-%d %H:%M:%S')
timezone=$(date '+%Z (UTC%:z)')
uptime_text=$(uptime -p | sed 's/^up //')
booted_at=$(uptime -s)

disk_percent=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_size=$(df -h / | awk 'NR==2 {print $2}')

ram_total=$(free -m | awk '/^Mem:/ {print $2}')
ram_available=$(free -m | awk '/^Mem:/ {print $7}')

if [ $# -ge 1 ]; then
    disk_percent=$1
    test_note="TEST RUN: disk usage replaced with $1 %"
else
    test_note=""
fi

status=$(disk_status "$disk_percent")

mkdir -p "$OUTPUT_DIR"
tmp_file=$(mktemp "$OUTPUT_DIR/.index.XXXXXX")

cat > "$tmp_file" << HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Week 3: Server status report</title>
</head>
<body>
    <h1>Week 3: Server status report</h1>
    <p>${test_note}</p>

    <h2>Status</h2>
    <table>
        <tr><th>Report is generated</th><td>${generated_at}</td></tr>
        <tr><th>Time zone</th><td>${timezone}</td></tr>
        <tr><th>Uptime</th><td>${uptime_text} (booted ${booted_at})</td></tr>
        <tr><th>Disk usage</th><td>${disk_percent} % (${disk_used} of ${disk_size})</td></tr>
        <tr><th>Disk space status</th><td>${status}</td></tr>
        <tr><th>Total RAM</th><td>${ram_total} MB</td></tr>
        <tr><th>Available RAM</th><td>${ram_available} MB</td></tr>
    </table>
</body>
</html>
HTML

chmod 644 "$tmp_file"
mv "$tmp_file" "$OUTPUT_FILE"