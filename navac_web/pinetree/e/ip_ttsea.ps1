# =====================================
# NAVac IP Monitor + Auto Block
# Windows PowerShell Version
# =====================================

$LOG_FILE = ".\exip_watch.log"

# 설정
$THRESHOLD = 10
$BLOCK_TIME = 600
$ENABLE_BLOCK = $true

# 화이트리스트
$MY_PUBLIC_IP = curl.exe -s https://ifconfig.me
$WHITELIST = @(
    "127.0.0.1",
    "::1",
    $MY_PUBLIC_IP
)

$BLOCKED = @{}

function Write-Log($msg)
{
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time $msg" | Tee-Object -FilePath $LOG_FILE -Append
}


function Is-WhiteList($ip)
{
    return $WHITELIST -contains $ip
}


function Block-IP($ip)
{
    if(Is-WhiteList $ip)
    {
        return
    }

    $rule = "NAVac_BLOCK_$ip"

    if(!(Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue))
    {
        New-NetFirewallRule `
        -DisplayName $rule `
        -Direction Inbound `
        -RemoteAddress $ip `
        -Action Block `
        -Profile Any

        $BLOCKED[$ip] = Get-Date

        Write-Log "🚫 BLOCKED : $ip"
    }
}


function Remove-ExpiredBlock
{
    foreach($ip in @($BLOCKED.Keys))
    {
        $diff =
        (New-TimeSpan `
        -Start $BLOCKED[$ip] `
        -End (Get-Date)).TotalSeconds


        if($diff -gt $BLOCK_TIME)
        {
            Remove-NetFirewallRule `
            -DisplayName "NAVac_BLOCK_$ip" `
            -ErrorAction SilentlyContinue


            $BLOCKED.Remove($ip)

            Write-Log "✅ UNBLOCK : $ip"
        }
    }
}



Write-Log "📡 NAVac IP Monitor Start"
Write-Log "MY IP : $MY_PUBLIC_IP"



while($true)
{

Write-Log "-----------------------------"


# 시간
$MOSCOW =
[System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(
(Get-Date),
"Russian Standard Time"
)

$GMT =
(Get-Date).ToUniversalTime()


Write-Log "MOSCOW : $MOSCOW"
Write-Log "GMT    : $GMT"



# Windows TCP 연결

$connections =
Get-NetTCPConnection |
Where-Object {

    $_.State -eq "Established" -and
    $_.RemoteAddress -notmatch "^(0\.|127\.|::1)"

}



$ips =
$connections |
Select-Object -ExpandProperty RemoteAddress |
Where-Object {
$_ -match "^\d+\.\d+\.\d+\.\d+$"
} |
Group-Object



foreach($item in $ips)
{

$ip=$item.Name
$count=$item.Count


Write-Log "🌐 IP : $ip COUNT : $count"


# 위치정보

try {

$geo =
curl.exe -s --max-time 2 `
"https://ipinfo.io/$ip"


Write-Log "📍 GEO : $geo"

}
catch
{
}



if(
$ENABLE_BLOCK -eq $true `
-and $count -ge $THRESHOLD
)
{
Block-IP $ip
}


}


Remove-ExpiredBlock


Start-Sleep -Seconds 5

}
