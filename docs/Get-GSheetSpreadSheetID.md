---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GSheetSpreadSheetID

## SYNOPSIS
Get a spreadsheet ID.

## SYNTAX

```
Get-GSheetSpreadSheetID [-accessToken] <String> [-fileName] <String> [<CommonParameters>]
```

## DESCRIPTION
Provide a case sensative file name to the function to get back the sheetID used in many other API calls.
mimeTymes are split out to only retrieve spreadSheet IDs (no folders or other files)

## EXAMPLES

### EXAMPLE 1
```
Get-GSheetSpreadSheetID -accessToken $accessToken -fileName 'Name of some file'
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
Aliases: spreadSheetName

Required: True
Position: 2
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
