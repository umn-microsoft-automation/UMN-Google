---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GOAuthTokenService

## SYNOPSIS
{{Fill in the Synopsis}}

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
{{Fill in the Description}}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -iss
{{Fill iss Description}}

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
{{Fill scope Description}}

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
{{Fill certPath Description}}

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
{{Fill certPswd Description}}

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
Optional, provide the System.Security.Cryptography.RSACryptoServiceProvider object. Such as when retrived/prepared from a KeyVault.

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

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
