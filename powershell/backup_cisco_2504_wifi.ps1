$wlc= Import-Csv C:\scripts\network_devices\wlc\wlc.csv
$n_days=90
$limit = (Get-Date).AddDays(-$n_days)
$time=Get-Date -Format g | foreach {$_ -replace ":", "."} | foreach {$_ -replace " ", "_"}

$Logfile=".\wlc_bak.log"

$secpasswd = ConvertTo-SecureString 01000000d08c9ddf0115d1118c7a00c04fc297eb01000000703463b8faa90b41a0f708223cbc365d0000000002000000000003660000c00000001000000022210f464455a071d451727d039d41720000000004800000a000000010000000cb1cc3173145817fb57151a981ba3cf428000000deb3b88246c9767e5c1aa6041002d02760bcc0b17b54e4936ec27c5cecaf784edeafc51a528a59a614000000c5bb37b553ad6ca63b2d4ea59d9b80ef28df8de5
$creds = New-Object System.Management.Automation.PSCredential ("by01.backup.wlc", $secpasswd)

$out="C:\scripts\network_devices\wlc\temp"

$s_err_count=0
$n=0
$host_count=$wlc.Count

while($n -lt $host_count){

$err_count=0
$name=$wlc[$n].host
$ip=$wlc[$n].ip

#Generation of the command "show run-config commands" output to the file
try {
New-SSHSession -ComputerName $ip -Credential $creds -AcceptKey
Start-Sleep 10
$session = Get-SSHSession -Index 0
$stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
$stream.Write("by01.backup.wlc`n")
Start-Sleep 2
$stream.Write("2Oef4r8EYSWrqG5E`n")
Start-Sleep 5
$stream.Write("show run-config commands`n")
Start-Sleep 5
$stream.Read() > "$out\temp.txt"
Start-Sleep 2
} catch {

$time + "---------------SSHSession----------"+"hostname: " + $wlc[$n] + "----------------" >> $Logfile
$error |  Out-File $Logfile -Append
"---------------------------------------------------------------------------">> $Logfile
$error.Clear()
$err_count=$err_count+1

}
$chk=0
$i=1

if($err_count -eq 0){
while($chk -eq 0){
$stream.Write(" `n")
Start-Sleep 1
$tmp=$stream.Read()
if($tmp.Length -ne 376){
$tmp >> "$out\temp.txt"}
else {$chk=$chk+1}
}
}



if($err_count -eq 0){
try {
#processing of lines and sending the file
$folder="$time-$name"
mkdir \\by01-bak01.topsoft.local\Backup\network_devices\wlc\$name\$folder
get-content $out\temp.txt |where {$_.Length -ne 0} | select-string -pattern '--More--' -notmatch | select-string -pattern 'Cisco Controller' -notmatch | select-string -pattern 'User:' -notmatch | select-string -pattern 'Password:' -notmatch | Out-File \\by01-bak01.topsoft.local\Backup\network_devices\wlc\$name\$folder\$folder-run-commands.txt
} catch {

$time + "---------------Error sending file----------"+"hostname: " + $wlc[$n] + "----------------" >> $Logfile
"hostname: " + "\\by01-bak01.topsoft.local\Backup\network_devices\wlc\$name\$folder\$folder-run-commands.txt" >> $Logfile
$error |  Out-File $Logfile -Append
"---------------------------------------------------------------------------">> $Logfile
$error.Clear()
$err_count=$err_count+1

}

#Generation of the command "show run-config startup-commands" output to the file
$stream.Write("show run-config startup-commands`n")
Start-Sleep 20
$stream.Read() > "$out\temp2.txt"
Start-Sleep 2

$chk=0
$i=1

while($chk -eq 0){
$stream.Write(" `n")
Start-Sleep 1
$tmp=$stream.Read()
if($tmp.Length -ne 376){
$tmp >> "$out\temp2.txt"}
else {$chk=$chk+1}
}

try {
#processing of lines and sending the file
get-content $out\temp2.txt |where {$_.Length -ne 0} | select-string -pattern '--More--' -notmatch | select-string -pattern 'Cisco Controller' -notmatch | select-string -pattern 'User:' -notmatch | select-string -pattern 'Password:' -notmatch | Out-File \\by01-bak01\Backup\network_devices\wlc\$name\$folder\$folder-startup-commands.txt
} catch {

$time + "---------------Error sending file----------"+"hostname: " + $wlc[$n] + "----------------" >> $Logfile
"hostname: " + "\\by01-bak01\Backup\network_devices\wlc\$name\$folder\$folder-startup-commands.txt" >> $Logfile
$error |  Out-File $Logfile -Append
"---------------------------------------------------------------------------">> $Logfile
$error.Clear()
$err_count=$err_count+1

}

Remove-SSHSession -Index 0

# Delete files older than the $limit
$path = "\\by01-bak01\Backup\network_devices\wlc\$name"
$fileCount = (Get-ChildItem $path).Count

if($fileCount -gt $n_days){
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force}
}

if($err_count -gt 0){$s_err_count=$err_count+1}

$n=$n+1

Start-Sleep 120

}

if($s_err_count -gt 0){exit 1}