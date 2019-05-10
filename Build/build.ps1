param ($Task = 'Default')
$VerbosePreference = 'Continue'

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module Psake, PSDeploy, BuildHelpers, Pester -Force
Import-Module Psake, BuildHelpers

#get-command 'git'
#write-warning $PWD.Path

Get-Item Env:


Set-BuildEnvironment

Invoke-psake -buildFile .\Build\psake.ps1 -taskList $Task -nologo
exit ( [int]( -not $psake.build_success ) )
