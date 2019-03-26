$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "General project validation: $moduleName" {

    $scripts = Get-ChildItem $moduleRoot -Include *.ps1,*.psm1,*.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object{@{file=$_}}         
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }

    # foreach ($analyzeFile in $scripts)
    # {
    #     $invokeScriptAnalyzerParameters = @{
    #         Path        = $analyzeFile
    #         ErrorAction = 'SilentlyContinue'
    #         Recurse     = $false
    #     }

    #     Context $invokeScriptAnalyzerParameters.Path {
    #         It 'Should pass all error-level PS Script Analyzer rules' {
    #             $errorPssaRulesOutput = Invoke-ScriptAnalyzer @invokeScriptAnalyzerParameters -Severity 'Error'

    #             if ($null -ne $errorPssaRulesOutput)
    #             {
    #                 $ScriptAnalyzerResultString = $errorPssaRulesOutput | Out-String
    #                 Write-Warning $ScriptAnalyzerResultString
                    
    #                 #Write-Warning -Message 'Error-level PSSA rule(s) did not pass.'
    #                 #Write-Warning -Message 'The following PSScriptAnalyzer errors need to be fixed:'

    #                 #foreach ($errorPssaRuleOutput in $errorPssaRulesOutput)
    #                 #{
    #                 #    Write-Warning -Message "$($errorPssaRuleOutput.ScriptName) (Line $($errorPssaRuleOutput.Line)): $($errorPssaRuleOutput.Message)"
    #                 #}

    #                 #Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/PSScriptAnalyzer'
    #             }
    #             Export-NUnitXml -ScriptAnalyzerResult $errorPssaRulesOutput -Path "$ProjectRoot\Build\ScriptAnalyzerResultError.xml"
    #             If($ENV:BHBuildSystem -eq 'AppVeyor') {
    #                 (New-Object 'System.Net.WebClient').UploadFile(
    #                     "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
    #                     "$ProjectRoot\Build\ScriptAnalyzerResultError.xml")
    #             }
    #             $errorPssaRulesOutput | Should Be $null
    #         }

    #         # It 'Should pass all warning-level PS Script Analyzer rules' {
    #         #     $requiredPssaRulesOutput = Invoke-ScriptAnalyzer @invokeScriptAnalyzerParameters -Severity 'Warning'

    #         #     if ($null -ne $requiredPssaRulesOutput)
    #         #     {
    #         #         $ScriptAnalyzerResultString = $requiredPssaRulesOutput | Out-String
    #         #         Write-Warning $ScriptAnalyzerResultString
    #         #         #Write-Warning -Message 'Required PSSA rule(s) did not pass.'
    #         #         #Write-Warning -Message 'The following PSScriptAnalyzer errors need to be fixed:'

    #         #         #foreach ($requiredPssaRuleOutput in $requiredPssaRulesOutput)
    #         #         #{
    #         #         #    Write-Warning -Message "$($requiredPssaRuleOutput.ScriptName) (Line $($requiredPssaRuleOutput.Line)): $($requiredPssaRuleOutput.Message)"
    #         #         #}

    #         #         #Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/PSScriptAnalyzer'
    #         #     }

    #         #     <#
    #         #         Automatically passing this test until they are passing.
    #         #     #>
    #         #     #$requiredPssaRulesOutput = $null
    #         #     Export-NUnitXml -ScriptAnalyzerResult $requiredPssaRulesOutput -Path "$ProjectRoot\Build\ScriptAnalyzerResultWarning.xml"
    #         #     If($ENV:BHBuildSystem -eq 'AppVeyor') {
    #         #         (New-Object 'System.Net.WebClient').UploadFile(
    #         #             "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
    #         #             "$ProjectRoot\Build\ScriptAnalyzerResultWarning.xml")
    #         #     }
    #         #     $requiredPssaRulesOutput | Should Be $null
    #         # }
    #     }
    #}

}