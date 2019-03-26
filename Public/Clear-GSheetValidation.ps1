function Clear-GSheetValidation
{
    <#
        .Synopsis
            Clears Validation data from selected cells or the entire sheet

        .DESCRIPTION
            Clears Validation data from selected cells or the entire sheet

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .PARAMETER sheetName
            Name of sheet in spreadSheet to clear validation from

        .PARAMETER startRowIndex
            The start row (inclusive) of the range, if not set will start at first row (Using GridRange Object https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange)
        
        .PARAMETER endRowIndex
            The end row (exclusive) of the range, if not set will end at last row (Using GridRange Object https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange)

        .PARAMETER startColumnIndex
            The start column (inclusive) of the range, if not set will start at first column (Using GridRange Object https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange)

        .PARAMETER endColumnIndex
           The end column (exclusive) of the range if not send will end at last column (Using GridRange Object https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange)

        .EXAMPLE Clear-GSheetValidation -accessToken $accessToken -sheetName 'Sheet1' -spreadSheetID $spreadSheetID -startRowIndex 1 -endRowIndex 10 -startColumnIndex 9 -EndColumnIndex 10 
            
        
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,
        
        [Parameter(Mandatory)]
        [string]$spreadSheetID,

        [Parameter(Mandatory)]
        [string]$sheetName,
        
        [Parameter()]
        [int]$startRowIndex,

        [Parameter()]
        [int]$endRowIndex,

        [Parameter()]
        [int]$startColumnIndex,

        [Parameter()]
        [int]$endColumnIndex
    )

    Begin
    {
        $sheetID = Get-GSheetSheetID -accessToken $accessToken -spreadSheetID $spreadSheetID -sheetName $sheetName
        $validation = @{
            setDataValidation = @{
            }
        }
        $range = @{sheetId = $sheetID}
        if ($startRowIndex) {
            $range += @{startRowIndex=$startRowIndex}
        }
        if ($startColumnIndex) {
            $range += @{sstartColumnIndex=$columnIndex}
        }
        if ($endRowIndex) {
            $range += @{endRowIndex=$endRowIndex}
        }
        if ($endColumnIndex) {
            $range += @{endColumnIndex=$endColumnIndex}
        }
        $validation.setDataValidation.Add("range",$range)
        $json = @{requests=@($validation)} | ConvertTo-Json -Depth 20
        $suffix = "$spreadSheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
    }

    Process
    {
        Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }
    
    End{}
}
