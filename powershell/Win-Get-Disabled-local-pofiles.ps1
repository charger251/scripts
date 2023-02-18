$path = 'Registry::HKey_Local_Machine\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*'
$items = Get-ItemProperty -path $path
Foreach ($item in $items) {
    $objUser = New-Object System.Security.Principal.SecurityIdentifier($item.PSChildName) 
            try
    {$objName = $objUser.Translate([System.Security.Principal.NTAccount])}
            catch {}
    $item.PSChildName = $objName.value 
}

$users=$items | Select-Object -Property PSChildName
[array]$list_profiles=$Null

foreach($user in $users){
    $user_check_dupl=$user_for_ad
    $user_for_ad=$user.PSChildName  -replace 'TOPSOFT\\','' 
    $enabled=get-aduser -filter {SamAccountName -eq $user_for_ad} | select Enabled 
        if($enabled.Enabled -eq $false){
            if($user_for_ad -ne $user_check_dupl)
            { $list_profiles+=$user_for_ad}
}
}


