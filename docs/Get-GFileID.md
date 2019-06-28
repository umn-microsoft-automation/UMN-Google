---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GFileID

## SYNOPSIS
Get a Google File ID.

## SYNTAX

```
Get-GFileID [-accessToken] <String> [-fileName] <String> [[-mimetype] <String>] [<CommonParameters>]
```

## DESCRIPTION
Provide a case sensative file name to the function to get back the gFileID used in many other API calls.

## EXAMPLES

### EXAMPLE 1
```
Get-GFileID -accessToken $accessToken -fileName 'Name of some file'
```

## PARAMETERS

### -accessToken
access token used for authentication. 
Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

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

### -fileName
Name of file to retrive ID for.
Case sensitive

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

### -mimetype
Use this to specify a specific mimetype. 
See google docs https://developers.google.com/drive/api/v3/search-parameters

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Travis Sobeck

## RELATED LINKS
