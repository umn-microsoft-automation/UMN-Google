---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Set-GFilePermissions

## SYNOPSIS
Set Permissions on Google File

## SYNTAX

```
Set-GFilePermissions [-accessToken] <String> [-emailAddress] <String> [-fileID] <String> [[-role] <String>]
 [[-sendNotificationEmail] <Boolean>] [[-type] <String>] [<CommonParameters>]
```

## DESCRIPTION
For use with any google drive file ID

## EXAMPLES

### EXAMPLE 1
```
set-GFilePermissions -emailAddress 'user@email.com' -role writer -sheetID $sheetID -type user
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

### -emailAddress
Email address of the user or group to grant permissions to

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

### -fileID
The fileID to apply permissions to.

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

### -role
Role to assign, select from 'writer','reader','commenter'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Writer
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
Position: 5
Default value: False
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
Requires drive and drive.file API scope.

## RELATED LINKS
