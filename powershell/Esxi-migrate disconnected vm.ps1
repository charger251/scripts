$session = New-SSHSession -ComputerName by01-esxi08.topsoft.local -Credential $shellCreds –AcceptKey


$loc = Get-VM -Name by01-app68 | Select Name, @{N="VMX";E={$_.Extensiondata.Summary.Config.VmPathName}}
$loc_all = $loc.VMX -split (" ")
$vmx = $loc_all[1]
$datastore = Get-VM -Name by01-app68 | Get-Datastore
$cmd_path = "/vmfs/volumes/$datastore/$vmx"



$cmd ="vim-cmd solo/registervm $cmd_path"
Invoke-SSHCommand -SSHSession $session -Command $cmd


get-vmhost by01-esxi08.topsoft.local |Get-VM  | Get-VMQuestion | Set-VMQuestion -Option button.uuid.movedTheVM -Confirm:$false