# =====================================
# NAVac IP Monitor + Auto Block
# Windows PowerShell Version
# Part 1
# =====================================

# UTF-8
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# 로그 파일
$LOG_FILE = "I:\wsl\t-t-sea.log"

# 설정
$THRESHOLD = 10
$BLOCK_TIME = 600
$ENABLE_BLOCK = $true

# DNS 캐시 (10분)
$DNS_CACHE = @{}
$DNS_CACHE_TIME = 600

# GeoIP 캐시 (1시간)
$IP_CACHE = @{}
$IP_CACHE_TIME = 3600

# 현재 공인 IP
# 내 공인 IP
try{
    $MY_PUBLIC_IP = (curl.exe -s --max-time 5 https://ifconfig.me).Trim()
}catch{
    $MY_PUBLIC_IP = ""
}

# 화이트리스트
$WHITELIST = @(
    # Localhost
    "127.0.0.1",
    "::1",

    # 내 공인 IP
    $MY_PUBLIC_IP,

    # Google Public DNS
    "8.8.8.8",
    "8.8.4.4",

    # Cloudflare DNS
    "1.1.1.1",
    "1.0.0.1",

    # KT DNS
    "168.126.63.1",
    "168.126.63.2",

    # SK Broadband / SKT DNS
    "219.250.36.130",
    "210.220.163.82",

    # LG U+ DNS
    "164.124.101.2",
    "203.248.252.2",

    # Quad9 DNS
    "9.9.9.9",
    "149.112.112.112",

    # OpenDNS
    "208.67.222.222",
    "208.67.220.220",

    # AdGuard DNS
    "94.140.14.14",
    "94.140.15.15",

    # CleanBrowsing DNS
    "185.228.168.9",
    "185.228.169.9",
    "185.228.168.10",
    "185.228.169.11",

    # NextDNS Anycast
    "45.90.28.0",
    "45.90.30.0",

    # Control D
    "76.76.2.0",
    "76.76.10.0",

    # DNS.WATCH
    "84.200.69.80",
    "84.200.70.40",

    # Comodo Secure DNS
    "8.26.56.26",
    "8.20.247.20",

    # Verisign Public DNS
    "64.6.64.6",
    "64.6.65.6",

    # Yandex DNS
    "77.88.8.8",
    "77.88.8.1",

    # Alternate DNS
    "76.76.19.19",
    "76.223.122.150"
) | Where-Object { $_ } | Sort-Object -Unique

# 차단 목록
$BLOCKED = @{}

############################################################
# 로그
############################################################

function Write-Log {

    param([string]$Message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    "$time $Message" |
        Tee-Object -FilePath $LOG_FILE -Append
}

############################################################
# 화이트리스트
############################################################

function Is-WhiteList {

    param($IP)

    return ($WHITELIST -contains $IP)
}

############################################################
# DNS 조회 (10분 캐시)
############################################################

function Get-DNSName {

    param($IP)

    $now = Get-Date

    if($DNS_CACHE.ContainsKey($IP))
    {
        $cache = $DNS_CACHE[$IP]

        if((($now-$cache.Time).TotalSeconds) -lt $DNS_CACHE_TIME)
        {
            return $cache.Name
        }
    }

    try
    {
        $dns = ([System.Net.Dns]::GetHostEntry($IP)).HostName
    }
    catch
    {
        $dns = "-"
    }

    $DNS_CACHE[$IP] = @{
        Name = $dns
        Time = $now
    }

    return $dns
}

############################################################
# GeoIP 조회 (1시간 캐시)
############################################################

function Get-IPInfo {

    param($IP)

    $now = Get-Date

    if($IP_CACHE.ContainsKey($IP))
    {
        $cache = $IP_CACHE[$IP]

        if((($now-$cache.Time).TotalSeconds) -lt $IP_CACHE_TIME)
        {
            return $cache.Info
        }
    }

    try
    {
        $json = curl.exe -s --max-time 5 "https://ipinfo.io/$IP/json" |
            ConvertFrom-Json

        $org = $json.org
        $city = $json.city
        $country = $json.country

        $service = "🌐 Unknown"

        switch -Regex ($org)
        {
            "Cloudflare" { $service="☁ Cloudflare"; break }
            "Fastly" { $service="⚡ Fastly"; break }
            "Google" { $service="🌎 Google"; break }
            "Microsoft" { $service="🪟 Microsoft"; break }
            "Amazon" { $service="☁ AWS"; break }
            "Apple" { $service="🍎 Apple"; break }
            "Meta" { $service="📘 Meta"; break }
            "Facebook" { $service="📘 Meta"; break }
            "Oracle" { $service="🟥 Oracle"; break }
            "Tencent" { $service="🐧 Tencent"; break }
            "Akamai" { $service="🚀 Akamai"; break }
            "NAVER" { $service="🟢 NAVER"; break }
            "Kakao" { $service="💛 Kakao"; break }
        }

        $result = [PSCustomObject]@{

            Service = $service
            Org      = $org
            City     = $city
            Country  = $country
        }

    }
    catch
    {
        $result = [PSCustomObject]@{

            Service = "?"
            Org      = ""
            City     = ""
            Country  = ""
        }
    }

    $IP_CACHE[$IP] = @{

        Info = $result
        Time = $now
    }

    return $result
}
############################################################
# 방화벽 차단
############################################################

function Block-IP {

    param($IP)

    if(Is-WhiteList $IP)
    {
        return
    }

    $rule = "NAVac_BLOCK_$IP"

    try
    {
        if(!(Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue))
        {
            New-NetFirewallRule `
                -DisplayName $rule `
                -Direction Inbound `
                -RemoteAddress $IP `
                -Action Block `
                -Profile Any | Out-Null

            $BLOCKED[$IP] = Get-Date

            Write-Log "🚫 BLOCK : $IP"
        }
    }
    catch
    {
        Write-Log "❌ Firewall Error : $IP"
    }
}

############################################################
# 차단 해제
############################################################

function UnBlock-IP {

    param($IP)

    $rule = "NAVac_BLOCK_$IP"

    try
    {
        Remove-NetFirewallRule `
            -DisplayName $rule `
            -ErrorAction SilentlyContinue

        if($BLOCKED.ContainsKey($IP))
        {
            $BLOCKED.Remove($IP)
        }

        Write-Log "✅ UNBLOCK : $IP"
    }
    catch
    {
        Write-Log "❌ UNBLOCK FAIL : $IP"
    }
}

############################################################
# 차단 시간 확인
############################################################

function Remove-ExpiredBlock {

    foreach($ip in @($BLOCKED.Keys))
    {
        $elapsed = (
            New-TimeSpan `
                -Start $BLOCKED[$ip] `
                -End (Get-Date)
        ).TotalSeconds

        if($elapsed -ge $BLOCK_TIME)
        {
            UnBlock-IP $ip
        }
    }

}

############################################################
# 재부팅 후 기존 규칙 복원
############################################################

function Restore-BlockedRules {

    Write-Log "🔄 Restore Firewall Rules"

    try
    {
        $rules = Get-NetFirewallRule |
            Where-Object {
                $_.DisplayName -like "NAVac_BLOCK_*"
            }

        foreach($rule in $rules)
        {
            $addr = (
                Get-NetFirewallAddressFilter `
                    -AssociatedNetFirewallRule $rule
            ).RemoteAddress

            if($addr)
            {
                $BLOCKED[$addr] = Get-Date

                Write-Log "✔ Restore : $addr"
            }
        }
    }
    catch
    {
        Write-Log "❌ Restore Error"
    }

}

############################################################
# 캐시 정리
############################################################

function Clear-ExpiredCache {

    $now = Get-Date

    foreach($ip in @($DNS_CACHE.Keys))
    {
        $t = $DNS_CACHE[$ip].Time

        if((($now-$t).TotalSeconds) -gt $DNS_CACHE_TIME)
        {
            $DNS_CACHE.Remove($ip)
        }
    }

    foreach($ip in @($IP_CACHE.Keys))
    {
        $t = $IP_CACHE[$ip].Time

        if((($now-$t).TotalSeconds) -gt $IP_CACHE_TIME)
        {
            $IP_CACHE.Remove($ip)
        }
    }

}

############################################################
# 시작 로그
############################################################

Write-Log ""
Write-Log "==============================================="
Write-Log "📡 NAVac IP Monitor Start"
Write-Log "==============================================="
Write-Log "My Public IP : $MY_PUBLIC_IP"

Restore-BlockedRules
############################################################
# 메인 감시 루프
############################################################

while ($true)
{
    Write-Log "------------------------------------------------------------"

    # 현재 시간
    $NOW = Get-Date

    try
    {
        $MOSCOW = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(
            $NOW,
            "Russian Standard Time"
        )
    }
    catch
    {
        $MOSCOW = "-"
    }

    $GMT = $NOW.ToUniversalTime()

    Write-Log "LOCAL  : $NOW"
    Write-Log "MOSCOW : $MOSCOW"
    Write-Log "GMT    : $GMT"

    ########################################################
    # TCP 연결 수집
    ########################################################

    try
    {
        $connections = Get-NetTCPConnection |
            Where-Object {

                $_.State -eq "Established" -and
                $_.RemoteAddress -notmatch "^(0\.|127\.|::1)"
            }
    }
    catch
    {
        Write-Log "❌ Get-NetTCPConnection Error"

        Start-Sleep -Seconds 5
        continue
    }

    ########################################################
    # IPv4만 추출
    ########################################################

    $ips = $connections |
        Select-Object -ExpandProperty RemoteAddress |
        Where-Object {

            $_ -match "^\d+\.\d+\.\d+\.\d+$"
        } |
        Group-Object |
        Sort-Object Count -Descending

    if($ips.Count -eq 0)
    {
        Write-Log "No Active Remote IP."

        Remove-ExpiredBlock
        Clear-ExpiredCache

        Start-Sleep -Seconds 5

        continue
    }

    ########################################################
    # IP 분석
    ########################################################

    foreach($item in $ips)
    {
        $ip = $item.Name
        $count = $item.Count

        if(Is-WhiteList $ip)
        {
            continue
        }

        ####################################################
        # DNS (10분 캐시)
        ####################################################

        $dns = Get-DNSName $ip

        ####################################################
        # GeoIP (1시간 캐시)
        ####################################################

        $info = Get-IPInfo $ip

        ####################################################
        # 출력
        ####################################################

        Write-Log (
            "{0,-15} COUNT:{1,-3} {2,-14} {3,-35} {4,-15} {5,-5}" -f `
            $ip,
            $count,
            $info.Service,
            $info.Org,
            $info.City,
            $info.Country
        )

        Write-Log ("DNS : {0}" -f $dns)

        ####################################################
        # 자동 차단
        ####################################################

        if($ENABLE_BLOCK -and ($count -ge $THRESHOLD))
        {
            Write-Log "⚠ Threshold Reached ($count >= $THRESHOLD)"

            Block-IP $ip
        }

    }

    ########################################################
    # 차단 만료 검사
    ########################################################

    Remove-ExpiredBlock

    ########################################################
    # 캐시 정리
    ########################################################

    Clear-ExpiredCache

    ########################################################
    # 다음 검사
    ########################################################

    Start-Sleep -Seconds 5

}
############################################################
# Part 4
# NAVac v2.0 Performance Patch
############################################################

# DNS를 이미 조회한 IP(이번 루프 동안)
$SCRIPT:DNS_LOOKUP = @{}

# GeoIP를 이미 조회한 IP(이번 루프 동안)
$SCRIPT:GEO_LOOKUP = @{}

############################################################
# DNS 조회 (Resolve-DnsName 우선)
############################################################

function Get-DNSName {

    param([string]$IP)

    if($SCRIPT:DNS_LOOKUP.ContainsKey($IP))
    {
        return $SCRIPT:DNS_LOOKUP[$IP]
    }

    $now = Get-Date

    if($DNS_CACHE.ContainsKey($IP))
    {
        $cache = $DNS_CACHE[$IP]

        if((($now-$cache.Time).TotalSeconds) -lt $DNS_CACHE_TIME)
        {
            $SCRIPT:DNS_LOOKUP[$IP] = $cache.Name
            return $cache.Name
        }
    }

    $dns = "-"

    try
    {
        $dns = (Resolve-DnsName -Name $IP -ErrorAction Stop).NameHost

        if(!$dns)
        {
            $dns = ([System.Net.Dns]::GetHostEntry($IP)).HostName
        }
    }
    catch
    {
        try
        {
            $dns = ([System.Net.Dns]::GetHostEntry($IP)).HostName
        }
        catch
        {
            $dns = "-"
        }
    }

    $DNS_CACHE[$IP] = @{
        Name = $dns
        Time = $now
    }

    $SCRIPT:DNS_LOOKUP[$IP] = $dns

    return $dns
}

############################################################
# 루프 시작 시 초기화
############################################################

function Begin-Loop {

    $SCRIPT:DNS_LOOKUP = @{}
    $SCRIPT:GEO_LOOKUP = @{}
}

############################################################
# 캐시 통계
############################################################

function Show-Statistics {

    Write-Log "--------------------------------------"
    Write-Log ("DNS Cache : {0}" -f $DNS_CACHE.Count)
    Write-Log ("Geo Cache : {0}" -f $IP_CACHE.Count)
    Write-Log ("Blocked   : {0}" -f $BLOCKED.Count)
    Write-Log "--------------------------------------"

}

############################################################
# 차단된 IP는 다시 조회하지 않음
############################################################

function Is-Blocked {

    param($IP)

    return $BLOCKED.ContainsKey($IP)

}

############################################################
# 메인 루프 수정 사항
############################################################

# while 루프의 맨 처음에 추가

Begin-Loop

# foreach($item in $ips)
# 바로 아래에 추가

if(Is-Blocked $ip)
{
    continue
}

############################################################
# 5분마다 통계 출력
############################################################

if(-not $script:LAST_STAT)
{
    $script:LAST_STAT = Get-Date
}

if(((Get-Date)-$script:LAST_STAT).TotalMinutes -ge 5)
{
    Show-Statistics
    $script:LAST_STAT = Get-Date
}
