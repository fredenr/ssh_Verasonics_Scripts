$ErrorActionPreference = 'Stop'
$remote = @'
whoami
query user
tasklist /fi "IMAGENAME eq MATLAB.exe"
schtasks /query /tn Vantage-MATLAB-Submit /fo LIST
'@
& ssh -F "$PSScriptRoot\vantage.sshconfig" -o BatchMode=yes -o ConnectTimeout=5 -o "UserKnownHostsFile=$PSScriptRoot\vantage_known_hosts" -o StrictHostKeyChecking=yes vantage ($remote -replace '\r?\n', ' & ')
if ($LASTEXITCODE -ne 0) { throw "Connection check failed (SSH exit $LASTEXITCODE)." }
