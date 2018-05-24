# UMN-Google

## Update '1.2.6'
Add functions Get-GFileID and Get-GFile'
Get-GFileID with fetch the ID of any file in Drive that you have access to.  This can then be feed into other functions
Get-GFile can be used to download a file from Drive.  Future releases will support converting Google Docs to other formats as provided by the Google API

## Update '1.2.5'
Add function Remove-GSheetSheetRowColumn.  Removes one or more rows or columns

## Update '1.2.3'
Add function Set-GSheetDropDownList.  Sets data validation on cells in a column and creates drop down list for users to choose options you specify.

EXAMPLE: Set-GSheetDropDownList -accessToken $accessToken -startRowIndex 1 -endRowIndex 10 -columnIndex 9 -sheetName 'Sheet1' -spreadSheetID $spreadSheetID -inputMessage "Must be one of 'Public','Private Restricted','Private, Highly-Restricted'" -values @('Public','Private Restricted','Private, Highly-Restricted')

## Update '1.2.2'
Catch up notes. Module is now code signed.
Fixed plurality typo for remove-gfilepermissions id parameter.

## Update '1.1.1'
Added function to move google drive file.

## Update '1.1.0'

Organized all functions.
Added parameter listing to every function.
Updated help files for every function.
Distinguished between 'fileID' and 'spreadSheetID' -- these are the same, but require different API when taking certain actions.


------------------------------------------------
Current Functions revolve around working with Google Sheets.  Based of API docs https://developers.google.com/sheets/

Set-up: Create a project https://console.developers.google.com/apis/dashboard
Enable the API
Each Service in google has its own API and needs to be enabled one by one for each you want to use.
Select the 3 bars in the upper left corner and choose API Manager, then click on Enable API
Select an appropriate Service
Create a Service Account

You'll need all this info to get to the point of being able to get accesstokens that all function require.

If you create a new sheet with the service account ONLY the service account will have access.  You'll need to call Set-GSheetPermissions to others or yourself if you want to be able to see it in the WebUI.