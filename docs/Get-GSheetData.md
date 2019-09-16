---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GSheetData

## SYNOPSIS
Basic function for retrieving data from a specific Sheet in a Google SpreadSheet.

## SYNTAX

```
Get-GSheetData [-accessToken] <String> [-cell] <String> [[-rangeA1] <String>] [-sheetName] <String>
 [-spreadSheetID] <String> [[-valueRenderOption] <String>] [<CommonParameters>]
```

## DESCRIPTION
Basic function for retrieving data from a specific Sheet in a Google SpreadSheet.

## EXAMPLES

### EXAMPLE 1
```
Get-GSheetData -accessToken $accessToken -cell 'AllData' -sheetName 'Sheet1' -spreadSheetID $spreadSheetID
```

### EXAMPLE 2
```
Get-GSheetData -accessToken $accessToken -cell 'Range' -rangeA1 'A0:F77' -sheetName 'Sheet1' -spreadSheetID $spreadSheetID
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

### -cell
Required switch for getting all data, or a subset of cells.

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

### -rangeA1
Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx.
The dimensions of the $values you put in MUST fit within this range

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

### -sheetName
Name of sheet to data from

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

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

### -valueRenderOption
How the data is renderd.
Switch option from formatted to unformatted data or 'formula'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: FORMATTED_VALUE
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
