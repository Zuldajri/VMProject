[CmdletBinding()]



Param(
    [string] $VMName, 
    [string] $GuestOSName,
    [string] $StorageAccountName,
    [string] $StorageAccountKey,
    [string] $USERNAME,
    [string] $PASSWORD
 )



#Initialize Data Disks
Get-Disk | ` 
Where partitionstyle -eq 'raw' | ` 
Initialize-Disk -PartitionStyle GPT -PassThru | ` 
New-Partition -AssignDriveLetter -UseMaximumSize | ` 
Format-Volume -FileSystem ReFS -NewFileSystemLabel "datadisk" -Confirm:$false







 
