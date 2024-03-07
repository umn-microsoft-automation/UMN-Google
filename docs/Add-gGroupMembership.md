---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Add-gGroupMembership

## SYNOPSIS
Add member to google group based on group ID

## SYNTAX

```
Add-gGroupMembership [-accessToken] <String> [-groupID] <String> [-member] <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provide email address of new member to group - requires Cloud Identity API enabled on project

## EXAMPLES

### EXAMPLE 1
```
Add-gGroupMembership -accessToken $accessToken -groupID 'hfiou08uf3' -member 'user@domain.com'
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

### -groupID
The groupID of the group.
See get-gGroupID for reference.

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

### -member
The email address of the new member to add

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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

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

### Success of group member add
## NOTES

## RELATED LINKS
