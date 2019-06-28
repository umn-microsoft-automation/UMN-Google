---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Set-GSheetColumnWidth

## SYNOPSIS
Set the width of a column on a sheet

## SYNTAX

```
Set-GSheetColumnWidth [-accessToken] <String> [[-numberOfColumns] <String>] [-sheetName] <String>
 [-spreadSheetID] <String> [<CommonParameters>]
```

## DESCRIPTION
This function calls the bulk update method to set column dimensions to 'autoResize'.

## EXAMPLES

### EXAMPLE 1
```
Set-GSheetColumnWidth -spreadSheetID $id -sheetName 'Sheet1' -accessToken $token -numberOfColumns ($property.count)
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

### -numberOfColumns
An optional parameter to specify how many columns to autosize.
Default to 26

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 26
Accept pipeline input: False
Accept wildcard characters: False
```

### -sheetName
Name of sheet in spreadSheet

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
