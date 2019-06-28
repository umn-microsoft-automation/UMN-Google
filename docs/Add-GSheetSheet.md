---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Add-GSheetSheet

## SYNOPSIS
Add named sheets to an existing spreadSheet file.

## SYNTAX

```
Add-GSheetSheet [-accessToken] <String> [-sheetName] <String> [-spreadSheetID] <String> [<CommonParameters>]
```

## DESCRIPTION
This function will add a specified sheet name to a google spreadsheet.

## EXAMPLES

### EXAMPLE 1
```
Add-GSheetSheet -accessToken $accessToken -sheetName 'NewName' -spreadSheetID $spreadSheetID
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

### -sheetName
Name to apply to new sheet

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

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

## NOTES

## RELATED LINKS
