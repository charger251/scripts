$session = New-SSHSession -ComputerName by01-esxi10.topsoft.local -Credential $shellCreds –AcceptKey

$vm_loc = Get-VMHost -Name by01-esxi09.topsoft.local | get-vm | Select Name, @{N="VMX";E={$_.Extensiondata.Summary.Config.VmPathName}}
foreach($vm in $vm_loc){

$loc_all = $vm.VMX -split (" ")
$vmx = $loc_all[1]
$datastore = Get-VM -Name $vm.Name | Get-Datastore
$cmd_path = "/vmfs/volumes/$datastore/$vmx"
$cmd_path
$cmd ="vim-cmd solo/registervm $cmd_path"

Invoke-SSHCommand -SSHSession $session -Command $cmd
}