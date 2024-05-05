param([switch]$elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Show-PressAnyKeyToExit {
    Write-Host -NoNewLine 'Press any key to exit...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    (Get-Host).SetShouldExit(0)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        "`nUnable to run PowerShell in Administrator Mode"
        Show-PressAnyKeyToExit
    } else {
        Start-Process pwsh -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'Running Powershell in Administrator Mode...'
Stop-Process -Name PowerToys.KeyboardManagerEngine
"`nSTOPPED --- process PowerToys.KeyboardManagerEngine ---"

$path = $HOME+"\AppData\Local\Microsoft\PowerToys\Keyboard Manager"
Set-Location "$path"
$file = 'keyboard-magic.json'
Copy-Item $file default.json
"`nUsing file: $path\$file"

$kbm = Get-Process PowerToys.KeyboardManagerEngine -ErrorAction SilentlyContinue
if ($kbm) {
    Stop-Process -Name PowerToys.KeyboardManagerEngine
    "`nSTOPPED --- process PowerToys.KeyboardManagerEngine ---"
} else {
    Start-Process -FilePath 'C:\Program Files\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe'
    "`nSTARTED --- process PowerToys.KeyboardManagerEngine ---"
}

Show-PressAnyKeyToExit
