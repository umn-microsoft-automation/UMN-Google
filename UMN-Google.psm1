###############
# Module for interacting with Google API
# More details found at https://developers.google.com/sheets/ and https://developers.google.com/drive/
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

#region Dependancies

function ConvertTo-Base64URL
{
    <#
        .Synopsis
            convert text or byte array to URL friendly Base64

        .DESCRIPTION
            Used for preparing the JWT token to a proper format.
        
        .PARAMETER bytes
            The bytes to be converted

        .PARAMETER text
            The text to be converted

        .EXAMPLE
            ConvertTo-Base64URL -text $headerJSON

        .EXAMPLE
            ConvertTo-Base64URL -Bytes $rsa.SignData($toSign,"SHA256")
    #>
    param
    (
        [Parameter(ParameterSetName='Bytes')]
        [System.Byte[]]$Bytes,
        
        [Parameter(ParameterSetName='String')]
        [string]$text
    )

    if($Bytes){$base = $Bytes}
    else{$base =  [System.Text.Encoding]::UTF8.GetBytes($text)}
    $base64Url = [System.Convert]::ToBase64String($base)
    $base64Url = $base64Url.Split('=')[0]
    $base64Url = $base64Url.Replace('+', '-')
    $base64Url = $base64Url.Replace('/', '_')
    $base64Url
}

#endregion

#region oAuth 2.0

    #region Get-GOAuthTokenService
        function Get-GOAuthTokenService
        {
            <#
                .Synopsis
                    Get google auth 2.0 token for a service account

                .DESCRIPTION
                    This is used in server-server OAuth token generation
                
                .PARAMETER certPath
                    Local or network path to .p12 used to sign the JWT token

                .PARAMETER certPswd
                    Password to access the private key in the .p12

                .PARAMETER iss
                    This is the Google Service account address

                .PARAMATER scope
                    The API scopes to be included in the request. Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"
                        
                .EXAMPLE
                    Get-GOAuthTokenService -scope "https://www.googleapis.com/auth/spreadsheets" -certPath "C:\users\$env:username\Desktop\googleSheets.p12" -certPswd 'notasecret' -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"

            #>
            [CmdletBinding()]
            Param
            (
                [Parameter(Mandatory)]
                [string]$certPath,

                [Parameter(Mandatory)]
                [string]$certPswd,

                [Parameter(Mandatory)]
                [string]$iss,
                
                [Parameter(Mandatory)]
                [string]$scope
            )

            Begin
            {
                # build JWT header
                $headerJSON = [Ordered]@{
                    alg = "RS256"
                    typ = "JWT"
                } | ConvertTo-Json -Compress
                $headerBase64 = ConvertTo-Base64URL -text $headerJSON
            }
            Process
            {        
                # Build claims for JWT
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
                # Prep JWT certificate signing
                $googleCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath, $certPswd,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable ) 
                $rsaPrivate = $googleCert.PrivateKey 
                $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider 
                $null = $rsa.ImportParameters($rsaPrivate.ExportParameters($true))
                
                # Signature is our base64urlencoded header and claims, delimited by a period. 
                $toSign = [System.Text.Encoding]::UTF8.GetBytes($headerBase64 + "." + $claimsBase64)
                $signature = ConvertTo-Base64URL -Bytes $rsa.SignData($toSign,"SHA256") ## this needs to be converted back to regular text
                
                # Build request
                $jwt = $headerBase64 + "." + $claimsBase64 + "." + $signature
                $fields = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='+$jwt

                # Fetch token
                $response = Invoke-RestMethod -Uri "https://www.googleapis.com/oauth2/v4/token" -Method Post -Body $fields -ContentType "application/x-www-form-urlencoded"

            }
            End
            {
                return $response.access_token
            }
        }
    #endregion

    #region Get-GOAuthIdToken
        function Get-GOAuthIdToken
        {
            <#
                .Synopsis
                    Get Valid OAuth ID token for a user.  
                
                .DESCRIPTION
                    The ID token is signed by google to represent a user https://developers.google.com/identity/sign-in/web/backend-auth.
                
                .PARAMETER clientID
                    Client ID within app project

                .PARAMETER redirectUri
                    An https project redirect. Can be anything as long as https

                .PARAMETER scope
                    The API scopes to be included in the request. Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"
                
                .EXAMPLE
                    Get-GOAuthIdToken -clientID $clientID -scope $scope -redirectUri $redirectURI
                    
                .NOTES
                    Requires GUI with Internet Explorer to get first token.      
            #>

            [CmdletBinding()]
            [OutputType([array])]
            Param
            (
                [Parameter(Mandatory)]
                [string]$clientID,
                
                [Parameter(Mandatory)]
                [string]$redirectUri,

                [Parameter(Mandatory)]
                [string]$scope

            )

            Begin
            {
                $requestUri = "https://accounts.google.com/o/oauth2/token"
            }
            Process
            {

                ### Get the ID Token - IE Popup and user interaction section
                $auth_string = "https://accounts.google.com/o/oauth2/auth?scope=$scope&response_type=token%20id_token&redirect_uri=$redirectUri&client_id=$clientID&approval_prompt=force"
                $ie = New-Object -comObject InternetExplorer.Application
                $ie.visible = $true
                $null = $ie.navigate($auth_string)

                #Wait for user interaction in IE, manual approval
                do{Start-Sleep 1}until($ie.LocationURL -match 'id_token=([^&]*)')
                $null = $ie.LocationURL -match 'id_token=([^&]*)'
                Write-Debug $ie.LocationURL
                $id_token = $matches[1]
                $null = $ie.Quit()
                return $id_token
            }
            End{}
        }
    #endregion

#endregion

#region Get-GFile
function Get-GFile
{
    <#
        .Synopsis
            Download a Google File.

        .DESCRIPTION
            Download a Google File based on a case sensative file or fileID.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER fileName
            Name of file to retrive ID for. Case sensitive
        
        .PARAMETER fileID
            File ID.  Can be gotten from Get-GFileID

        .PARAMETER outFilePath
            Path to output file including file name.    
        
        .EXAMPLE
            Get-GFile -accessToken $accessToken -fileName 'Name of some file'

        .EXAMPLE
            Get-GFile -accessToken $accessToken -fileID 'ID of some file'

        .NOTES
            Written by Travis Sobeck
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(ParameterSetName='fileName')]
        [string]$fileName,

        [Parameter(ParameterSetName='fileID')]
        [string]$fileID,

        [Parameter(Mandatory)]
        [string]$outFilePath

        #[string]$mimetype
    )

    Begin{}
    Process
    {
        if ($fileName){$fileID = Get-GFileID -accessToken $accessToken -fileName $fileName}
        If ($fileID.count -eq 0 -or $fileID.count -gt 1){break}
        $uri = "https://www.googleapis.com/drive/v3/files/$($fileID)?alt=media"
        Invoke-RestMethod -Method Get -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"} -OutFile $outFilePath
    }
    End{}
}
#endregion 

#region Get-GFileID
function Get-GFileID
{
    <#
        .Synopsis
            Get a Google File ID.

        .DESCRIPTION
            Provide a case sensative file name to the function to get back the gFileID used in many other API calls.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER fileName
            Name of file to retrive ID for. Case sensitive
        
        .PARAMETER mimetype
            Use this to specify a specific mimetype.  See google docs https://developers.google.com/drive/api/v3/search-parameters
        .EXAMPLE
            Get-GFileID -accessToken $accessToken -fileName 'Name of some file'

        .NOTES
            Written by Travis Sobeck
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$fileName,

        [string]$mimetype
    )

    Begin{}
    Process
    {
        $uri = "https://www.googleapis.com/drive/v3/files?q=name%3D'$fileName'"
        if ($mimetype){$fileID = (((Invoke-RestMethod -Method get -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}).files) | Where-Object {$_.mimetype -eq $mimetype}).id}
        else{$fileID = (((Invoke-RestMethod -Method get -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}).files)).id}
        
        # Logic on multiple IDs being returned
        If ($fileID.count -eq 0){Write-Warning "There are no files matching the name $fileName"}
        If ($fileID.count -gt 1){Write-Warning "There are $($fileID.Count) files matching the provided name. Please investigate the following sheet IDs to verify which file you want.";return($fileID)}
        Else{return($fileID)}
    }
    End{}
}
#endregion 

#region Permissions for Google Drive files

function Get-GFilePermissions
{
    <#
        .Synopsis
            Get Permissions on Google Drive File

        .DESCRIPTION
            Get Permission ID list on Google File

        .PARAMETER accessToken
            OAuth Access Token for authorization.
                  
        .PARAMETER fileID
            The fileID to query.  This is returned when a new file is created.

        .PARAMETER permissionID
            If specified will query only that specific permission for the file, rather than all permissions

        .PARAMETER DefaultFields
            If specified, will only query "default" rather than querying all fields of Permission object.  Added primarily for backwards compatibility

        .EXAMPLE
            Get-GFilePermissions -accessToken $accessToken -fileID 'String of File ID' -permissionID 'String of Permission ID'

        .OUTPUTS
            If only a fileID, this will return an object with two properties, the first is kind, and will always be drive#permissionList
            The second will be permissions, which includes the individual permissions objects.  Each one of these will have the same format as if a specific PermissionID was requested
            If a permissionID is also specified, only that specific permission will be returned.  It will have a kind property of drive#permission as well as all properties of that specific permission.
            More details on the permission object available here: https://developers.google.com/drive/api/v2/reference/permissions

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        #[Alias("spreadSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID,

        # Parameter help description
        [Parameter()]
        [string]
        $permissionID,

        # Parameter help description
        [Parameter()]
        [switch]
        $DefaultFields
    )

    Begin
    {
        $uri = "https://www.googleapis.com/drive/v3/files/$fileID/permissions"
        if ($permissionID) {
            $uri += "/$permissionID"
        }
        if (-not $DefaultFields) {
            $uri += "/?fields=*"
        }
        $headers = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        write-host $uri
        Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    }
    End{}
}

function Move-GFile
{
    <#
        .Synopsis
            Change parent folder metadata

        .DESCRIPTION
            A function to change parent folder metadata of a file.

        .PARAMETER accessToken
            OAuth Access Token for authorization.
                  
        .PARAMETER fileID
            The fileID to move.

        .PARAMETER folderID
            The fileID of the new parent folder.

        .PARAMETER parentFolderID
            The fileID of the parentFolder. Optional parameter. root (My Drive) is assumed if not specified.

        .EXAMPLE
            MoveGFile -fileID 'String of File ID' -folderID 'String of folder's File ID'
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        #[Alias("spreadSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID,

        [Parameter(Mandatory)]
        [string]$folderID,

        [string]$parentFolderID='root'
    )

    Begin
    {
        $uriAdd = "https://www.googleapis.com/drive/v3/files/$fileID"+"?removeParents=$parentFolderID"
        $uriRemove = "https://www.googleapis.com/drive/v3/files/$fileID"+"?addParents=$folderID"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        Invoke-RestMethod -Method patch -Uri $uriAdd -Headers $headers

        Invoke-RestMethod -Method patch -Uri $uriRemove -Headers $headers
    }
    End{}
}

function Remove-GFilePermissions
{
    <#
        .Synopsis
            Remove Permissions on Google Drive File

        .DESCRIPTION
            Remove Permission ID list on Google File

        .PARAMETER accessToken
            OAuth Access Token for authorization.
                  
        .PARAMETER fileID
            The fileID to query.  This is returned when a new file is created.

        .PARAMETER permissionsID
            The permission ID to be removed. See Get-GFilePermissions

        .EXAMPLE
            Remove-GFilePermissions -fileID 'String of File ID' -accessToken $accessToken -permissionID 'ID of the permission'

        .NOTES
            A successfull removal returns no body data. 
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        #[Alias("spreadSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID,
        
        [Parameter(Mandatory)]
        [string]$permissionID

    )

    Begin
    {
        $uri = "https://www.googleapis.com/drive/v3/files/$fileId/permissions/$permissionId"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers
    }
    End{}
}

function Set-GFilePermissions
{
    <#
        .Synopsis
            Set Permissions on Google File

        .DESCRIPTION
            For use with any google drive file ID

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER emailAddress
            Email address of the user or group to grant permissions to
        
        .PARAMETER fileID
            The fileID to apply permissions to.

        .PARAMETER role
            Role to assign, select from 'writer','reader','commenter'

        .PARAMETER sendNotificationEmail
            Boolean response on sending email notification.

        .PARAMETER type
            This refers to the emailAddress, is it a user or a group

        .EXAMPLE
            set-GFilePermissions -emailAddress 'user@email.com' -role writer -sheetID $sheetID -type user

        .NOTES
            Requires drive and drive.file API scope.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,
        
        [Parameter(Mandatory)]
        [string]$emailAddress,

        #[Alias("spreadhSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID,
        
        [ValidateSet('writer','reader','commenter')]
        [string]$role = "writer",
        
        [ValidateSet($true,$false)]
        [boolean]$sendNotificationEmail = $false,

        [ValidateSet('user','group')]
        [string]$type
    )

    Begin{
        $json = @{emailAddress=$emailAddress;type=$type;role=$role} | ConvertTo-Json
        $ContentType = "application/json"
        $uri = "https://www.googleapis.com/drive/v3/files/$fileID/permissions/?sendNotificationEmail=$sendNotificationEmail"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }
    Process
    {
        Invoke-RestMethod -Method post -Uri $uri -Body $json -ContentType $ContentType -Headers $headers
    }
    End{}
}

function Update-GFilePermissions
{
    <#
        .Synopsis
            Update Permissions on Google File

        .DESCRIPTION
            Update Permissions on Google File
     
        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER fileID
            The sheetID to apply permissions to.  This is returned when a new sheet is created or use Get-GSheetID

        .PARAMETER permissionID
            The permission ID of the entiry with permissions. Sett Get-GFilePermissions to get a lsit
        
        .PARAMETER role
            Role to assign, select from 'writer','reader','commenter','Owner','Organizer'
        
        .PARAMETER supportTeamDrives
            Boolean for TeamDrive Support

        .PARAMETER transferOwnership
            Update ownership of file to permission ID

        .EXAMPLE
            Update-GFilePermissions -emailAddress 'user@email.com' -role writer -fileID $sheetID -permissionID 'ID of the permission'

        .NOTES
            This is usefull for changing ownership. You cannot change ownership from non-domain to domain.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,
        
        #[Alias("spreadSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID,
        
        [Parameter(Mandatory)]
        [string]$permissionID,

        [ValidateSet('writer','reader','commenter','owner','organizer')]
        [string]$role = "writer",

        [ValidateSet($true,$false)]
        [string]$supportTeamDrives = $false,

        [ValidateSet($true,$false)]
        [string]$transferOwnership = $false
    )

    Begin{
        $json = @{role=$role} | ConvertTo-Json
        $ContentType = "application/json"
        $uri = "https://www.googleapis.com/drive/v3/files/$fileID/permissions/$permissionID/?transferOwnership=$transferOwnership"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }
    Process
    {

        Invoke-RestMethod -Method Patch -Uri $uri -Body $json -ContentType $ContentType -Headers $headers
    }
    End{}
}

#endregion

#region Spread Sheet API Functions

#region Add-GSheetSheet
    function Add-GSheetSheet
    {
        <#
            .Synopsis
                Add named sheets to an existing spreadSheet file.
        
            .DESCRIPTION
                This function will add a specified sheet name to a google spreadsheet.

            .PARAMETER accessToken
                access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService
        
            .PARAMETER sheetName
                Name to apply to new sheet
                
            .PARAMETER spreadSheetID
                ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

            
            .EXAMPLE
                Add-GSheetSheet -accessToken $accessToken -sheetName 'NewName' -spreadSheetID $spreadSheetID
        
        #>
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory)]
            [string]$accessToken,
            
            [Parameter(Mandatory)]
            [string]$sheetName,

            [Parameter(Mandatory)]
            [string]$spreadSheetID


        )

        Begin
        {
            $properties = @{requests=@(@{addSheet=@{properties=@{title=$sheetName}}})} |convertto-json -Depth 10
        }

        Process
        {
            $suffix = "$spreadSheetID" + ":batchUpdate"
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
            Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType 'application/json' -Headers @{"Authorization"="Bearer $accessToken"}
        }
        End{}
    }
#endregion

#region Clear-GSheetSheet
    function Clear-GSheetSheet
    {
        <#
            .Synopsis
                Clear all data and leave formatting intact for a sheet from a spreadsheet based on sheetID

            .DESCRIPTION
                This function will delete data from a sheet

            .PARAMETER accessToken
                access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

            .PARAMETER sheetName
                Name of sheet to clear

            .PARAMETER spreadSheetID
                ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

            .EXAMPLE
                $pageID = 0  ## using pageID to differentiate from sheetID -- 
                In this case, index 0 is the actual sheetID per the API and will be cleared.

                $sheetID = ## the id number of the file/spreadsheet

                clear-gsheet -pageID $pageID -sheetID $sheetID -accessToken $accessToken

            
        #>
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory)]
            [string]$accessToken,
            
            [Parameter(Mandatory)]
            [string]$sheetName,

            [Parameter(Mandatory)]
            [string]$spreadSheetID

        )

        Begin{}
        Process
        {
            $sheetID = Get-GSheetSheetID -accessToken $accessToken -spreadSheetID $spreadSheetID -sheetName $sheetName
            $properties = @{requests=@(@{updateCells=@{range=@{sheetId=$sheetID};fields="userEnteredValue"}})} |ConvertTo-Json -Depth 10
            $suffix = "$spreadSheetID" + ":batchUpdate"
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
            Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType 'application/json' -Headers @{"Authorization"="Bearer $accessToken"}
        }
        End{}
    }
#endregion

#region Get-GSheetData
    function Get-GSheetData
    {
        <#
            .Synopsis
                Basic function for retrieving data from a specific Sheet in a Google SpreadSheet.

            .DESCRIPTION
                Basic function for retrieving data from a specific Sheet in a Google SpreadSheet.

            .PARAMETER accessToken
                access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService
            
            .PARAMETER cell
                Required switch for getting all data, or a subset of cells.

            .PARAMETER rangeA1
                Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx. The dimensions of the $values you put in MUST fit within this range
            
            .PARAMETER sheetName
                Name of sheet to data from

            .PARAMETER spreadSheetID
                ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

            .PARAMETER valueRenderOption
                How the data is renderd. Switch option from formatted to unformatted data or 'formula'

            .EXAMPLE
                Get-GSheetData -accessToken $accessToken -cell 'AllData' -sheetName 'Sheet1' -spreadSheetID $spreadSheetID

            .EXAMPLE
                Get-GSheetData -accessToken $accessToken -cell 'Range' -rangeA1 'A0:F77' -sheetName 'Sheet1' -spreadSheetID $spreadSheetID
            
        #>
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory)]
            [string]$accessToken,
            
            [Parameter(Mandatory)]
            [ValidateSet('AllData','Range')]
            [string]$cell,

            [string]$rangeA1,
            
            [Parameter(Mandatory)]
            [string]$sheetName,

            [Parameter(Mandatory)]
            [string]$spreadSheetID,

            [Parameter()]
            [ValidateSet('FORMATTED_VALUE', 'UNFORMATTED_VALUE', 'FORMULA')]
            [string]$valueRenderOption = "FORMATTED_VALUE"

        )

        Begin{}
        Process
        {
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID/values/$sheetName"

            if($cell -eq "Range") {
                $uri += "!$rangeA1"
            }

            $uri += "?valueRenderOption=$valueRenderOption"

            $result = Invoke-RestMethod -Method GET -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}
            
            # Formatting the returned data
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
        End{}
    }
#endregion

function Get-GSheetSheetID
{
    <#
        .Synopsis
            Get ID of specific sheet in a Spreadsheet

        .DESCRIPTION
         Get ID of specific sheet in a Spreadsheet

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService
        
        .PARAMETER sheetName
            The name of the sheet

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE
            Get-GSheetSheetID -accessToken $accessToken -sheetName 'Sheet1' -spreadSheetID $spreadSheetID  
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$sheetName,

        [Parameter(Mandatory)]
        [string]$spreadSheetID
    )

    Begin{}
    Process
    {
        $spreadSheet = Get-GSheetSpreadSheetProperties -spreadSheetID $spreadSheetID -accessToken $accessToken
        ($spreadSheet.sheets.properties | Where-Object {$_.title -eq $sheetName}).sheetID
    }
    End{}
}

#region Get-GSheetSpreadSheetID
    function Get-GSheetSpreadSheetID
    {
        <#
            .Synopsis
                Get a spreadsheet ID.

            .DESCRIPTION
                Provide a case sensative file name to the function to get back the sheetID used in many other API calls.
                mimeTymes are split out to only retrieve spreadSheet IDs (no folders or other files)

            .PARAMETER accessToken
                access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

            .PARAMETER fileName
                Name of file to retrive ID for. Case sensitive
            
            .EXAMPLE
                Get-GSheetSpreadSheetID -accessToken $accessToken -fileName 'Name of some file'
        #>
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory)]
            [string]$accessToken,
            [Parameter(Mandatory)]

            [Alias("spreadSheetName")] 
            [string]$fileName
        )

        Begin{}
        Process
        {
            return (Get-GFileID -accessToken $accessToken -fileName $fileName -mimetype "application/vnd.google-apps.spreadsheet")
        }
        End{}
    }
#endregion

function Get-GSheetSpreadSheetProperties
{
    <#
        .Synopsis
            Get the properties of a SpreadSheet

        .DESCRIPTION
            Get all properties of a SpreadSheet

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .EXAMPLE
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$spreadSheetID
    )

    Begin{}
    Process
    {
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID"
        Invoke-RestMethod -Method GET -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End{}
}

function Move-GSheetData
{
    <#
        .Synopsis
            Move data around between sheets in a spreadSheet.

        .DESCRIPTION
            This is a cut and paste between sheets in a spreadsheet.
            The function will find the row index based on search criteria, and copy/paste between the sheets provided.

        .PARAMETER accessToken
            oAuth access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER columnKey
            Row 0 column value. A key to search for data by. $columnKey = 'Column header'

        .PARAMETER currentSheetName
            Name of sheet to be searched, and copied from.

        .PARAMETER newSheetName
            Name of destination sheet data is to be written to.

        .PARAMETER query
            Value to be queried for in specified column (see columnKey) $query = 'Cell Content'
        
        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE
            Move-GSheetData -accessToken $accessToken -columnKey 'Column Header -destinationSheetName 'New Sheet!' -query 'Cell Content' -sourceSheetName 'Old Sheet' -spreadSheetID $spreadSheetID
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$columnKey,

        [Parameter(Mandatory)]
        [string]$destinationSheetName,
        
        [Parameter(Mandatory)]
        [string]$query,
        
        [Parameter(Mandatory)]
        [string]$sourceSheetName,

        [Parameter(Mandatory)]
        [string]$spreadSheetID
    )

    Begin{}

    Process
    {
        ## Query all data from sheet
        $data = Get-GSheetData -spreadSheetID $spreadSheetID -accessToken $accessToken -sheetName $sourceSheetName -cell AllData
        $destinationData = Get-GSheetData -spreadSheetID $spreadSheetID -accessToken $accessToken -sheetName $destinationSheetName -cell AllData

        ## Get row query belongs to
        $Index = (0..($data.count -1) | where {$Data[$_].$columnKey -eq $query})
        
        ## Sanity Check - is this the data?
        if (-not $Index) {
            write-Warning "$Query in $columnKey does not exist"
            return $null
            }

        Else {
        $rowIndex = $index[0] + 2    
        $startRow = $Index[0] + 1
        $destinationRow = ($destinationData).count + 2
        $destinationStartRow = ($destinationData).count + 1
        }

        ## Get sheet index ID numbers
        $allSheetProperties = (Get-GSheetSpreadSheetProperties -spreadSheetID $spreadSheetID -accessToken $accessToken).sheets.properties

        $srcSheetIndex = ($allSheetProperties | where {$_.title -eq $sourceSheetName}).sheetID
        $dstSheetIndex = ($allSheetProperties | where {$_.title -eq $destinationSheetName}).sheetID                                

        $method = 'POST'
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID"+":batchUpdate"
        $ContentType = "application/json"
        
   
        ## cutPaste row to row 
        $values = @{"cutPaste"=@{"source"=@{"sheetId"=$srcSheetIndex;"startRowIndex"=$startRow;"endRowIndex"=$rowIndex};"destination"=@{"sheetId"=$dstSheetIndex;"rowIndex"=$destinationRow};"pasteType"="PASTE_NORMAL"}}
        $JSON = @{"requests"=$values} |ConvertTo-Json -Depth 20
            
        
        
        Invoke-RestMethod -Method $method -Uri $uri -Body $json -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}
        
    }
}
    
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename
