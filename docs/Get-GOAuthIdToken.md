---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GOAuthIdToken

## SYNOPSIS
Get Valid OAuth ID token for a user.

## SYNTAX

```
Get-GOAuthIdToken [-clientID] <String> [-redirectUri] <String> [-scope] <String> [<CommonParameters>]
```

## DESCRIPTION
The ID token is signed by google to represent a user https://developers.google.com/identity/sign-in/web/backend-auth.

## EXAMPLES

### EXAMPLE 1
```
Get-GOAuthIdToken -clientID $clientID -scope $scope -redirectUri $redirectURI
```

## PARAMETERS

### -clientID
Client ID within app project

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -redirectUri
An https project redirect.
Can be anything as long as https

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array
## NOTES
Requires GUI with Internet Explorer to get first token.

## RELATED LINKS
