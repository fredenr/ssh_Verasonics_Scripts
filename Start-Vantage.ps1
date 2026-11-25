$ErrorActionPreference = 'Stop'
$remote = @'
$ErrorActionPreference = 'Stop'
$d = 'C:\Users\Administrator\Documents\Vantage-Matlab-Helper'
$r = 'C:\Users\Administrator\Documents\Vantage-4.9.6-2502061500'
$n = 'UTA64_LEMO_RealTime_Abdomen_Tomography'
$s = Join-Path $r "Example_Scripts\CustomScripts\$n.m"
if (!(Test-Path -LiteralPath $s)) { throw "Missing setup: $s" }
$t = Get-ScheduledTask -TaskName 'Vantage-MATLAB-Submit'
if ($t.State -ne 'Ready') { throw "Helper task state: $($t.State)" }
$l = Join-Path $d ('vsx-' + (Get-Date -Format yyyyMMdd-HHmmss) + '.log')
$c = "diary('$l'); try, cd('$r'); activate; run('$s'); filename='MatFiles/$n.mat'; VSX; catch err, disp(getReport(err,'extended','hyperlinks','off')); end; diary off"
Set-Content -LiteralPath "$d\command.txt" -Value $c -Encoding ascii -NoNewline
Start-ScheduledTask -InputObject $t
"Submitted to AutoHotkey. Check the server log: $l"
'@
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
& ssh -F "$PSScriptRoot\vantage.sshconfig" -o BatchMode=yes -o ConnectTimeout=5 -o "UserKnownHostsFile=$PSScriptRoot\vantage_known_hosts" -o StrictHostKeyChecking=yes vantage powershell.exe -NoProfile -EncodedCommand $encoded
if ($LASTEXITCODE -ne 0) { throw "Submission failed (SSH exit $LASTEXITCODE)." }
