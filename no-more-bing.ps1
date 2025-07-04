function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-GroupPolicySupport {
    $gpeditPath = Join-Path $env:SystemRoot "System32\gpedit.msc"
    return Test-Path $gpeditPath
}

$SearchEngineConfigs = @{
    "Google"     = @{ "name" = "Google"; "keyword" = "g"; "search_url" = "https://www.google.com/search?q={searchTerms}"; "suggest_url" = "https://www.google.com/complete/search?client=chrome&q={searchTerms}" };
    "Bing"       = @{ "name" = "Bing"; "keyword" = "b"; "search_url" = "https://www.bing.com/search?q={searchTerms}"; "suggest_url" = "https://www.bing.com/osjson.aspx?query={searchTerms}" };
    "DuckDuckGo" = @{ "name" = "DuckDuckGo"; "keyword" = "d"; "search_url" = "https://duckduckgo.com/?q={searchTerms}"; "suggest_url" = "https://duckduckgo.com/ac/?q={searchTerms}&type=list" };
    "Baidu"      = @{ "name" = "Baidu"; "keyword" = "bd"; "search_url" = "https://www.baidu.com/s?wd={searchTerms}"; "suggest_url" = "https://suggestion.baidu.com/su?wd={searchTerms}" };
}
$EdgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

function Lock-SearchEngine([string]$SelectedEngine) {
    $config = $SearchEngineConfigs[$SelectedEngine]
    Write-Host "Locking search engine to: $($config.name) using policy" -ForegroundColor Green
    
    if (-not (Test-Path $EdgePolicyPath)) { New-Item -Path $EdgePolicyPath -Force | Out-Null }
    
    try {
        $oldPolicyNames = "DefaultSearchProviderName", "DefaultSearchProviderSearchURL", "DefaultSearchProviderSuggestURL"
        foreach ($p in $oldPolicyNames) { Remove-ItemProperty -Path $EdgePolicyPath -Name $p -ErrorAction SilentlyContinue }

        $mspJson = @"
[
  {
    "name": "$($config.name)",
    "keyword": "$($config.keyword)",
    "search_url": "$($config.search_url)",
    "suggest_url": "$($config.suggest_url)",
    "is_default": true 
  }
]
"@
        
        Set-ItemProperty -Path $EdgePolicyPath -Name "ManagedSearchEngines" -Value $mspJson -Type String -Force
        Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderEnabled" -Value 1 -Type DWord -Force
        Write-Host "Group Policy settings applied successfully!" -ForegroundColor Green
        
        Write-Host "Forcing Group Policy update..." -ForegroundColor Yellow
        gpupdate /force | Out-Null
        
        Write-Host "`n=== Lock Complete ===" -ForegroundColor Green
        Write-Host "Please completely close Edge (including the icon in the system tray) and restart it for the new policy to take effect." -ForegroundColor Cyan
        
    } catch {
        Write-Host "Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Unlock-SearchEngine {
    Write-Host "Unlocking Edge search engine settings safely..." -ForegroundColor Green
    if (-not (Test-Path $EdgePolicyPath)) { Write-Host "Edge policy path not found, no unlock needed." -ForegroundColor Yellow; return }
    
    $policyNamesToRemove = @("ManagedSearchEngines", "DefaultSearchProviderEnabled", "DefaultSearchProviderName", "DefaultSearchProviderSearchURL", "DefaultSearchProviderSuggestURL")
    
    Write-Host "Precisely removing all related policies..." -ForegroundColor Cyan
    foreach ($policyName in $policyNamesToRemove) {
        if (Get-ItemProperty -Path $EdgePolicyPath -Name $policyName -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $EdgePolicyPath -Name $policyName -Force
            Write-Host "  [Removed] $policyName" -ForegroundColor Gray
        }
    }
    
    Write-Host "Forcing Group Policy update..." -ForegroundColor Yellow
    gpupdate /force | Out-Null
    Write-Host "`n=== Precise Unlock Complete ===" -ForegroundColor Green
}

function Get-LockStatus {
    Write-Host "`n--- Current Lock Status Check ---" -ForegroundColor Cyan
    if (-not (Test-Path $EdgePolicyPath)) {
        Write-Host "Status: Unlocked (No Edge policies found)" -ForegroundColor Green
        return
    }
    
    $managedPolicy = Get-ItemProperty -Path $EdgePolicyPath -Name "ManagedSearchEngines" -ErrorAction SilentlyContinue
    $enabledPolicy = Get-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderEnabled" -ErrorAction SilentlyContinue

    if ($managedPolicy -and $enabledPolicy -and ($enabledPolicy.DefaultSearchProviderEnabled -eq 1)) {
        try {
            $json = $managedPolicy.ManagedSearchEngines | ConvertFrom-Json
            $defaultEngine = $json | Where-Object { $_.is_default -eq $true } | Select-Object -First 1
            if ($defaultEngine) {
                Write-Host "Status: Locked" -ForegroundColor Green
                Write-Host "Current Default Search Engine: $($defaultEngine.name)" -ForegroundColor Yellow
            } else {
                Write-Host "Status: Incomplete Configuration (List defined, but no default specified)" -ForegroundColor Magenta
            }
        } catch {
            Write-Host "Status: Configuration Error (ManagedSearchEngines content is not valid JSON)" -ForegroundColor Magenta
        }
    } else {
        Write-Host "Status: Unlocked" -ForegroundColor Red
        Write-Host "Other policies may exist, but default search engine lock is not enabled." -ForegroundColor Gray
    }
    Write-Host "-------------------------" -ForegroundColor Cyan
}

function Show-LockSubMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Please select a search engine to lock ---" -ForegroundColor Cyan
        
        $engineKeys = $SearchEngineConfigs.Keys | Sort-Object
        for ($i = 0; $i -lt $engineKeys.Count; $i++) {
            Write-Host "  [$($i+1)] $($engineKeys[$i])"
        }
        Write-Host "  [B] Back to Main Menu" -ForegroundColor Yellow
        Write-Host "-----------------------------" -ForegroundColor Cyan
        
        $choice = Read-Host "Please enter your choice"
        
        if ($choice -eq 'B' -or $choice -eq 'b') {
            return $null
        }
        
        if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $engineKeys.Count) {
            return $engineKeys[[int]$choice - 1]
        } else {
            Write-Host "`nInvalid input. Press Enter to try again..." -ForegroundColor Red
            Read-Host
        }
    }
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host "======================================" -ForegroundColor Cyan
        Write-Host "             No More Bing"
        Write-Host "======================================" -ForegroundColor Cyan
        Write-Host
        Write-Host "  [1] Lock Default Search Engine"
        Write-Host "  [2] Unlock Default Search Engine"
        Write-Host "  [3] Check Current Lock Status"
        Write-Host
        Write-Host "  [Q] Exit Script" -ForegroundColor Yellow
        Write-Host
        
        $choice = Read-Host "Please select an option [1, 2, 3, Q]"
        
        switch ($choice) {
            '1' {
                $selectedEngine = Show-LockSubMenu
                if ($selectedEngine) {
                    Clear-Host
                    Lock-SearchEngine -SelectedEngine $selectedEngine
                    Read-Host "`nOperation complete. Press Enter to return to the main menu..."
                }
            }
            '2' {
                Clear-Host
                Unlock-SearchEngine
                Read-Host "`nOperation complete. Press Enter to return to the main menu..."
            }
            '3' {
                Clear-Host
                Get-LockStatus
                Read-Host "`nPress Enter to return to the main menu..."
            }
            'Q' {
                Write-Host "Exiting..." -ForegroundColor Yellow
                return
            }
            default {
                Write-Host "`nInvalid input. Press Enter to try again..." -ForegroundColor Red
                Read-Host
            }
        }
    }
}

if (-not (Test-Administrator)) { Write-Host "`nError: Administrator privileges required. Please run the powershell as administrator'." -ForegroundColor Red; Read-Host; exit }
if (-not (Test-GroupPolicySupport)) { Write-Host "`nWarning: Group Policy is not supported on this system. The script cannot continue." -ForegroundColor Red; Read-Host; exit }

Show-MainMenu
