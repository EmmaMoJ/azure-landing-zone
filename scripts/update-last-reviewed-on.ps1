#!/usr/bin/env pwsh
$commit = $false

git diff-tree --no-commit-id --name-status -r '@{0}' 
| 
# We only care about .erb files and we don't care about deleted files, which start with D
Where-Object { $_ -match 'source' `
        -and $_ -match '.erb' `
        -and $_[0] -ne "D" } | 
ForEach-Object {         
    $file = $_.Substring(1, $_.Length - 1).Trim()    
    $pattern = "(last_reviewed_on:)(\s\d{4}-\d{1,2}-\d{1,2})"
    $date = Get-Date -format yyyy-MM-dd
      
    try {        
        $contents = (Get-Content $file  -Raw) 
        if ($contents -match $date) { continue; }
        $contents -replace $pattern, "`$1 $date" | set-content -Path $file
        git add  $file        
        Write-Output "updated file $file"
        $commit = $true
    }
    catch {       
        Write-Host "Something has gone wrong. Exception: $_"              
        exit 1
    }            
}
if ($commit) {
    git commit -m "Updated last_reviewed_on date to $date"
}

exit 0