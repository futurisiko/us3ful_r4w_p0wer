#### Dump generic users permissions
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
Write-Host "`n--- Start the dump ? ---`n" -ForegroundColor green
$start = Read-Host
Write-Host " "

# Execute the query and output to file
$ErrorActionPreference = "silentlycontinue"
$shares | ForEach-Object { $fullpath = $rootPath + $_ ; Get-ChildItem "$fullpath" } | 
Where-Object { Get-Acl $_.FullName | Select-Object -ExpandProperty Access | 
    Where-Object { $_.IdentityReference -match 'Users' } } | 
ForEach-Object { Write-Host $_.FullName -ForegroundColor green; Get-Acl $_.FullName | 
    Select-Object -ExpandProperty Access | 
    Where-Object { $_.IdentityReference -match 'Users' } | 
    Select-Object FileSystemRights, IdentityReference} | 
FL 2>$null
