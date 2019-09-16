---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Move-GSheetData

## SYNOPSIS
Move data around between sheets in a spreadSheet.

## SYNTAX

```
Move-GSheetData [-accessToken] <String> [-columnKey] <String> [-destinationSheetName] <String>
 [-query] <String> [-sourceSheetName] <String> [-spreadSheetID] <String> [<CommonParameters>]
```

## DESCRIPTION
This is a cut and paste between sheets in a spreadsheet.
The function will find the row index based on search criteria, and copy/paste between the sheets provided.

## EXAMPLES

### EXAMPLE 1
```
Move-GSheetData -accessToken $accessToken -columnKey 'Column Header -destinationSheetName 'New Sheet!' -query 'Cell Content' -sourceSheetName 'Old Sheet' -spreadSheetID $spreadSheetID
```

## PARAMETERS

### -accessToken
oAuth access token used for authentication. 
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

### -columnKey
Row 0 column value.
A key to search for data by.
$columnKey = 'Column header'

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

### -destinationSheetName
{{ Fill destinationSheetName Description }}

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

### -query
Value to be queried for in specified column (see columnKey) $query = 'Cell Content'

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

### -sourceSheetName
{{ Fill sourceSheetName Description }}

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
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
