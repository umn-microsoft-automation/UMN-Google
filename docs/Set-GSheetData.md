---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Set-GSheetData

## SYNOPSIS
Set values in sheet in specific cell locations or append data to a sheet

## SYNTAX

### Append
```
Set-GSheetData -accessToken <String> [-append] -sheetName <String> -spreadSheetID <String>
 [-valueInputOption <String>] -values <ArrayList> [<CommonParameters>]
```

### set
```
Set-GSheetData -accessToken <String> [-rangeA1 <String>] -sheetName <String> -spreadSheetID <String>
 [-valueInputOption <String>] -values <ArrayList> [<CommonParameters>]
```

## DESCRIPTION
Set json data values on a sheet in specific cell locations or append data to a sheet

## EXAMPLES

### EXAMPLE 1
```
Set-GSheetData -accessToken $accessToken -rangeA1 'A1:B2' -sheetName 'My Sheet' -spreadSheetID $spreadSheetID -values @(@("a","b"),@("c","D"))
```

### EXAMPLE 2
```
Set-GSheetData -accessToken $accessToken -append 'Append'-sheetName 'My Sheet' -spreadSheetID $spreadSheetID -values $arrayValues
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -append
Switch option to append data.
See rangeA1 if not appending

```yaml
Type: SwitchParameter
Parameter Sets: Append
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -rangeA1
Range in A1 notation https://msdn.microsoft.com/en-us/library/bb211395(v=office.12).aspx .
The dimensions of the $values you put in MUST fit within this range

```yaml
Type: String
Parameter Sets: set
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sheetName
Name of sheet to set data in

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

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

### -valueInputOption
Default to RAW.
Optionally, you can specify if you want it processed as a formula and so forth.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: RAW
Accept pipeline input: False
Accept wildcard characters: False
```

### -values
The values to write to the sheet.
This should be an array list. 
Each list array represents one ROW on the sheet.

```yaml
Type: ArrayList
Parameter Sets: (All)
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
