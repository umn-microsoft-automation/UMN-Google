# UMN-Google

Update '1.1.1'
Added function to move google drive file.

Update '1.1.0'

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

If you create a new sheet it with the service account ONLY the service account will have access.  You'll need to call Set-GSheetPermissions to others or yourself if you want to be able to see it in the WebUI.