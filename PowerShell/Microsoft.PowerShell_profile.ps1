#
# PowerShell User Profile
#

pwsh.exe -version

$pure = $PSScriptRoot + '\pure.omp.json'
oh-my-posh init --config $pure pwsh | Invoke-Expression
