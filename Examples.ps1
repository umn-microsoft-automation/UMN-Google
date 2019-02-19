## Getting the user access Token
# The first 4 variables you'll get from https://console.developers.google.com/apis/dashboard after creating a project
$projectID = "";$app_key = "" 
$app_Secret = "";$redirectURI = ""
$scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file"
$tokens = Get-GOAuthTokenUser -projectID $projectID -appKey $app_key -appSecret $app_secret -scope $scope -redirectUri $redirectURI -refreshToken $tokens.refreshToken
$accessToken = $tokens.accesstoken

## Service token
$scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file"
$certPath = "<path to .p12 certificate file"
$iss = '' #this is the service account eamil it will look like  <something>@<projectname>.iam.gserviceaccount.com
$certPswd = '' #Password for certificate
$accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $iss

# Tokens are good for 1 hour after that rerun $accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $iss
# or $tokens = Get-GOAuthTokenUser -projectID $projectID -appKey $app_key -appSecret $app_secret -scope $scope -redirectUri $redirectURI -refreshToken $tokens.refreshToken
# $accessToken = $tokens.accesstoken
# depending on which one you used.