# 외부 접속 IP 감시 PowerShell 스크립트

$LOG_FILE = ".\exip.log"

if (!(Test-Path $LOG_FILE)) {
    New-Item -Path $LOG_FILE -ItemType File | Out-Null
}

"📡 외부 접속 IP 감시 시작" | Out-File $LOG_FILE -Append

while ($true) {

    "-----------------------------" | Out-File $LOG_FILE -Append

    $MOSCOW_TIME = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(
        (Get-Date),
        "Russian Standard Time"
    )

    $GMT_TIME = (Get-Date).ToUniversalTime()

    "MOSCOW TIME : $MOSCOW_TIME" | Out-File $LOG_FILE -Append
    "GMT TIME    : $GMT_TIME" | Out-File $LOG_FILE -Append


    "[INCOMING CONNECTION]" | Out-File $LOG_FILE -Append


    # Windows TCP 연결 확인
    $connections = Get-NetTCPConnection |
        Where-Object {
            $_.State -eq "Established" -and
            $_.RemoteAddress -notmatch "^(127\.|0\.|::1)"
        }


    foreach ($conn in $connections) {

        $IP = $conn.RemoteAddress

        if ($IP -match "^\d{1,3}(\.\d{1,3}){3}$") {

            $GEO = curl.exe -s --max-time 2 "https://ipinfo.io/$IP"

            "🌐 CLIENT IP : $IP" | Out-File $LOG_FILE -Append
            "📍 GEO : $GEO" | Out-File $LOG_FILE -Append
            "-----------------------------" | Out-File $LOG_FILE -Append
        }
    }


    # 내 PC IP
    $LOCAL_IP = (Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object {
            $_.IPAddress -notlike "127.*"
        }).IPAddress

    "🖥 LOCAL IP : $LOCAL_IP" | Out-File $LOG_FILE -Append


    Start-Sleep -Seconds 5
}
