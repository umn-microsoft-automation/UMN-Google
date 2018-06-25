<#
    Stashing this work, could never really get it to work because google removed lines and re-indexed too fast.  Also if the endIndex of one array was the same as the startIndex of another
    google's api would ignore it.
#>
#region Remove-GSheetSheetRowColumn
function Remove-GSheetSheetRowColumn
{
    <#
        .Synopsis
            Remove row(s) or column(s)

        .DESCRIPTION
            Remove row(s) or column(s)

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER indexes
            Array of Arrays containing Index of row or column to start deleting
        
            .PARAMETER startIndex
            Index of row or column to start deleting

        .PARAMETER endIndex
            Index of row or column to stop deleting

        .PARAMETER dimension
            Remove Rows or Columns

        .PARAMETER sheetName
            Name of sheet in spreadSheet

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE  Remove-GSheetSheetRowColumn -accessToken $accessToken -sheetName "Sheet1" -spreadSheetID $spreadSheetID -dimension ROWS -startIndex 5 -endIndex 10            
        
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,
        
        [Parameter(Mandatory,ParameterSetName='Single')]
        [int]$startIndex,

        [Parameter(Mandatory,ParameterSetName='Single')]
        [int]$endIndex,

        [Parameter(Mandatory,ParameterSetName='Multiple')]
        [array]$indexes,

        [Parameter(Mandatory)]
        [ValidateSet("COLUMNS", "ROWS")]
        [string]$dimension,

        [Parameter(Mandatory)]
        [string]$sheetName,

        [Parameter(Mandatory)]
        [string]$spreadSheetID
    )

    Begin
    {
        $sheetID = Get-GSheetSheetID -accessToken $accessToken -spreadSheetID $spreadSheetID -sheetName $sheetName            
    }

    Process
    {
        [System.Collections.ArrayList]$requestArray = @()
        if ($indexes)
        {
            foreach ($index in $indexes)
            {
                if ($index[0] -eq $index[1]){$index[1]++}
                [void]$requestArray.add(@{"deleteDimension" = @{"range" = @{"sheetId" = $sheetID; "dimension" = $dimension; "startIndex" = $index[0]; "endIndex" = $index[1]}}})
            }
        }
        else
        {
            if ($startIndex -eq $endIndex){$endIndex++}
            [void]$requestArray.add(@{"deleteDimension" = @{"range" = @{"sheetId" = $sheetID; "dimension" = $dimension; "startIndex" = $startIndex; "endIndex" = $endIndex}}})
        }
        $json = @{requests=$requestArray} | ConvertTo-Json -Depth 20
        $suffix = "$spreadSheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
        write-verbose -Message $json
        Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }
    
    End{}
}
#endregion