$SLABOOFSERVICEURL = "http://go.microsoft.com/fwlink/p/?LinkID=290903"
$SLABOOPSERVICEZIP = "$env:temp\SemanticLogging-service.exe"

# Download the package
Invoke-WebRequest -uri $SLABOOFSERVICEURL -OutFile $SLABOOPSERVICEZIP

Unblock-File $SLABOOPSERVICEZIP

$current = (Get-Location).Path
$APPROOT = Join-Path -Path $current -ChildPath "\..\..\approot"
$APPROOTDIR = Get-Item $APPROOT

$SLABDESTINATION = Join-Path -Path  $APPROOTDIR.FullName -ChildPath "\SLAB"

New-Item -ItemType directory $SLABDESTINATION -ErrorAction SilentlyContinue

.$SLABOOPSERVICEZIP /Q /C /T:$SLABDESTINATION

$ZIPFILENAME = Join-Path -Path $SLABDESTINATION -ChildPath "Enterprise Library Semantic Logging Service.zip"

# Wait till copy of the files is complete.
Start-Sleep -s 30

$ZIPFILE = Get-Item $ZIPFILENAME
#-ErrorAction SilentlyContinue

Write-Output "Get-Item $ZIPFILENAME -ErrorAction SilentlyContinue"

Write-Output "zipfile "

$ZIPFILE

if ($ZIPFILE -eq $null)
{
    Write-Output "Cannot file the zip file, exiting."
	return
}

# Unzip
$helper = New-Object -ComObject Shell.Application
$files = $helper.NameSpace($ZIPFILE.FullName).Items()
$helper.NameSpace((Get-Item $SLABDESTINATION).FullName).CopyHere($files)

# Install

$INSTALLPACKAGESFILENAME = $SLABDESTINATION + "\install-packages.ps1"
$NEWINSTALLPACKAGESFILENAME = $SLABDESTINATION + "\new-install-packages.ps1"

# Remove the ReadLine line in the uppacked script.
(Get-Content $INSTALLPACKAGESFILENAME) |  Where-Object {$_ -notlike "*ReadLine*"} | Set-Content $NEWINSTALLPACKAGESFILENAME

.($NEWINSTALLPACKAGESFILENAME) -autoAcceptTerms

$CONFIGFILENAME = "SemanticLogging-svc.xml"

if (Test-Path $APPROOT\$CONFIGFILENAME)
{
	if (Test-Path $SLABDESTINATION\$CONFIGFILENAME)
	{
		Remove-Item $SLABDESTINATION\$CONFIGFILENAME
	}

	if ($NEWCONFIGFILE -ne "")
	{
		Copy-Item $APPROOT\$CONFIGFILENAME -Destination $SLABDESTINATION\$CONFIGFILENAME
	}
}

# Start the service
.$("$SLABDESTINATION\SemanticLogging-svc.exe") -start 