#### Dump every permission from root shares
#### By Futurisiko

# Specify target
Write-Host "`n--- SPECIFY TARGET SVM ---"-ForegroundColor green
Write-Host "e.g. \\fs\`n" -ForegroundColor red
$rootPath = Read-Host

# Run the net view command, capture its output and filter DISK word
$output = net view $rootPath | ForEach-Object { ($_ -split 'Disk')[0] } | ForEach-Object { ($_ -split 'Disco')[0] }

# Filter the output to capture lines after the dashes until "The command completed successfully."
$shares = $output |
    Select-String -Pattern "----" -Context 0, 1000 | # Use Select-String to find the dash line and capture the following lines
    ForEach-Object { $_.Context.PostContext } | # Get the lines following the dash line
    Where-Object { $_ -notmatch "The command completed successfully" } | # Exclude the final line
    Where-Object { $_ -notmatch "Esecuzione comando riuscita" } |
        Where-Object { $_ -match "\S" } | # Filter lines that contain non-whitespace characters
    ForEach-Object { $_.Trim() } # Trim whitespace from each line

# Output the share names
Write-Host "`n--- DISK / SHARES on " -NoNewline -ForegroundColor green
Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
Write-Host " --- `n" -ForegroundColor green
$shares

# Prompt for attribute to look for
Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green
$targetShare = Read-Host
Write-Host " "

# Define the full path
$fullPath = $rootPath + $targetShare

# Check if temp_list is already present and delete it
If (Test-Path "temp_list") {
    Remove-Item "temp_list"
}

# Execute the query and output to file
Get-ChildItem "$fullPath" | ForEach-Object {
    Get-Acl $_.FullName |
    Select-Object -ExpandProperty Access |
    Select-Object FileSystemRights, IdentityReference
} | Out-File "temp_list" -Width 4096

# Read from the file, process it, and display initial results
Get-Content .\temp_list |
    Where-Object { $_ -match "\S" -and $_ -notmatch "FileSystemRights" -and $_ -notmatch "----------------" } |
    Sort-Object |
    Group-Object |
    Select-Object Name, Count |
    ForEach-Object {
        Write-Host "$($_.Name) : $($_.Count)"
    }

# Prompt for deeper analysis
Write-Host "`n--- Wanna go deeper and see more precise output? ---" -ForegroundColor green
$yesno = Read-Host -Prompt "yes / no"
Write-Host " "

# If deeper analysis is confirmed, perform it
If ($yesno -eq 'yes') {
	
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}
	If (Test-Path "outscan.txt") {
		Remove-Item "outscan.txt"
	}
	Write-Host "`n--- PROCESSING --- `n" -ForegroundColor green
    Get-ChildItem "$fullPath" -Recurse | ForEach-Object {
        $_.FullName | Out-File "outscan.txt" -Width 4096 -Append;
		Get-Acl $_.FullName |
        Select-Object -ExpandProperty Access |
        Select-Object FileSystemRights, IdentityReference |
        Out-File "outscan.txt" -Width 4096 -Append;
		"##################################################" | Out-File "outscan.txt" -Width 4096 -Append
        #Start-Sleep -Seconds 1
	}
    Get-Content .\outscan.txt |
		Where-Object { $_ -match "\S" -and $_ -notmatch "FileSystemRights" -and $_ -notmatch "----------------" -and $_ -notmatch "\\\\" } |
		ForEach-Object { $_.Trim() } |
		Sort-Object |
		Group-Object |
		Select-Object Name, Count |
		ForEach-Object {
			Write-Host "$($_.Name) : $($_.Count)"
		};
	Write-Host "`n`n`n--- DONE ! --- `n" -ForegroundColor green
}


