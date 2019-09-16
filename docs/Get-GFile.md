---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GFile

## SYNOPSIS
Download a Google File.

## SYNTAX

### fileName
```
Get-GFile -accessToken <String> [-fileName <String>] -outFilePath <String> [<CommonParameters>]
```

### fileID
```
Get-GFile -accessToken <String> [-fileID <String>] -outFilePath <String> [<CommonParameters>]
```

## DESCRIPTION
Download a Google File based on a case sensative file or fileID.

## EXAMPLES

### EXAMPLE 1
```
Get-GFile -accessToken $accessToken -fileName 'Name of some file'
```

### EXAMPLE 2
```
Get-GFile -accessToken $accessToken -fileID 'ID of some file'
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

### -fileName
Name of file to retrive ID for.
Case sensitive

```yaml
Type: String
Parameter Sets: fileName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -fileID
File ID. 
Can be gotten from Get-GFileID

```yaml
Type: String
Parameter Sets: fileID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -outFilePath
Path to output file including file name.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Travis Sobeck

## RELATED LINKS
