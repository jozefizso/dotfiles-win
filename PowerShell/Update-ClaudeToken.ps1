function Update-ClaudeToken {
    <#
    .SYNOPSIS
    Updates the ANTHROPIC_AUTH_TOKEN in Claude settings files with token from 1Password.

    .DESCRIPTION
    Reads the Claude API token from 1Password (op://CLI/Claude Token/password) and updates
    the ANTHROPIC_AUTH_TOKEN in Claude Code settings files for both CLI and VSCode.

    .EXAMPLE
    Update-ClaudeToken
    #>

    [CmdletBinding()]
    param()

    try {
        # Read token from 1Password
        Write-Verbose "Reading token from 1Password..."
        $token = op read "op://CLI/Claude Token/password" 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to read token from 1Password. Make sure you're signed in with 'op signin'"
            return
        }

        if ([string]::IsNullOrWhiteSpace($token)) {
            Write-Error "Retrieved token is empty"
            return
        }

        # Define Claude settings file paths
        $settingsFiles = @(
            # Claude Code CLI settings
            "$env:USERPROFILE\.claude\settings.json"
        )

        $updatedCount = 0

        foreach ($settingsPath in $settingsFiles) {
            if (Test-Path $settingsPath) {
                Write-Verbose "Updating settings file: $settingsPath"

                try {
                    # Read existing settings
                    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

                    # Update or add the token
                    if ($null -eq $settings.ANTHROPIC_AUTH_TOKEN) {
                        $settings | Add-Member -NotePropertyName "ANTHROPIC_AUTH_TOKEN" -NotePropertyValue $token -Force
                    } else {
                        $settings.ANTHROPIC_AUTH_TOKEN = $token
                    }

                    # Write back to file with proper formatting
                    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

                    Write-Host "✓ Updated: $settingsPath" -ForegroundColor Green
                    $updatedCount++
                }
                catch {
                    Write-Warning "Failed to update $settingsPath : $_"
                }
            }
            else {
                Write-Verbose "Settings file not found: $settingsPath"
            }
        }

        if ($updatedCount -eq 0) {
            Write-Warning "No Claude settings files found. Files checked:"
            $settingsFiles | ForEach-Object { Write-Warning "  - $_" }
        }
        else {
            Write-Host "`nSuccessfully updated $updatedCount settings file(s)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}
