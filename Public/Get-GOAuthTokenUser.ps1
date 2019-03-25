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

        .PARAMETER redirectUri
            An https project redirect. Can be anything as long as https, only needed when generating a new token

        .PARAMETER refreshToken
            A refresh token if refreshing

        .PARAMETER scope
            The API scopes to be included in the request. Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"
            Only needed when generating a new token
        
        .EXAMPLE
            Get-GOAuthTokenUser -appKey $appKey -appSecret $appSecret -redirectUri $redirectUri -scope $scope
                
        .EXAMPLE
            Get-GOAuthTokenUser -appKey $appKey -appSecret $appSecret -redirectUri $redirectUri -scope $scope -refreshToken $refreshToken
            
        .NOTES
            Requires GUI with Internet Explorer to get first token.
            If this code doesn't work to generate a new token, use the following URL to manually create it
            https://lazyadmin.nl/it/connect-to-google-api-with-powershell/
            That will generate a refresh token that can be used with this cmdlet
    #>
    [CmdletBinding()]
    [OutputType([array])]
    Param
    (
        [Parameter(Mandatory)]
        [string]$appKey,

        [Parameter(Mandatory)]
        [string]$appSecret,
        
        [Parameter(Mandatory,ParameterSetName="NewToken")]
        [string]$redirectUri,

        [Parameter(Mandatory,ParameterSetName="Refresh")]
        [string]$refreshToken,

        [Parameter(Mandatory,ParameterSetName="NewToken")]
        [string]$scope

    )

    Begin
    {
        $requestUri = "https://www.googleapis.com/oauth2/v4/token"
    }
    Process
    {

        if($PSCmdlet.ParameterSetName -eq "NewToken")
        {
            #Write-Warning "This probably won't work"
            #Write-Warning "See this URL on how go manually generate a refresh token"
            #Write-Warning "Once you have a refresh token you can use the cmdlet to retreive a new access token"
            #Write-Warning "https://lazyadmin.nl/it/connect-to-google-api-with-powershell/"
            ### Get the authorization code - IE Popup and user interaction section
            $scope = $scope.Replace(' ','%20')
            $auth_string = "https://accounts.google.com/o/oauth2/v2/auth?client_id=$appKey&redirect_uri=$redirectUri&scope=$scope&access_type=offline&response_type=code&prompt=consent"
            #$auth_string = "https://accounts.google.com/o/oauth2/auth?scope=$scope&response_type=code&redirect_uri=$redirectUri&client_id=$appKey&access_type=offline&approval_prompt=force"
            Write-Host "please open $auth_string in your browser"
            $authorizationCode = New-GOAuthTokenCode -RedirectURI $redirectUri

            # exchange the authorization code for a refresh token and access token
            #$requestBody = "code=$authorizationCode&client_id=$appKey&client_secret=$appSecret&grant_type=authorization_code&redirect_uri=$redirectUri"
            $body = @{
                code=$authorizationCode;
                client_id=$appKey;
                client_secret=$appSecret;
                redirect_uri=$redirectUri;
                grant_type="authorization_code"; # Fixed value
               };
 
            $response = Invoke-RestMethod -Method Post -Uri $requestUri -Body $body

            $props = @{
                accessToken = $response.access_token
                refreshToken = $response.refresh_token
            }
        }

        else
        { 
            # Exchange the refresh token for new tokens
            $requestBody = "refresh_token=$refreshToken&client_id=$appKey&client_secret=$appSecret&grant_type=refresh_token"
 
            $response = Invoke-RestMethod -Method Post -Uri $requestUri -ContentType "application/x-www-form-urlencoded" -Body $requestBody
            $props = @{
                accessToken = $response.access_token
                refreshToken = $refreshToken
            }
        }
        
    }
    End
    {
        return new-object psobject -Property $props
    }
}

#endregion
