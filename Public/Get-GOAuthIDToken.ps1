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

    Begin {}
    Process
    {
        $scope = $scope.Replace(' ','%20')
        $auth_string = "https://accounts.google.com/o/oauth2/auth"
        $auth_string += "?scope=$scope"
        $auth_string += "&response_type=token%20id_token"
        $auth_string += "&redirect_uri=$redirectUri"
        $auth_string += "&client_id=$clientID"
        $auth_string += "&approval_prompt=force"
        Write-Host "Please open this link on the machine you're running this cmdlet on"
        Write-Host $auth_string

        $id_token = New-GOAuthTokenCode -RedirectURI $redirectUri -matchString 'code=([^&]*)'
        return $id_token
    }
    End{}
}
