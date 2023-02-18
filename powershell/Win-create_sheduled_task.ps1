$time = (Get-date).AddDays(14)

$Trigger= New-ScheduledTaskTrigger -Once -At "$time" -RandomDelay $DELAY


$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\PS\StartupScript.ps1"
Register-ScheduledTask -TaskName "StartupScript_PS22" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force