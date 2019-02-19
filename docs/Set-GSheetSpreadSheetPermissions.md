---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version: 
schema: 2.0.0
---

# Set-GSheetSpreadSheetPermissions

## SYNOPSIS
Set Permissions on Google Sheet

## SYNTAX

```
Set-GSheetSpreadSheetPermissions [-emailAddress] <String> [-spreadSheetID] <String> [[-role] <String>]
 [[-type] <String>] [-accessToken] <String> [[-sendNotificationEmail] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Set Permissions on Google Sheet

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
set-GSheetPermissions -emailAddress 'user@email.com' -role writer -sheetID $sheetID -type user
```

## PARAMETERS

### -emailAddress
Email address of the user or group to grant permissions to

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
The sheetID to apply permissions to. 
This is returned when a new sheet is created or use Get-GSheetID

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

### -role
Role to assign, select from 'writer','reader','commenter'

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: Writer
Accept pipeline input: False
Accept wildcard characters: False
```

### -type
This refers to the emailAddress, is it a user or a group

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -accessToken
access token used for authentication. 
Get from Get-GOAuthTokenUser or Get-GOAuthTokenService

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

### -sendNotificationEmail
Boolean response on sending email notification.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

