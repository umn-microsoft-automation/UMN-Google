---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version: 
schema: 2.0.0
---

# Remove-GSheetSpreadSheet

## SYNOPSIS
Delete a SpreadSheet

## SYNTAX

```
Remove-GSheetSpreadSheet [-accessToken] <String> [-fileID] <String>
```

## DESCRIPTION
Uses the google File Drive API to delete a file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-GSheetSpreadSheet -accessToken $accessToken -spreadSheetID $spreadSheetID
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

### -fileID
ID for the target file/spreadSheet. 
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

