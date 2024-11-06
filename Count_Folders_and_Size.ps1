### 
# Conta numero Folders e peso totale files
###

Write-Host "`n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/"
Write-Host "CoNtA tOtAlE nUmErO fOlDeR e PeSo ToTaLe FiLe"
Write-Host "/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/`n"

#Conta folders
$folderPath = Read-Host -prompt "Root Folder Path";
$folders = Get-ChildItem -Path $folderPath -Recurse -Directory;
Write-Host "`nConta totale folder";
$folders.Count;
Write-Host " ";

#Conta size
$bytes = Get-ChildItem -Path $folderPath -File -Recurse | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
$megabytes = $bytes / 1MB; $gigabytes = $bytes / 1GB;
Write-Host "Size totale in MB = " -NoNewLine;
$megabytes
Write-Host "Size totale in GB = " -NoNewLine;
$gigabytes
Write-Host " ";