<#
.SYNOPSIS
	Installs Backup Exec on VM Image
.DESCRIPTION
	Copies a blob from one storage accout to another
.PARAMETER UserName 
	UserName - Secure String with UserName
.PARAMETER UserPass
	UserPass - Secure string with userPass
.PARAMETER InstallPackage
	InstallPackage - Opt1 (basic standalone media server) or Opt2 (CASO with Dedupe)
.NOTE
    Redeployments will not change the user/password.
.DISCLAIMER
	This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
    We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object
    code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software
    product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the
    Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims
    or lawsuits, including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
    Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained
    within the Premier Customer Services Description.
#>

[CmdletBinding()]
param
(
	[Parameter(Mandatory=$true)]
	[string]$UserName,

	[Parameter(Mandatory=$true)]
	[string]$Password,

	[Parameter(Mandatory=$true)]
	[string]$InstallPackage

)

#Initialize Data Disks
Get-Disk | ` 
Where partitionstyle -eq 'raw' | ` 
Initialize-Disk -PartitionStyle GPT -PassThru | ` 
New-Partition -AssignDriveLetter -UseMaximumSize | ` 
Format-Volume -FileSystem ReFS -NewFileSystemLabel "datadisk" -Confirm:$false

$beDefSettings = "/S: /DOCS: /TRIAL:"
$beSetupExeCmd = "C:\BE_DVD\BE\WinNT\Install\BEx64\Setup.exe"

try
{
	Write-Host "<<<<<<<<<<Script Started>>>>>>>>>>"

	$SrvName = $env:COMPUTERNAME
	$BEUSER = "/USER:$UserName"
	$BEPASS = "/PASS:$Password"
	$BEDom = "/DOM:$SrvName"
	$DBServerValue = "/DBSERVER:$SrvName\BKUPEXEC"

	Write-Verbose "DefSettings:    $beDefSettings"
	Write-Verbose "HostName:       $SrvName"
	Write-Verbose "UserName:       $UserName"
	Write-Verbose "Password:       $Password"
	Write-Verbose "UserDom:        $UserDom"
	Write-Verbose "DBSERVER:       $DBServerValue"
	Write-Verbose "InstallPackage: $InstallPackage"
	Write-Verbose ""
	
	switch ($InstallPackage)
	{
		"Opt1" { $BEInstallFeatures = " /VIRT: /APPLICATIONS:" }
		"Opt2" { $BEInstallFeatures = " /VIRT: /APPLICATIONS: /CASO: /DEDUPE:" }
		default { $BEInstallFeatures = "" }
	}

	# start the install using the specified settings...
	$beArgs = "$beDefSettings $BEUSER $BEPASS $BEDom $DBServerValue $BEInstallFeatures"
	Write-Verbose "$beSetupExeCmd $beArgs -Wait"
	Start-Process -FilePath $beSetupExeCmd -ArgumentList $beArgs -Wait
	
	Write-Host "<<<<<<<<<<Script Finished>>>>>>>>>>"
}
catch
{
	Write-host "An error ocurred: $_"
	#"An error ocurred: $_" | Out-File "c:\$scriptName.txt" -Append
}
