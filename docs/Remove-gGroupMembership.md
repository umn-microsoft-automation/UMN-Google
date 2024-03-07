---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Remove-gGroupMembership

## SYNOPSIS
Remove member to google group based on group ID

## SYNTAX

```
Remove-gGroupMembership [-accessToken] <String> [-membershipName] <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Provide email address of new member to group

## EXAMPLES

### EXAMPLE 1
```
Remove-gGroupMembership -accessToken $accessToken -groupID 'hfiou08uf3' -member 'user@domain.com'
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

### -membershipName
The memberhsip name in format groups/groupID/memberships/membershipsID, such as 'groups/03ep43zb2bc7vzi/memberships/111396014913618483233'

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

### Success of group member remove
## NOTES

## RELATED LINKS
