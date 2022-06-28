[CmdletBinding()]



Param(
    [string] $VMName, 
    [string] $GuestOSName,
    [string] $StorageAccountName,
    [string] $StorageAccountKey,
    [string] $USERNAME,
    [string] $PASSWORD
 )

$osDrive = ((Get-WmiObject Win32_OperatingSystem).SystemDrive).TrimEnd(":")
$size = (Get-Partition -DriveLetter $osDrive).Size
$maxSize = (Get-PartitionSupportedSize -DriveLetter $osDrive).SizeMax
if ($size -lt $maxSize){
     Resize-Partition -DriveLetter $osDrive -Size $maxSize
}

#Initialize Data Disks
Get-Disk | ` 
Where partitionstyle -eq 'raw' | ` 
Initialize-Disk -PartitionStyle GPT -PassThru | ` 
New-Partition -AssignDriveLetter -UseMaximumSize | ` 
Format-Volume -FileSystem ReFS -NewFileSystemLabel "datadisk" -Confirm:$false







 
