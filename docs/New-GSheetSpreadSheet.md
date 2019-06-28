---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# New-GSheetSpreadSheet

## SYNOPSIS
Create a new Google SpreadSheet.

## SYNTAX

### properties
```
New-GSheetSpreadSheet -accessToken <String> [-properties <Array>] [<CommonParameters>]
```

### title
```
New-GSheetSpreadSheet -accessToken <String> [-title <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a new Google SpreadSheet.

## EXAMPLES

### EXAMPLE 1
```
Create-GSheet -properties $properties -accessToken $accessToken
```

### EXAMPLE 2
```
create-GSheet -title 'My sheet' -accessToken $accessToken
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

### -properties
Alternatively, the properties that can be set are extensive.
Cell color, formatting etc. 
If you use this you MUST include @{properties=@{title='mY sheet'}} |convertto-json
at a minimum. 
More details at https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create

```yaml
Type: Array
Parameter Sets: properties
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -title
Use this in the simplest case to just create a new sheet with a Title/name

```yaml
Type: String
Parameter Sets: title
Aliases:

Required: False
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
