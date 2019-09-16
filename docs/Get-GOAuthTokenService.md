---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GOAuthTokenService

## SYNOPSIS
Get google auth 2.0 token for a service account

## SYNTAX

### CertificateFile
```
Get-GOAuthTokenService -iss <String> -scope <String> -certPath <String> -certPswd <String> [<CommonParameters>]
```

### CertificateObject
```
Get-GOAuthTokenService -iss <String> -scope <String> -certObj <X509Certificate2> [<CommonParameters>]
```

### RSA
```
Get-GOAuthTokenService -iss <String> -scope <String> -rsa <RSACryptoServiceProvider> [<CommonParameters>]
```

## DESCRIPTION
This is used in server-server OAuth token generation
This function will use a certificate to generate an RSA token that will be used to sign a JWT token which is needed to generate the access key.
The certificate can be specified as file path and password to read the certificate from.
It can also be specified as an object, such was when running in Automation that will return a certificate object
The RSA token can also be specified directly if needed instead of generating it from a certificate

## EXAMPLES

### EXAMPLE 1
```
Get-GOAuthTokenService -scope "https://www.googleapis.com/auth/spreadsheets" -certPath "C:\users\$env:username\Desktop\googleSheets.p12" -certPswd 'notasecret' -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
```

Generates an access token using the given certificate file and password

### EXAMPLE 2
```
Get-GOAuthTokenService -rsa $rsaSecurityObject -scope "https://www.googleapis.com/auth/spreadsheets" -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
```

Generates an access token using the given rsa object

### EXAMPLE 3
```
Get-GOAuthTokenService -certObj $GoogleCert -scope "https://www.googleapis.com/auth/spreadsheets" -iss "serviceAccount@googleProjectName.iam.gserviceaccount.com"
```

Generates an access token using the given certificate object

## PARAMETERS

### -iss
This is the Google Service account address

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -scope
The API scopes to be included in the request.
Space delimited, "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certPath
Local or network path to .p12 used to sign the JWT token, requires certPswd to also be specified

```yaml
Type: String
Parameter Sets: CertificateFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certPswd
Password to access the private key in the .p12, requires certPath to also be specified

```yaml
Type: String
Parameter Sets: CertificateFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certObj
Certificate object that will be used to sign the JWT token

```yaml
Type: X509Certificate2
Parameter Sets: CertificateObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -rsa
provide the System.Security.Cryptography.RSACryptoServiceProvider object directly that will be used to sign the JWT token

```yaml
Type: RSACryptoServiceProvider
Parameter Sets: RSA
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
