###############
# Module for interacting with Google API
#
#
###############

###
# Copyright 2017 University of Minnesota, Office of Information Technology

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
###

function ConvertTo-Base64URL
{
    <#
        .Synopsis
        convert text or byte array to URL friendly BAse64
        .DESCRIPTION
        convert text or byte array to URL friendly BAse64
        .EXAMPLE
        ConvertTo-Base64URL -text $headerJSON
        .EXAMPLE
        ConvertTo-Base64URL -Bytes $rsa.SignData($toSign,"SHA256")
    #>
    param
    (
        [Parameter(ParameterSetName='String')]
        [string]$text,

        [Parameter(ParameterSetName='Bytes')]
        [System.Byte[]]$Bytes
    )

    if($Bytes){$base = $Bytes}
    else{$base =  [System.Text.Encoding]::UTF8.GetBytes($text)}
    $base64Url = [System.Convert]::ToBase64String($base)
    $base64Url = $base64Url.Split('=')[0]
    $base64Url = $base64Url.Replace('+', '-')
    $base64Url = $base64Url.Replace('/', '_')
    $base64Url
}

################################################## OAuth #################################################################
function Get-GOAuthTokenUser
{
    <#
        .Synopsis
        Get Valid OAuth Token.  The access token is good for an hour, the refresh token is mostly permanent and can be used to get a new access token without having to reauthenticate
        .DESCRIPTION
        Long description
        .EXAMPLE
        You can provide multiple scopes for access to multiple APIs at the same time. They just need to be separated by a space
        $scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive" provides access to spreadsheets and drive api.
        .EXAMPLE
        Another example of how to use this cmdlet 
    #>
    [CmdletBinding()]
    [OutputType([array])]
    Param
    (
        # projectID, appKey, and appSecret 
        [Parameter(Mandatory)]
        [string]$projectID, # Name of API Project

        [Parameter(Mandatory)]
        [string]$appKey,    # App key ID

        [Parameter(Mandatory)]
        [string]$appSecret, # App key secret

        [Parameter(Mandatory)]
        [string]$scope, ## example $scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"

        [Parameter(Mandatory)]
        [string]$redirectUri, ## example $redirectUri = "https://umn.edu"  has to be set to https

        [string]$refreshToken
    )

    Begin
    {
    }
    Process
    {
        ### If no refresh token - requires human interaction with IE
        if(!($refreshToken))
        { 
            ### Get Google API access - https://developers.google.com/identity/protocols/OAuth2WebServer#offline
            #$scope = "https://www.googleapis.com/auth/spreadsheets"
            $response_type = "code"
            $approval_prompt = "force"
            $access_type = "offline"
 
            ### Get the authorization code
            $auth_string = "https://accounts.google.com/o/oauth2/auth?scope=$scope&response_type=$response_type&redirect_uri=$redirectUri&client_id=$appKey&access_type=$access_type&approval_prompt=$approval_prompt"
 
            $ie = New-Object -comObject InternetExplorer.Application
            if($approval_prompt -eq "force"){$ie.visible = $true}
            $null = $ie.navigate($auth_string)
            #Wait for user interaction in IE, manual approval
            do{Start-Sleep 1}until($ie.LocationURL -match 'code=([^&]*)')
            $null = $ie.LocationURL -match 'code=([^&]*)'
            $authorizationCode = $matches[1]
            $null = $ie.Quit()

            ### exchange the authorization code for a refresh token and access token
            $grantType = "authorization_code"
            $requestUri = "https://accounts.google.com/o/oauth2/token"
            $requestBody = "code=$authorizationCode&client_id=$appKey&client_secret=$appSecret&grant_type=$grantType&redirect_uri=$redirectUri"
 
            $response = Invoke-RestMethod -Method Post -Uri $requestUri -ContentType "application/x-www-form-urlencoded" -Body $requestBody

            $props = @{
                accessToken = $response.access_token
                refreshToken = $response.refresh_token
            }
        }

        ### If refresh token exists
        else
        { 
            ### exchange the refresh token for an access token
            $grantType = "refresh_token"
            $requestUri = "https://accounts.google.com/o/oauth2/token"
            $requestBody = "refresh_token=$refreshToken&client_id=$appKey&client_secret=$appSecret&grant_type=$grantType"
 
            $response = Invoke-RestMethod -Method Post -Uri $requestUri -ContentType "application/x-www-form-urlencoded" -Body $requestBody
            $props = @{
                accessToken = $response.access_token
                refreshToken = $refreshToken
            }
        }
        
        return new-object psobject -Property $props
    }
    End
    {
    }
}

function Get-GOAuthTokenService
{
    <#
        .Synopsis
        Get google auth 2.0 token for a service account
        .DESCRIPTION
        Long description
        .EXAMPLE
        Get-GOAuthTokenService -scope "https://www.googleapis.com/auth/spreadsheets" -certPath "C:\users\$env:username\Desktop\googleSheets.p12" -certPswd 'notasecret' -iss "oit-automation@oit-mpt-powershell-sheets.iam.gserviceaccount.com"
        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$scope,

        [Parameter(Mandatory)]
        [string]$certPath,

        [Parameter(Mandatory)]
        [string]$certPswd,

        [Parameter(Mandatory)]
        [string]$iss ## Google service account email address 
    )

    Begin
    {
    }
    Process
    {        
        # build JWT header
        $headerJSON = [Ordered]@{
            alg = "RS256"
            typ = "JWT"
        } | ConvertTo-Json -Compress
        $headerBase64 = ConvertTo-Base64URL -text $headerJSON

        ## Claims
        ## Build date times needed in seconds
        $now = (Get-Date).ToUniversalTime()
        $iat = [Math]::Floor([decimal](Get-Date($now) -UFormat "%s"))
        $exp = [Math]::Floor([decimal](Get-Date($now.AddMinutes(59)) -UFormat "%s")) 
        $aud = "https://www.googleapis.com/oauth2/v4/token"
        $claimsJSON = [Ordered]@{
            iss = $iss
            scope = $scope
            aud = $aud
            exp = $exp
            iat = $iat
        } | ConvertTo-Json -Compress

        $claimsBase64 = ConvertTo-Base64URL -text $claimsJSON

        ################# Create JWT
        # Prep Cert
        #$certPath = "C:\users\$env:username\Desktop\googleSheets.p12"
        $googleCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath, $certPswd,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable ) 
        # get just the private key
        $rsaPrivate = $googleCert.PrivateKey 
        # get a new RSA provider
        $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider 
        # copy the parameters from the private key into our new rsa provider
        $null = $rsa.ImportParameters($rsaPrivate.ExportParameters($true))
        # signature is our base64urlencoded header and claims, seperated by a . 
        $toSign = [System.Text.Encoding]::UTF8.GetBytes($headerBase64 + "." + $claimsBase64)
        # sign the sig, we then serialize to UTF-8 bytes, then base64url encode the signature
        $signature = ConvertTo-Base64URL -Bytes $rsa.SignData($toSign,"SHA256") ## this needs to be converted back to regular text
        ## request
        $jwt = $headerBase64 + "." + $claimsBase64 + "." + $signature
        $fields = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='+$jwt

        $response = Invoke-RestMethod -Uri "https://www.googleapis.com/oauth2/v4/token" -Method Post -Body $fields -ContentType "application/x-www-form-urlencoded"
        $response.access_token
    }
    End
    {
        
    }
}

################################################## sheets #################################################################

function Get-GSheetData
{
    <#
        .Synopsis
        Basic function for retrieving data from a specific Google Sheet.
        .DESCRIPTION
        Long description
        .EXAMPLE
        Example of how to use this cmdlet
        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$sheetName,

        ## Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx
        ## The dimensions of the $values you put in MUST fit within this range
        [string]$rangeA1,

        [Parameter(Mandatory)]
        [ValidateSet('AllData','Range')]
        [string]$cell,

        [Parameter()]
		[ValidateSet('FORMATTED_VALUE', 'UNFORMATTED_VALUE', 'FORMULA')]
		[string]$valueRenderOption = "FORMATTED_VALUE"

    )

    Begin
    {
    }
    Process
    {
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$sheetID/values/$sheetName"

        if($cell -eq "Range") {
            $uri += "!$rangeA1"
        }

        $uri += "?valueRenderOption=$valueRenderOption"

        $result = Invoke-RestMethod -Method GET -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}
        $sheet = $result.values
        $Rows = $sheet.Count
        $Columns = $sheet[0].Count
        $HeaderRow = 0
        $Header = $sheet[0]
        foreach ($Row in (($HeaderRow + 1)..($Rows-1))) { 
            $h = [Ordered]@{}
            foreach ($Column in 0..($Columns-1)) {
                if ($sheet[0][$Column].Length -gt 0) {
                    $Name = $Header[$Column]
                    $h.$Name = $Sheet[$Row][$Column]
                }
            }
            [PSCustomObject]$h
        }
    }
    End
    {
    }
}

function Set-GSheetData
{
    <#
        .Synopsis
        Set values in sheet in specific cell locations or append data to a sheet
        .DESCRIPTION
        Long description
        .EXAMPLE
        Set-GSheetData -sheetID '1LvqbZSTlgQNIBC2bkv9Ze6nFWPBY98ASI2_sMc1DQSE' -accessToken $accessToken -sheetName 'Sheet1' -rangeA1 'A19:B20' -values @(@("a","b"),@("c","D"))
        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$sheetName,

        ## Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx
        ## The dimensions of the $values you put in MUST fit within this range
        [Parameter(ParameterSetName='set')]
        [string]$rangeA1,

        [Parameter(ParameterSetName='Append')]
        [switch]$append,

        ## This shoudl be an array or arrays.  Each internal array represents one ROW
        [Parameter(Mandatory)]
        [System.Collections.ArrayList]$values,

        [string]$valueInputOption = 'RAW'

    )

    Begin
    {
    }
    Process
    {
        if ($append)
        {
            $method = 'POST'
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$sheetID/values/$sheetName"+":append?valueInputOption=$valueInputOption"
        }
        else
        {
            $method = 'PUT'
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$sheetID/values/$sheetName!$rangeA1"+"?valueInputOption=$valueInputOption"
        }
        $json = @{values=$values} | ConvertTo-Json
        ###### uncomment the following two lines for debug
        #$uri
        #$json
        $ContentType = "application/json"
        
        Invoke-RestMethod -Method $method -Uri $uri -Body $json -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
        
    }
    End
    {
    }
}

function Get-GSheetProperties
{
    <#
        .Synopsis
        Short description
        .DESCRIPTION
        Long description
        .EXAMPLE
        Example of how to use this cmdlet
        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken

    )

    Begin
    {
    }
    Process
    {
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$sheetID"
        $Data = Invoke-RestMethod -Method GET -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
        return([array]$data)
    }
}

function get-GSheetID
{
    <#
        .Synopsis
        Get a spreadsheet ID.
        .DESCRIPTION
        Provide a case sensative sheet name to the function to get back the sheetID used in many other API calls.
        mimeTymes are split out to only retrieve spreadSheet IDs (no folders or other files)
        .EXAMPLE
        $fileName = 'Test'
        get-GSheetID -fileName $fileName
        There are  2  files matching the provided name. Please investigate the following sheet IDs to verify which file you want.
            sheetID0 = 1X3JO1sbchh6F8ZxOwTxyAVVqUisyVM2qWRipfDoeLdQ
            sheetID1 = 1I7mhlRDazIF3f5chIcDN7ru1hkrGlxAWCXtpHw6L4Nc
        .EXAMPLE
            Case sensitivity - 
        $fileName = 'test'
        get-GSheetID -FileName 'test'
            1wKsiD7QOglTwA27eoKqmdwudJL4XAjt2rx58gpscBVY
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$fileName,

        [Parameter(Mandatory)]
        [string]$accessToken
    )

    Begin
    {
    }
    Process
    {

        $uri = "https://www.googleapis.com/drive/v3/files?q=name%3D'$FileName'"
        $sheetID = (((Invoke-RestMethod -Method get -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}).files) | where {$_.mimetype -eq "application/vnd.google-apps.spreadsheet"}).id
        If ($sheetID.count -eq 0){throw "There are no files matching the name $fileName"}
        If ($sheetID.count -gt 1){Write-Warning "There are $($sheetid.Count) files matching the provided name. Please investigate the following sheet IDs to verify which file you want.";return($sheetID)}
        Else{return($sheetID)}
    }
    End
    {                
    }
}

function New-GSheet
{
    <#
        .Synopsis
        Provide JSON properties to create new Google Sheet.
        .DESCRIPTION
        The properties that can be set are extensive. Cell color, formatting etc - most commonly this will only be used for setting the file name.
        Return is array data of the created sheet in order to retrieve the newly generated sheetID to continue working with the remaining functions.
        .EXAMPLE
            Example for setting the title of the sheet 
        $properties = @{properties=@{title="JSON ARRAYS ARE AWESOME"}} |convertto-json
        create-GSheet -properties $properties -accessToken $accessToken
        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$Title,

        [array]$properties
    )

    Begin
    {
        If (!$properties)
            {
            $properties = @{properties=@{title=$Title}} |convertto-json
            }
    }
    Process
    {
        $uri = "https://sheets.googleapis.com/v4/spreadsheets"
        $ContentType = "application/json"
        $data = Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
    return([array]$data)
    }
}

function set-GSheetPermissions
{
    <#
        .Synopsis
        Provide JSON properties to set file permissions.
        .DESCRIPTION

        .EXAMPLE

        .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$emailAddress, ## email address of user or group to be shared with

        [Parameter(Mandatory)]
        [string]$fileID,

        [string]$role = "writer",

        [ValidateSet('user','group')]
        [string]$type

 
    )

    Begin
    {
    }
    Process
    {
        $json = @{emailAddress=$emailAddress;type=$type;role=$role} | ConvertTo-Json
        $ContentType = "application/json"
        $uri = "https://www.googleapis.com/drive/v3/files/$fileID/permissions"
        
        Invoke-RestMethod -Method post -Uri $uri -Body $json -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
    return([array]$data)
    }
}


function move-GSheetData
{
    <#
        .Synopsis
            'Move' data around
        .DESCRIPTION
            This is a cut and paste between sheets in a spreadsheet.
            The function will find the row index based on search criteria, and move between the sheets provided.
        .EXAMPLE
            $newSheetName = 'Decommissioned'
            $currentSheetName = 'Servers'
            $sheetID = get-GSheetID -FileName 'MPT-ServerDoco'
            $columnKey = 'Server name' # value based on column name to search
            $query = 'test1124' # Key item in column to search for. Such as the server's name
            $accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $iss

            move-gsheetData -sheetID $sheetID -accessToken $accessToken -CurrentSheetName $currentSheetName -newSheetName $newSheetName -query $query -columnKey $columnKey
        .EXAMPLE
            move-GSheetData -sheetID $sheetID -accessToken $accessToken -currentSheetName 'Servers' -newSheetName 'Decommissioned' -query 'Virt-vum-dev' -columnKey 'Server name'
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$currentSheetName,

        [Parameter(Mandatory)]
        [string]$newSheetName,

        [Parameter(Mandatory)]
        [string]$query,

        [Parameter(Mandatory)]
        [string]$columnKey

    )

    Begin
    {


    }
    Process
    {
        ## Query all data from sheet
        $data = Get-GSheetData -sheetID $sheetID -accessToken $accessToken -sheetName $currentSheetName -cell AllData
        $destinationData = Get-GSheetData -sheetID $sheetID -accessToken $accessToken -sheetName $newSheetName -cell AllData

        ## Get row query belongs to
        $Index = (0..($data.count -1) | where {$Data[$_].$columnKey -eq $query})
        
        ## Sanity Check - is this the data?
        if (!$Index) {write-host "$Query in $columnKey does not exist"
            break}
        Else {
        $rowIndex = $index[0] + 2    
        $startRow = $Index[0] + 1
        $destinationRow = ($destinationData).count + 2
        $destinationStartRow = ($destinationData).count + 1
        }

        ## Get sheet index ID numbers
        $allSheetProperties = (Get-GSheetProperties -sheetID $sheetID -accessToken $accessToken).sheets.properties

        $currentSheetIndex = ($allSheetProperties | where {$_.title -eq $currentSheetName}).sheetID
        $newSheetIndex = ($allSheetProperties | where {$_.title -eq $newSheetName}).sheetID                                

        $method = 'POST'
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$sheetID"+":batchUpdate"
        $ContentType = "application/json"
        
   
        ## cutPaste row to row 
        $values = @{"cutPaste"=@{"source"=@{"sheetId"=$currentSheetIndex;"startRowIndex"=$startRow;"endRowIndex"=$rowIndex};"destination"=@{"sheetId"=$newSheetIndex;"rowIndex"=$destinationRow};"pasteType"="PASTE_NORMAL"}}
        $JSON = @{"requests"=$values} |ConvertTo-Json -Depth 20
            
        
        
        Invoke-RestMethod -Method $method -Uri $uri -Body $json -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
        
    }
    End
    {
    }
}

function add-GSheet
{
    <#
    .Synopsis
        Add named pages/sheets to an existing document
    .DESCRIPTION
        This function will add a specified sheet name to a google spreadsheet.
    .EXAMPLE
        $sheetName = "Data 2"
        $sheetID = ## the id number of the file
        add-gSheet -sheetName $sheetName -sheetID $sheetID -accessToken $accessToken

    .EXAMPLE
    
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$sheetName,

        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken
    )

    Begin
    {
        If (!$properties)
            {
            $properties = @{requests=@(@{addSheet=@{properties=@{title=$sheetName}}})} |convertto-json -Depth 10
            }
    }
    Process
    {
        $suffix = "$sheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
        $ContentType = "application/json"
        $data = Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
    return([array]$data)
    }
}

function remove-GSheet
{
    <#
        .Synopsis
        Removes a sheet from a spreadsheet based on sheetID
        .DESCRIPTION
            This function will delete a sheet.
        .EXAMPLE
            $pageID = 0  ## using pageID to differentiate from sheetID -- 
            In this case, index 0 is the actual sheetID per the API and will be deleted.

            $sheetID = ## the id number of the file/spreadsheet

            remove-gsheet -pageID $pageID -sheetID $sheetID -accessToken $accessToken

        .EXAMPLE
        
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$pageID,
        
        [Parameter(Mandatory)]
        [string]$sheetID,

        [Parameter(Mandatory)]
        [string]$accessToken
    )

    Begin
    {
        If (!$properties)
            {
            $properties = @{requests=@(@{deleteSheet=@{sheetId=$pageID}})} |convertto-json -Depth 10
            }
    }
    Process
    {
        $suffix = "$sheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
        $ContentType = "application/json"
        $data = Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
    return([array]$data)
    }
}

##########################################################################################################################
Export-ModuleMember -Function *