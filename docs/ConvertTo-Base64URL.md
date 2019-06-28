---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# ConvertTo-Base64URL

## SYNOPSIS
convert text or byte array to URL friendly Base64

## SYNTAX

### Bytes
```
ConvertTo-Base64URL [-Bytes <Byte[]>] [<CommonParameters>]
```

### String
```
ConvertTo-Base64URL [-text <String>] [<CommonParameters>]
```

## DESCRIPTION
Used for preparing the JWT token to a proper format.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-Base64URL -text $headerJSON
```

### EXAMPLE 2
```
ConvertTo-Base64URL -Bytes $rsa.SignData($toSign,"SHA256")
```

## PARAMETERS

### -Bytes
The bytes to be converted

```yaml
Type: Byte[]
Parameter Sets: Bytes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -text
The text to be converted

```yaml
Type: String
Parameter Sets: String
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
