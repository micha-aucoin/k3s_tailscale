## window systems:

``` powershell
function fn-powershell {
    $sourceDir = "fn_powershell"
    $currentDir = Get-Location
    $sourcePath = Join-Path -Path $currentDir -ChildPath $sourceDir

    if (Test-Path -Path $sourcePath) {
        $psFiles = Get-ChildItem -Path $sourcePath -Filter *.ps1
        foreach ($file in $psFiles) {
            . $file.FullName
        }
        Write-Host "Sourced all PowerShell files in $sourcePath."
    } else {
        Write-Host "Directory $sourcePath not found."
    }
}
```
- copy and paste the above function to $PROFILE 
    > ```powershell
    > notepad $PROFILE   
    >```
          
- restart the terminal and source the function
    > ```powershell
    > . fn-powershell
    >```


## things to add:
1. install nestybox/sysbox

2. create ansible key

3. conda env ansible
    - ansible
    - molecule-plugins

4. secret env files

