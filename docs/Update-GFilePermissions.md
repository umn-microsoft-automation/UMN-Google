---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Update-GFilePermissions

## SYNOPSIS
Update Permissions on Google File

## SYNTAX

```
Update-GFilePermissions [-accessToken] <String> [-fileID] <String> [-permissionID] <String> [[-role] <String>]
 [[-supportTeamDrives] <String>] [[-transferOwnership] <String>] [<CommonParameters>]
```

## DESCRIPTION
Update Permissions on Google File

## EXAMPLES

### EXAMPLE 1
```
Update-GFilePermissions -emailAddress 'user@email.com' -role writer -fileID $sheetID -permissionID 'ID of the permission'
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

### -permissionID
The permission ID of the entiry with permissions.
Sett Get-GFilePermissions to get a lsit

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
Role to assign, select from 'writer','reader','commenter','Owner','Organizer'

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

### -supportTeamDrives
Boolean for TeamDrive Support

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -transferOwnership
Update ownership of file to permission ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This is usefull for changing ownership.
You cannot change ownership from non-domain to domain.

## RELATED LINKS
