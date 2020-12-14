#!/usr/bin/env pwsh

function wait_update($filepattern) {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $PSScriptRoot
    $watcher.Filter = "$filepattern"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  
    $changeResult = $watcher.WaitForChanged([IO.WatcherChangeTypes]::All, 1000)
    $updated = (!$changeResult.TimedOut)
    return $updated
}

function update_on_test_succeded() {
    if ("$(git status --porcelain)" -eq "") {
        return
    }
    git add -A | Out-Null
    git commit
    . "./publish/4_test.ps1"
}

$count = 0
while ($true) {
    $count += 1
    Clear-Host
    Write-Host "[#$("{0:04}" -f $count)] @$(get-date -UFormat "%Y/%m/%d %H:%M:%S")"
    python -m pytest
    $test_success = $?
    if ($test_success) {
        update_on_test_succeded
    }
    Start-Sleep -s 1
    $updated = $false
    while (!$updated) {
        $updated = wait_update "*.py"
    }
    if ($test_success) {
        update_on_test_succeded
    }
}
