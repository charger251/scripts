$sw= Get-Content c:\scripts\network_devices\switch\sw.csv
$n_days=90
$limit = (Get-Date).AddDays(-$n_days)
$time=Get-Date -Format g | foreach {$_ -replace ":", "."} | foreach {$_ -replace " ", "_"}

$Logfile=".\switch_bak.log"

$secpasswd = ConvertTo-SecureString 01000000d08c9ddf0115d1118c7a00c04fc297eb01000000703463b8faa90b41a0f708223cbc365d0000000002000000000003660000c0000000100000004357ee62a805ab0635886ddf2a91538f0000000004800000a0000000100000000f88a5b93ad632f7263503cb7c191ffb2800000029bfc35c0e6e7baa7cff899cf0dffe42e4d56a6d4606976f6f8dd1ebd5da76e3c96a9d1b05dd51cd140000003df26032495b618d43312e2d01aaade58c8b014d
$creds = New-Object System.Management.Automation.PSCredential ("readonly", $secpasswd)
[string]$name

Import-Module Posh-SSH

$err_count=0
$i=0 

while($sw[$i] -gt 0){

try {
New-SSHSession -ComputerName $sw[$i] -Credential $creds -AcceptKey
Start-Sleep 10
$session = Get-SSHSession -Index 0
$stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
$stream.Write("   terminal length 0`n")
$stream.Write("show startup-config`n")
Start-Sleep 10
$name=$sw[$i]+'_'+$time
$p=$sw[$i]
$out="\\by01-bak01\Backup\network_devices\switch\$p\$name.txt"
$stream.Read() > $out 
Remove-SSHSession -Index 0



} catch {

$time + "---------------SSHSession----------"+"hostname: " + $sw[$i] + "----------------" >> $Logfile
$error |  Out-File $Logfile -Append
"---------------------------------------------------------------------------">> $Logfile
$error.Clear()
$err_count=$err_count+1

}

# Delete files older than the $limit
$path = "\\by01-bak01\Backup\network_devices\switch\$p"
$fileCount = (Get-ChildItem $path).Count

if($fileCount -gt $n_days){
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force}


$i++

}

if($err_count -gt 0){exit 1}