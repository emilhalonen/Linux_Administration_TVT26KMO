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
    <meta http-equiv="refresh" content="60">
    <title>Week 3: Server status report</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; padding: 48px 16px; background: #0d1117; color: #c9d1d9; font-family: "JetBrains Mono", monospace; font-size: 15px; line-height: 1.6; }
        h1 { margin: 0; font-size: 30px; line-height: 1.2; color: #f0f6fc; }
        a { color: #58a6ff; }
        p { margin: 0; }
        code { color: #f0f6fc; background: #161b22; padding: 1px 6px; border-radius: 4px; overflow-wrap: anywhere; }

        /* Terminal window */
        .window { max-width: 820px; margin: 0 auto; border: 1px solid #30363d; border-radius: 12px; overflow: hidden; }
        .titlebar { background: #202020; height: 46px; padding: 0 0 0 8px; display: flex; align-items: flex-end; gap: 4px; user-select: none; }
        .tab { background: #0d1117; color: #f0f0f0; height: 38px; padding: 0 12px; border-radius: 8px 8px 0 0; display: flex; align-items: center; gap: 10px; font-family: "Segoe UI", system-ui, sans-serif; font-size: 13px; width: 260px; }
        .tab-icon { flex-shrink: 0; width: 18px; height: 18px; border-radius: 4px; background: #2d2d2d; color: #f0f0f0; font-family: "JetBrains Mono", monospace; font-size: 10px; font-weight: 700; display: flex; align-items: center; justify-content: center; }
        .tab-title { flex-grow: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .tab-close { color: #a0a0a0; font-size: 12px; }
        .tab-actions { height: 38px; display: flex; align-items: center; gap: 18px; padding: 0 12px; color: #c0c0c0; font-family: "Segoe UI", system-ui, sans-serif; font-size: 18px; }
        .tab-actions .chevron { font-size: 12px; }
        .win-controls { margin-left: auto; align-self: stretch; display: flex; }
        .win-controls span { width: 46px; display: flex; align-items: center; justify-content: center; color: #c0c0c0; font-family: "Segoe UI", system-ui, sans-serif; font-size: 14px; }
        .win-controls span:hover { background: #333333; }
        .win-controls .close:hover { background: #c42b1c; color: #ffffff; }
        .content { padding: 28px; }
        .block { margin-bottom: 30px; }

        /* Terminal text */
        .prompt { display: block; color: #3fb950; margin-bottom: 6px; }
        .comment { color: #8b949e; }
        .key { color: #d29922; }
        .OK { color: #3fb950; font-weight: 700; }
        .WARNING { color: #f85149; font-weight: 700; }
        .test { color: #f85149; font-weight: 700; }
        .cursor { color: #3fb950; animation: blink 1s steps(1) infinite; }
        @keyframes blink { 50% { opacity: 0; } }
        pre { margin: 0; font-family: inherit; white-space: pre-wrap; }

        /* Header with Tux */
        .header { display: flex; gap: 24px; align-items: center; flex-wrap: wrap; }
        .header img { width: 110px; height: auto; }

        /* Documentation */
        ul { margin: 0; padding-left: 20px; }
        li { margin-bottom: 8px; }
        table { border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #30363d; padding: 6px 14px; text-align: left; }
        th { color: #d29922; }

        /* Link buttons */
        .links { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; }
        .link { display: flex; flex-direction: column; gap: 4px; padding: 16px 18px; border-radius: 10px; text-decoration: none; color: #c9d1d9; transition: background 0.15s, transform 0.15s; }
        .link:hover { transform: translateY(-2px); }
        .link .label { font-size: 16px; font-weight: 700; }
        .link .sub { font-size: 13px; }
        .link.github { border: 1px solid #3fb950; background: #0f1a12; }
        .link.github .label { color: #3fb950; }
        .link.week { border: 1px solid #58a6ff; background: #0d1626; }
        .link.week .label { color: #58a6ff; }
    </style>
</head>
<body>
<div class="window">
    <div class="titlebar">
        <div class="tab">
            <span class="tab-icon">&gt;_</span>
            <span class="tab-title">ubuntu@week2: ~/linux-admin/viikko3</span>
            <span class="tab-close">✕</span>
        </div>
        <div class="tab-actions">
            <span>+</span>
            <span class="chevron">⌄</span>
        </div>
        <div class="win-controls">
            <span>─</span>
            <span>☐</span>
            <span class="close">✕</span>
        </div>
    </div>
    <div class="content">

        <div class="block header">
            <img src="/tux.svg" alt="Tux, the Linux mascot">
            <div>
                <span class="prompt">$ cat README</span>
                <h1>Week 3: Server status report</h1>
                <span class="comment"># This report is generated by a Bash script every minute</span>
            </div>
        </div>

        <div class="block">
            <span class="prompt">$ ./status_report.sh</span>
            <p class="test">${test_note}</p>
<pre>
<span class="key">Report is generated</span> : ${generated_at}
<span class="key">Time zone          </span> : ${timezone}
<span class="key">Uptime             </span> : ${uptime_text} (booted ${booted_at})
<span class="key">Disk usage         </span> : ${disk_percent} % (${disk_used} of ${disk_size})
<span class="key">Disk space status  </span> : <span class="${status}">${status}</span>  <span class="comment"># OK below ${WARNING_LIMIT} %, WARNING at ${WARNING_LIMIT} % or above</span>
<span class="key">Total RAM          </span> : ${ram_total} MB
<span class="key">Available RAM      </span> : ${ram_available} MB</pre>
            <p class="comment" style="margin-top: 10px;"># The report is updated every minute, and the page reloads itself every 60 seconds.</p>
        </div>

        <div class="block">
            <span class="prompt">$ man commands-used</span>
            <ul>
                <li><code>date '+%Y-%m-%d %H:%M:%S'</code> prints the current date and time. The format after the plus sign decides how the output looks, and <code>date '+%Z'</code> prints the time zone.</li>
                <li><code>uptime -p</code> prints how long the server has been running in an easy-to-read form, for example "5 days, 20 hours".</li>
                <li><code>df / | awk 'NR==2 {print &#36;5}' | tr -d '%'</code> is a pipe of three commands. df lists the disk usage of the root filesystem, awk picks the usage percentage from the second row and tr removes the % sign so the value can be compared as a number.</li>
                <li><code>free -m | awk '/^Mem:/ {print &#36;2}'</code> is another pipe. free shows the memory in megabytes and awk picks the total RAM from the row that starts with Mem:.</li>
            </ul>
        </div>

        <div class="block">
            <span class="prompt">$ man how-it-works</span>
            <p>
                The script runs Linux commands and saves their output in variables using command substitution,
                for example <code>disk_percent=&#36;(df / | awk ... | tr -d '%')</code>. The function
                <code>disk_status</code> takes the disk usage as a parameter and uses an if statement to decide
                the status: 80 % or more returns WARNING, anything below that returns OK. Finally the script builds
                the HTML page in a temporary file and moves it to index.html, so visitors never see an unfinished
                page. Nginx serves the page at /viikko3/.
            </p>
        </div>

        <div class="block">
            <span class="prompt">$ systemctl cat status-report.timer</span>
            <p>
                The report is updated by a systemd timer. The service file <code>status-report.service</code> runs
                the script once, and the timer file <code>status-report.timer</code> starts the service every minute
                with <code>OnCalendar=*-*-* *:*:00</code>. I enabled the timer with
                <code>systemctl enable --now status-report.timer</code>, which means it starts automatically
                whenever the server boots.
            </p>
        </div>

        <div class="block">
            <span class="prompt">$ cat test-results.txt</span>
            <p><span class="key">Syntax check:</span> <code>bash -n status_report.sh</code> did not report any errors. Running <code>./status_report.sh</code> manually created the report, and it opened correctly in the browser.</p>
            <p style="margin-top: 12px;"><span class="key">Disk status tests:</span> I tested the status logic by giving the script a test value as an argument, for example <code>./status_report.sh 90</code>. After testing I ran the script without an argument to restore the real disk usage.</p>
            <table>
                <tr><th>Test input</th><th>Expected</th><th>Actual</th></tr>
                <tr><td>50 %</td><td>OK</td><td class="OK">OK</td></tr>
                <tr><td>80 %</td><td>WARNING</td><td class="WARNING">WARNING</td></tr>
                <tr><td>90 %</td><td>WARNING</td><td class="WARNING">WARNING</td></tr>
            </table>
            <p style="margin-top: 12px;"><span class="key">Automatic updates:</span> TODO: two generation times in a row.</p>
            <p style="margin-top: 12px;"><span class="key">Reboot test:</span> TODO: reboot time and result.</p>
        </div>

        <div class="block">
            <span class="prompt">$ cat lesson-learned.txt</span>
                       <p>
                While working on week 3 project, I noticed that my Week 2 page showed "502 Bad Gateway".
                With <code>systemctl status</code> and <code>journalctl -u viikko2</code> I found out that
                the app had been stopped at 08:06, at the same moment when MySQL was restarted by an
                automatic security update. My service file had <code>Requires=mysql.service</code>, which
                stops the app when MySQL stops, but does not start it again. I changed it to
                <code>Wants=mysql.service</code>, so the app keeps running when MySQL restarts.
                The lesson for me was to remember to check that my existing services still work,
                not only the new projects I'm building =D
            </p>
        </div>

        <div class="block">
            <span class="prompt">$ ls links/</span>
            <div class="links">
                <a class="link github" href="https://github.com/emilhalonen/Linux_Administration_TVT26KMO">
                    <span class="label">Source code →</span>
                    <span class="sub">GitHub repository</span>
                </a>
                <a class="link week" href="/viikko2/">
                    <span class="label">← Week 2 page</span>
                    <span class="sub">Python web app</span>
                </a>
                <a class="link week" href="/">
                    <span class="label">← Week 1 page</span>
                    <span class="sub">Nginx static site</span>
                </a>
            </div>
        </div>

        <span class="prompt">$ <span class="cursor">█</span></span>
    </div>
</div>
</body>
</html>
HTML

chmod 644 "$tmp_file"
mv "$tmp_file" "$OUTPUT_FILE"