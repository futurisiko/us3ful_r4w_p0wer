####################################################################
#
#	Remove permissions Recursevely
#	Usign icacls and powershell
#
#	Nk aka Futu
#
####################################################################

# Clear screen
cls


######### Banner and user inputs #########

# Specify targets
Write-Host "`n################################################################################" -ForegroundColor blue
Write-Host "REMOVE RECURSEVELY ALL ASSIGNED PERMISSIONS TO A TARGET GROUP/USER" 
Write-Host " "
Write-Host "Nk aka Futu"
Write-Host "################################################################################`n" -ForegroundColor blue
Write-Host "--- SPECIFY TARGET PATH ---"-ForegroundColor green
Write-Host "e.g. \\fs\folderX\ or C:\folder\" -ForegroundColor yellow
Write-Host "`n!!! Attention !!! The script will disable inheritance for the given PATH !!!`n" -ForegroundColor red
$rootPath = Read-Host

Write-Host "`n--- SPECIFY TARGET USER/GROUP ---" -ForegroundColor green
Write-Host "e.g. BUILTIN\Users `n" -ForegroundColor yellow
$userTarget = Read-Host

# Validate inputs
Write-Host "`n--- VALIDATE GIVEN INPUTS ---" -ForegroundColor green
Write-Host "PATH specified = " -NoNewLine 
Write-Host $rootPath -ForegroundColor green
Write-Host "Target GROUP/USER specified = " -NoNewLine
Write-Host $userTarget -ForegroundColor green

# Start confirmation
Write-Host "`n--- ??? Wanna procede ??? ---" -ForegroundColor green
Write-Host "Answer YES or NO`n"  -ForegroundColor yellow
$confirmation = Read-Host


######### Start operations #########

# Check if the user confirmed with 'YES'
if ($confirmation -eq 'YES') {
	
	# Remove inheritance 
	Write-Host "`n######### Removing inheritance for root path #########`n" -ForegroundColor green
	
	$root = Get-Item -Path $rootPath
	$acl = Get-Acl $root.FullName
	$inheritedRules = $acl.Access | Where-Object { $_.IsInherited -eq $true }
	$acl.SetAccessRuleProtection($true, $true)
	Set-Acl -Path $root.FullName -AclObject $acl

	# Remove target permission's group/user from root path 
	Write-Host "`n######### Removing target group/users inherited permissions #########`n" -ForegroundColor green
	icacls.exe $rootPath /remove $userTarget 
	
	# Remove target permission's group/user recursevely if there are explicit permissions
	Write-Host "`n######### Removing possible explicit permissions left recursevely #########`n" -ForegroundColor green
	icacls.exe $rootPath /remove $userTarget /T
	
	Write-Host "`n######### Job done \m/ #########`n" -ForegroundColor green	
	
} else {

	# If no confirmation end the loop
    Write-Output "Operation cancelled by user."
	exit
	
}