---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Clear-GSheetSheet

## SYNOPSIS
Clear all data and leave formatting intact for a sheet from a spreadsheet based on sheetID

## SYNTAX

```
Clear-GSheetSheet [-accessToken] <String> [-sheetName] <String> [-spreadSheetID] <String> [<CommonParameters>]
```

## DESCRIPTION
This function will delete data from a sheet

## EXAMPLES

### EXAMPLE 1
```
$pageID = 0  ## using pageID to differentiate from sheetID --
```

In this case, index 0 is the actual sheetID per the API and will be cleared.

$sheetID = ## the id number of the file/spreadsheet

clear-gsheet -pageID $pageID -sheetID $sheetID -accessToken $accessToken

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
Name of sheet to clear

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
