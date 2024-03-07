---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GOAuthTokenDevice

## SYNOPSIS
Get Valid OAuth Token.
Provides login URL for any browser to allow for lack of web driver.

## SYNTAX

```
Get-GOAuthTokenDevice [-appKey] <String> [-appSecret] <String> [-projectID] <String> [-redirectUri] <String>
 [-scope] <String> [[-refreshToken] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-GOAuthTokenDevice -appKey $appKey -redirectUri $redirectUri -scope $scope
```

### EXAMPLE 2
```
Get-GOAuthTokenDevice -appKey $appKey -appSecret $appSecret -projectID $projectID -redirectUri $redirectUri -scope $scope -refreshToken $refreshToken
```

## PARAMETERS

### -appKey
The google project App Key

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

### -appSecret
The google project application secret

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

### -projectID
The google project ID

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

### -redirectUri
An https project redirect.
Can be anything as long as https

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -refreshToken
A refresh token if refreshing

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
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
Requires 2nd device with browser.
User interaction required.

## RELATED LINKS
