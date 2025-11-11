#
# PowerShell User Profile
#

# Alias for easier navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }


# Run the profile
pwsh.exe -version

$pure = $PSScriptRoot + '\pure.omp.json'
oh-my-posh init --config $pure pwsh | Invoke-Expression
