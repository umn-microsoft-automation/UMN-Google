---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Get-GFilePermissions

## SYNOPSIS
Get Permissions on Google Drive File

## SYNTAX

```
Get-GFilePermissions [-accessToken] <String> [-fileID] <String> [[-permissionID] <String>] [-DefaultFields]
 [<CommonParameters>]
```

## DESCRIPTION
Get Permission ID list on Google File

## EXAMPLES

### EXAMPLE 1
```
Get-GFilePermissions -accessToken $accessToken -fileID 'String of File ID' -permissionID 'String of Permission ID'
```

## PARAMETERS

### -accessToken
OAuth Access Token for authorization.

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
The fileID to query. 
This is returned when a new file is created.

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
If specified will query only that specific permission for the file, rather than all permissions

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultFields
If specified, will only query "default" rather than querying all fields of Permission object. 
Added primarily for backwards compatibility

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### If only a fileID, this will return an object with two properties, the first is kind, and will always be drive#permissionList
### The second will be permissions, which includes the individual permissions objects.  Each one of these will have the same format as if a specific PermissionID was requested
### If a permissionID is also specified, only that specific permission will be returned.  It will have a kind property of drive#permission as well as all properties of that specific permission.
### More details on the permission object available here: https://developers.google.com/drive/api/v2/reference/permissions
## NOTES

## RELATED LINKS
