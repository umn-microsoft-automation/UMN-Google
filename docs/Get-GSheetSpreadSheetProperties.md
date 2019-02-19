---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version: 
schema: 2.0.0
---

# Get-GSheetSpreadSheetProperties

## SYNOPSIS
Get the properties of a SpreadSheet

## SYNTAX

```
Get-GSheetSpreadSheetProperties [-accessToken] <String> [-spreadSheetID] <String>
```

## DESCRIPTION
Get all properties of a SpreadSheet

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```

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

### -spreadSheetID
ID for the target Spreadsheet. 
This is returned when a new sheet is created or use Get-GSheetSpreadSheetID

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

