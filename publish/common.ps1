#!/usr/bin/env pwsh

function require_file ($filepath) {
    $exists = (Test-Path $filepath)
    if (!$exists) {
        Write-Error "'${version_fiepath}' not found"
        exit
    }
}

function grep ($finding, $filepath) {
    $result = ( `
        (Get-Content $setuppy_filepath) | `
        ForEach-Object {$i++; "L$($i-1):$_"} | `
        Select-String $finding `
        )
    if ($result -eq $null) {
        Write-Host "not found: '$finding'"
        return $false
    } else {
        Write-Host "found:"
        Write-Host "$result"
        Write-Host
        return $true
    }
}

function update_version($measure) {
    # 1. Conduct pytest (exit on error)
    Clear-Host
    python -m pytest
    if (! $?) {
        Write-Error "Failed on pytest."
        return $result
    }

    # 2. Check uncommitted files (exit if exist)
    if ("$(git status --porcelain)" -ne "") {
        Write-Error (
            "Uncommited files exist. " +
            "Commit all files before an update."
        )
        git status --porcelain
        return 1 | Out-Null
    }

    # 3. Check old version is consistent to setup.py (exit on error)
    $old_version = (Get-Content $version_filepath | Select-Object -First 1)
    $found = grep "version='${old_version}'" $setuppy_filepath
    if (-not $found) {
        Write-Host "Inconsitent versioning found."
        return 1 | Out-Null
    }

    # 4. Calculate new version by incrementing specified verison
    $ver_list = $old_version.Split(".")
    $ver_list[$measure] = [int]$ver_list[$measure] + 1
    for ($i=$measure+1; $i -lt 4; $i++) {
        $ver_list[$i] = 0
    }
    $new_version = ($ver_list -join ".")

    # 5. Update version and setup.py, and git push
    Write-Output $new_version | Set-Content $version_filepath -NoNewline
    (Get-Content $setuppy_filepath) | `
        %{ "$_`n" -replace "version='${old_version}'", "version='${new_version}'" } | `
        Set-Content $setuppy_filepath -NoNewline
    Write-Host "Git process is running..."
    git add -A | Out-Null
    git commit -m "Release v$new_version." | Out-Null
    git tag "v$new_version" | Out-Null
    git push | Out-Null
    git push --tags | Out-Null
    Write-Host "Git process completed."
    Write-Host "Run 'git tag -a <tagname> -f -m <comment>' if changing comemnts of release tag."
    Write-Host
    Write-Host "Updated: v$old_version to v$new_version."
    Write-Host
    Write-Host
}

$major = 0
$minor = 1
$revision = 2
$test = 3

# Check the existence of files.
$version_filepath = "publish/version"
$setuppy_filepath = "setup.py"
require_file $version_filepath
require_file $setuppy_filepath

