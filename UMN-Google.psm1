###############
# Module for interacting with Google API
# More details found at https://developers.google.com/sheets/ and https://developers.google.com/drive/
#
###############

###
# Copyright 2020 University of Minnesota, Office of Information Technology

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
                    This function will use a certificate to generate an RSA token that will be used to sign a JWT token which is needed to generate the access key.
                    The certificate can be specified as file path and password to read the certificate from.
                    It can also be specified as an object, such was when running in Automation that will return a certificate object
                    The RSA token can also be specified directly if needed instead of generating it from a certificate

                .PARAMETER certPath
                    Local or network path to .p12 used to sign the JWT token, requires certPswd to also be specified

                .PARAMETER certPswd
                    Password to access the private key in the .p12, requires certPath to also be specified

                .PARAMETER certObj
                    Certificate object that will be used to sign the JWT token

                .PARAMETER RSA
                    provide the System.Security.Cryptography.RSACryptoServiceProvider object directly that will be used to sign the JWT token

                .PARAMETER iss
                    This is the Google Service account address

                .PARAMETER scope
                    The API scopes to be included in the request. Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"

                .EXAMPLE
                    Get-GOAuthTokenService -scope "https://www.googleapis.com/auth/spreadsheets" -certPath "C:\users\$env:username\Desktop\googleSheets.p12" -certPswd 'notasecret' -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
                    Generates an access token using the given certificate file and password

                .EXAMPLE
                    Get-GOAuthTokenService -rsa $rsaSecurityObject -scope "https://www.googleapis.com/auth/spreadsheets" -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
                    Generates an access token using the given rsa object

                .EXAMPLE
                    Get-GOAuthTokenService -certObj $GoogleCert -scope "https://www.googleapis.com/auth/spreadsheets" -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
                    Generates an access token using the given certificate object

            #>
            [CmdletBinding()]
            Param
            (
                [Parameter(Mandatory)]
                [string]$iss,

                [Parameter(Mandatory)]
                [string]$scope,

                [Parameter(Mandatory,ParameterSetName='CertificateFile')]
                [string]$certPath,

                [Parameter(Mandatory,ParameterSetName='CertificateFile')]
                [string]$certPswd,

                [Parameter(Mandatory,ParameterSetName='CertificateObject')]
                [System.Security.Cryptography.X509Certificates.X509Certificate2]$certObj,

                [Parameter(Mandatory,ParameterSetName='RSA')]
                [System.Security.Cryptography.RSACryptoServiceProvider]$rsa

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
                switch ($PSCmdlet.ParameterSetName) {
                    'CertificateFile' {
                        Write-Verbose "Assembling RSA object based on given certificate file and password"
                        $googleCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath, $certPswd,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable )
                        $rsaPrivate = $googleCert.PrivateKey
                        $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
                        $null = $rsa.ImportParameters($rsaPrivate.ExportParameters($true))
                    }
                    'CertificateObject' {
                        Write-Verbose "Assembling RSA object based on given certificate object"
                        $rsaPrivate = $certObj.PrivateKey
                        $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
                        $null = $rsa.ImportParameters($rsaPrivate.ExportParameters($true))
                    }
                    'RSA' {
                        Write-Verbose "Using given RSA object as is"
                    }
                    Default {
                        throw "Unknown parameter set"
                    }
                }

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

    #region Get-GOAuthTokenUser
        function Get-GOAuthTokenUser
        {
            <#
                .Synopsis
                    Get Valid OAuth Token.

                .DESCRIPTION
                    The access token is good for an hour, the refresh token is mostly permanent and can be used to get a new access token without having to reauthenticate.

                .PARAMETER appKey
                    The google project App Key

                .PARAMETER appSecret
                    The google project application secret

                .PARAMETER projectID
                    The google project ID

                .PARAMETER redirectUri
                    An https project redirect. Can be anything as long as https

                .PARAMETER refreshToken
                    A refresh token if refreshing

                .PARAMATER scope
                    The API scopes to be included in the request. Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"

                .EXAMPLE
                    Get-GOAuthTokenUser -appKey $appKey -appSecret $appSecret -projectID $projectID -redirectUri $redirectUri -scope $scope

                .EXAMPLE
                    Get-GOAuthTokenUser -appKey $appKey -appSecret $appSecret -projectID $projectID -redirectUri $redirectUri -scope $scope -refreshToken $refreshToken

                .NOTES
                    Requires GUI with Internet Explorer to get first token.
            #>
            [CmdletBinding()]
            [OutputType([array])]
            Param
            (
                [Parameter(Mandatory)]
                [string]$appKey,

                [Parameter(Mandatory)]
                [string]$appSecret,

                [Parameter(Mandatory)]
                [string]$projectID,

                [Parameter(Mandatory)]
                [string]$redirectUri,

                [string]$refreshToken,

                [Parameter(Mandatory)]
                [string]$scope

            )

            Begin
            {
                $requestUri = "https://accounts.google.com/o/oauth2/token"
            }
            Process
            {
                if(!($refreshToken))
                {
                    ### Get the authorization code - IE Popup and user interaction section
                    $auth_string = "https://accounts.google.com/o/oauth2/auth?scope=$scope&response_type=code&redirect_uri=$redirectUri&client_id=$appKey&access_type=offline&approval_prompt=force"
                    $ie = New-Object -comObject InternetExplorer.Application
                    $ie.visible = $true
                    $null = $ie.navigate($auth_string)

                    #Wait for user interaction in IE, manual approval
                    do{Start-Sleep 1}until($ie.LocationURL -match 'code=([^&]*)')
                    $null = $ie.LocationURL -match 'code=([^&]*)'
                    $authorizationCode = $matches[1]
                    $null = $ie.Quit()

                    # exchange the authorization code for a refresh token and access token
                    $requestBody = "code=$authorizationCode&client_id=$appKey&client_secret=$appSecret&grant_type=authorization_code&redirect_uri=$redirectUri"

                    $response = Invoke-RestMethod -Method Post -Uri $requestUri -ContentType "application/x-www-form-urlencoded" -Body $requestBody
                }
                else
                {
                    # Exchange the refresh token for new tokens
                    $requestBody = "refresh_token=$refreshToken&client_id=$appKey&client_secret=$appSecret&grant_type=refresh_token"
                    $response = Invoke-RestMethod -Method Post -Uri $requestUri -ContentType "application/x-www-form-urlencoded" -Body $requestBody
                    Add-Member -InputObject $response -NotePropertyName refreshToken -NotePropertyValue $refreshToken
                }
            }
            End
            {
                # add alias for backwards compatability
                Add-Member -InputObject $response -MemberType AliasProperty -Name accesstoken -Value access_token
                return $response
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
                        if ($sheet[$row].count -gt ($column)) {
                            $h.$Name = $Sheet[$Row][$Column]
                        } else {
                            $h.$Name = ""
                        }
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
        $Index = (0..($data.count -1) | where-object {$Data[$_].$columnKey -eq $query})

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

        $srcSheetIndex = ($allSheetProperties | where-object {$_.title -eq $sourceSheetName}).sheetID
        $dstSheetIndex = ($allSheetProperties | where-object {$_.title -eq $destinationSheetName}).sheetID

        $method = 'POST'
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID"+":batchUpdate"
        $ContentType = "application/json"


        ## cutPaste row to row
        $values = @{"cutPaste"=@{"source"=@{"sheetId"=$srcSheetIndex;"startRowIndex"=$startRow;"endRowIndex"=$rowIndex};"destination"=@{"sheetId"=$dstSheetIndex;"rowIndex"=$destinationRow};"pasteType"="PASTE_NORMAL"}}
        $JSON = @{"requests"=$values} |ConvertTo-Json -Depth 20



        Invoke-RestMethod -Method $method -Uri $uri -Body $json -ContentType $ContentType -Headers @{"Authorization"="Bearer $accessToken"}

    }

    End{}
}

function New-GSheetSpreadSheet
{
    <#
        .Synopsis
            Create a new Google SpreadSheet.

        .DESCRIPTION
            Create a new Google SpreadSheet.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER properties
            Alternatively, the properties that can be set are extensive. Cell color, formatting etc.  If you use this you MUST include @{properties=@{title='mY sheet'}} |convertto-json
            at a minimum.  More details at https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create

        .PARAMETER title
            Use this in the simplest case to just create a new sheet with a Title/name

        .EXAMPLE
            Create-GSheet -properties $properties -accessToken $accessToken

        .EXAMPLE
            create-GSheet -title 'My sheet' -accessToken $accessToken

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(ParameterSetName='properties')]
        [array]$properties,

        [Parameter(ParameterSetName='title')]
        [string]$title
    )

    Begin
    {
        If (!$properties)
            {
                $properties = @{properties=@{title=$title}} |convertto-json
            }

        $uri = "https://sheets.googleapis.com/v4/spreadsheets"
    }

    Process
    {
        Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }

    End{}
}

function Remove-GSheetSheet
{
    <#
        .Synopsis
            Removes a sheet from a spreadsheet based on sheetID

        .DESCRIPTION
            This function will delete an individual sheet.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER sheetName
            Name of sheet to delete

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE
            Remove-GSheetSheet -accessToken $accessToken -sheetName 'Name to delete' -spreadSheetID $spreadSheetID

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
        $sheetID = Get-GSheetSheetID -accessToken $accessToken -sheetName $sheetName -spreadSheetID $spreadSheetID
        $properties = @{requests=@(@{deleteSheet=@{sheetId=$sheetID}})} |convertto-json -Depth 10
        $suffix = "$spreadSheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
        $data = Invoke-RestMethod -Method Post -Uri $uri -Body $properties -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End
    {
    return([array]$data)
    }
}

function Remove-GSheetSpreadSheet
{
    <#
        .Synopsis
            Delete a SpreadSheet

        .DESCRIPTION
            Uses the google File Drive API to delete a file.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER fileID
            ID for the target file/spreadSheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE
            Remove-GSheetSpreadSheet -accessToken $accessToken -spreadSheetID $spreadSheetID
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        #[Alias("spreadSheetID")]
        [Parameter(Mandatory)]
        [string]$fileID
    )

    Begin{}
    Process
    {
        $uri = "https://www.googleapis.com/drive/v3/files/$fileID"
        Invoke-RestMethod -Method Delete -Uri $uri -Headers @{"Authorization"="Bearer $accessToken"}
    }
    End{}
}

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

            [Parameter(Mandatory)]
            [int]$startIndex,

            [Parameter(Mandatory)]
            [int]$endIndex,

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
            if ($startIndex -eq $endIndex){$endIndex++}
        }

        Process
        {
            $request = @{"deleteDimension" = @{"range" = @{"sheetId" = $sheetID; "dimension" = $dimension; "startIndex" = $startIndex; "endIndex" = $endIndex}}}
            $json = @{requests=@($request)} | ConvertTo-Json -Depth 20
            $suffix = "$spreadSheetID" + ":batchUpdate"
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
            write-verbose -Message $json
            Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
        }

        End{}
    }
#endregion
function Set-GSheetColumnWidth
{
    <#
        .Synopsis
            Set the width of a column on a sheet

        .DESCRIPTION
            This function calls the bulk update method to set column dimensions to 'autoResize'.

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER numberOfColumns
            An optional parameter to specify how many columns to autosize. Default to 26

        .PARAMETER sheetName
            Name of sheet in spreadSheet

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .EXAMPLE
            Set-GSheetColumnWidth -spreadSheetID $id -sheetName 'Sheet1' -accessToken $token -numberOfColumns ($property.count)

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [string]$numberOfColumns = '26',

        [Parameter(Mandatory)]
        [string]$sheetName,

        [Parameter(Mandatory)]
        [string]$spreadSheetID
    )

    Begin
    {
        $sheetID = Get-GSheetSheetID -accessToken $accessToken -spreadSheetID $spreadSheetID -sheetName $sheetName
        $json = @{requests=@(@{autoResizeDimensions=@{dimensions=@{sheetId=$sheetID;dimension='COLUMNS';startIndex='0';endIndex='26'}}})} |ConvertTo-Json -Depth 20
        $suffix = "$spreadSheetID" + ":batchUpdate"
        $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
    }

    Process
    {
        Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }

    End{}
}

function Set-GSheetData
{
    <#
        .Synopsis
            Set values in sheet in specific cell locations or append data to a sheet

        .DESCRIPTION
            Set json data values on a sheet in specific cell locations or append data to a sheet

        .PARAMETER accessToken
            access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

        .PARAMETER append
            Switch option to append data. See rangeA1 if not appending

        .PARAMETER rangeA1
            Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx . The dimensions of the $values you put in MUST fit within this range

        .PARAMETER sheetName
            Name of sheet to set data in

        .PARAMETER spreadSheetID
            ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

        .PARAMETER valueInputOption
            Default to RAW. Optionally, you can specify if you want it processed as a formula and so forth.

        .PARAMETER values
            The values to write to the sheet. This should be an array list.  Each list array represents one ROW on the sheet.

        .EXAMPLE
            Set-GSheetData -accessToken $accessToken -rangeA1 'A1:B2' -sheetName 'My Sheet' -spreadSheetID $spreadSheetID -values @(@("a","b"),@("c","D"))

        .EXAMPLE
            Set-GSheetData -accessToken $accessToken -append 'Append'-sheetName 'My Sheet' -spreadSheetID $spreadSheetID -values $arrayValues

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(ParameterSetName='Append')]
        [switch]$append,

        [Parameter(ParameterSetName='set')]
        [string]$rangeA1,

        [Parameter(Mandatory)]
        [string]$sheetName,

        [Parameter(Mandatory)]
        [string]$spreadSheetID,

        [string]$valueInputOption = 'RAW',

        [Parameter(Mandatory)]
        [System.Collections.ArrayList]$values
    )

    Begin
    {
        if ($append)
            {
                $method = 'POST'
                $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID/values/$sheetName"+":append?valueInputOption=$valueInputOption"
            }
        else
            {
                $method = 'PUT'
                $uri = "https://sheets.googleapis.com/v4/spreadsheets/$spreadSheetID/values/$sheetName!$rangeA1"+"?valueInputOption=$valueInputOption"
            }
    }

    Process
    {
        $json = @{values=$values} | ConvertTo-Json
        Invoke-RestMethod -Method $method -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
    }

    End{}
}

#region Set-GSheetDropDownList
    function Set-GSheetDropDownList
    {
        <#
            .Synopsis
                Set Drop Down List Data validation on cells in a column

            .DESCRIPTION
                Set Drop Down List Data validation on cells in a column

            .PARAMETER accessToken
                access token used for authentication.  Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

            .PARAMETER columnIndex
                Index of column to update

            .PARAMETER startRowIndex
                Index of row to start updating

            .PARAMETER endRowIndex
                Index of last row to update

            .PARAMETER values
                List of string values that the use can chose from in an array.  Google API only takes strings

            .PARAMETER inputMessage
                A message to show the user when adding data to the cell.

            .PARAMETER showCustomUi
                True if the UI should be customized based on the kind of condition. If true, $values will show a dropdown.

            .PARAMETER sheetName
                Name of sheet in spreadSheet

            .PARAMETER spreadSheetID
                ID for the target Spreadsheet.  This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

            .EXAMPLE Set-GSheetDropDownList -accessToken $accessToken -startRowIndex 1 -endRowIndex 10 -columnIndex 9 -sheetName 'Sheet1' -spreadSheetID $spreadSheetID -inputMessage "Must be one of 'Public','Private Restricted','Private, Highly-Restricted'" -values @('Public','Private Restricted','Private, Highly-Restricted')


        #>
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory)]
            [string]$accessToken,

            [Parameter(Mandatory)]
            [int]$startRowIndex,

            [Parameter(Mandatory)]
            [int]$endRowIndex,

            [Parameter(Mandatory)]
            [int]$columnIndex,

            [Parameter(Mandatory)]
            [string]$sheetName,

            [Parameter(Mandatory)]
            [string]$spreadSheetID,

            [Parameter(Mandatory)]
            [string[]]$values,

            [string]$inputMessage,

            [boolean]$showCustomUi=$true

        )

        Begin
        {
            $sheetID = Get-GSheetSheetID -accessToken $accessToken -spreadSheetID $spreadSheetID -sheetName $sheetName
            $valueList = [Collections.ArrayList]@()
            foreach ($value in $values){$valueList.Add(@{userEnteredValue=$value})}
            $validation = @{
                setDataValidation = @{
                    range=@{sheetId = $sheetID;startRowIndex=$startRowIndex;endRowIndex=$endRowIndex;startColumnIndex=$columnIndex;endColumnIndex=($columnIndex+1)};
                    rule=@{
                        condition = @{
                            type= 'ONE_OF_LIST';
                            values=$valueList
                        };
                        inputMessage=$inputMessage;strict=$true;showCustomUi=$showCustomUi
                    }
                }
            }
            $json = @{requests=@($validation)} | ConvertTo-Json -Depth 20
            $suffix = "$spreadSheetID" + ":batchUpdate"
            $uri = "https://sheets.googleapis.com/v4/spreadsheets/$suffix"
            $json
            $uri
        }

        Process
        {
            Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json" -Headers @{"Authorization"="Bearer $accessToken"}
        }

        End{}
    }
#endregion
#endregion

#region App Scripts and Projects
function Get-gAppScriptsProject
{
    <#
        .Synopsis
            Get information about a google App Script project

        .DESCRIPTION
            Provide scriptID to get google project info for Google Apps Script

        .PARAMETER accessToken
            OAuth Access Token for authorization.

        .PARAMETER scriptID
            The scriptID to query. Found as a project property.

        .EXAMPLE
            Get-gAppScriptsProject -scriptID $scriptID -accessToken $accessToken
        .OUTPUTS

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$scriptID
    )

    Begin
    {
        $uri = "https://script.googleapis.com/v1/projects/$scriptID"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        Invoke-RestMethod -Method get -Uri $uri -Headers $headers -UseBasicParsing
    }
    End{}
}

function Get-gAppScriptsProjectContent
{
    <#
        .Synopsis
            Get content  about a google App Script project

        .DESCRIPTION
            Provide scriptID to get google project content for Google Apps Script

        .PARAMETER accessToken
            OAuth Access Token for authorization.

        .PARAMETER scriptID
            The scriptID to query. Found as a project property.

        .EXAMPLE
            Get-gAppScriptsProjectContent -scriptID $scriptID -accessToken $accessToken

        .OUTPUTS
            Provides the actual scripts of the project.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$scriptID
    )

    Begin
    {
        $uri = "https://script.googleapis.com/v1/projects/$scriptID/content"
        $headers = @{"Authorization"="Bearer $accessToken"}
    }

    Process
    {
        Invoke-RestMethod -Method get -Uri $uri -Headers $headers -UseBasicParsing
    }
    End{}
}

function send-gAppsScriptFunction
{
    <#
        .Synopsis
            Send parameters to a Google App Scripts Function by name

        .DESCRIPTION
            Call and send parameters to a Google App Scripts Function by name.

        .PARAMETER accessToken
            OAuth Access Token for authorization.

        .PARAMETER scriptID
            The scriptID associated to the Google App Scripts project.

        .PARAMETER requestBody
            The PSCustom Object or hashtable to be send to the Google App Scripts API. Will be converted to JSON string.

            Example requestBody
                $requestbody = @{
                    "function"= 'DeleteTrigger';
                    "parameters"=@(
                    formID123fjn4
                    );
                    "devMode"= $false
                }

        .PARAMETER function
                The google App Script function to be called.

                Function name is CASE Sensitive.

        .PARAMETER parameter
                Optional paramteter to pass through to the google function.

        .PARAMETER devMode
                Switch flag for dev mode. Run the last saved script instead of last published.

        .EXAMPLE
            Execute a function by providing your own hashtable.
            send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -requestBody $requestbody

        .EXAMPLE
            Execute a function with no parameters.
            send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function CreateForm

        .EXAMPLE
            Execute a function by name with a paramter to pass into the Google App Script function.
            send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function DeleteTrigger -parameter formID1234fjdnejf

        .EXAMPLE
            Execute a function by name with a paramter to pass into the Google App Script function using Dev mode (Last saved script version instead of latest published)
            send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function DeleteTrigger -parameter formID1234fjdnejf -DevMode true


        .EXAMPLE
            test.gs script in project

            function DeleteTrigger(formid){
                triggers = ScriptApp.getProjectTriggers()
                for (var i = 0; i < triggers.length; i++) {
                    if (triggers[i].getTriggerSourceId() == formid) {
                    ScriptApp.deleteTrigger(triggers[i])
                    Logger.log("deleted " + formid)
                    }
                }
            }

            Sample $RequestBody for above Function in .gs
            $requestbody = @{
                    "function"= 'DeleteTrigger';
                    "parameters"=@(
                    $item
                    );
                    "devMode"= 'false'
                }

        .OUTPUTS
            The following may come up if you did not publish the App Script as API Executable.
            "error": {
            "code": 404,
            "message": "Requested entity was not found.",
            "status": "NOT_FOUND"

        .OUTPUTS
                done response
                ---- --------
                True @{@type=type.googleapis.com/google.apps.script.v1.ExecutionResponse}

        .OUTPUTS
                done error
                ---- -----
                True @{code=3; message=ScriptError; details=System.Object[]}
                $return.error.details.errorMessage
                Script function not found: ShowProperties

}
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$accessToken,

        [Parameter(Mandatory)]
        [string]$scriptID,

        [Parameter(Mandatory, ParameterSetName = 'PSObject')]
        [validateScript({$_.GetType().Fullname -in 'System.Management.Automation.PSCustomObject','System.Collections.Hashtable'})]
        $requestBody,

        [Parameter(Mandatory, ParameterSetName = 'Body Options')]
        [string]$function,

        [Parameter(ParameterSetName = 'Body Options')]
        [string]$parameter,

        [Parameter(ParameterSetName = 'Body Options')]
        [switch]$devMode
    )

    Begin
    {
        $uri = "https://script.googleapis.com/v1/scripts/$scriptID"+":run"
        $headers = @{"Authorization"="Bearer $accessToken"}

        If($requestbody){
            $body = $requestbody |convertto-json
        }

        If($function){
            $body = @{
                "function"= $function;
                "parameters"=@(
                $parameter
                );
                "devMode"= [bool]$devMode
            } |convertto-json
        }
    }

    Process
    {
        $return = Invoke-RestMethod -Method post -Uri $uri -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    }
    End{
        return $return
    }
}
#endregion

Export-ModuleMember -Function *
