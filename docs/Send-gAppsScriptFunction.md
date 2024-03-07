---
external help file: UMN-Google-help.xml
Module Name: UMN-Google
online version:
schema: 2.0.0
---

# Send-gAppsScriptFunction

## SYNOPSIS
Send parameters to a Google App Scripts Function by name

## SYNTAX

### PSObject
```
Send-gAppsScriptFunction -accessToken <String> -scriptID <String> -requestBody <Object>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Body Options
```
Send-gAppsScriptFunction -accessToken <String> -scriptID <String> -function <String> [-parameter <String>]
 [-devMode] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Call and send parameters to a Google App Scripts Function by name.

## EXAMPLES

### EXAMPLE 1
```
Execute a function by providing your own hashtable.
send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -requestBody $requestbody
```

### EXAMPLE 2
```
Execute a function with no parameters.
send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function CreateForm
```

### EXAMPLE 3
```
Execute a function by name with a paramter to pass into the Google App Script function.
send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function DeleteTrigger -parameter formID1234fjdnejf
```

### EXAMPLE 4
```
Execute a function by name with a paramter to pass into the Google App Script function using Dev mode (Last saved script version instead of latest published)
send-gAppsScriptFunction -accessToken $accessToken -scriptID $scriptID -function DeleteTrigger -parameter formID1234fjdnejf -DevMode true
```

### EXAMPLE 5
```
test.gs script in project
```

function DeleteTrigger(formid){
    triggers = ScriptApp.getProjectTriggers()
    for (var i = 0; i \< triggers.length; i++) {
        if (triggers\[i\].getTriggerSourceId() == formid) {
        ScriptApp.deleteTrigger(triggers\[i\])
        Logger.log("deleted " + formid)
        }
    }
}

Sample $RequestBody for above Function in .gs
$requestbody = @{
        "function"= 'DeleteTrigger';
        "parameters"=@(
        $item
        );
        "devMode"= 'false'
    }

## PARAMETERS

### -accessToken
OAuth Access Token for authorization.

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

### -scriptID
The scriptID associated to the Google App Scripts project.

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

### -requestBody
The PSCustom Object or hashtable to be send to the Google App Scripts API.
Will be converted to JSON string.

Example requestBody
    $requestbody = @{
        "function"= 'DeleteTrigger';
        "parameters"=@(
        formID123fjn4
        );
        "devMode"= $false
    }

```yaml
Type: Object
Parameter Sets: PSObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -function
The google App Script function to be called.

Function name is CASE Sensitive.

```yaml
Type: String
Parameter Sets: Body Options
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -parameter
Optional paramteter to pass through to the google function.

```yaml
Type: String
Parameter Sets: Body Options
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -devMode
Switch flag for dev mode.
Run the last saved script instead of last published.

```yaml
Type: SwitchParameter
Parameter Sets: Body Options
Aliases:

Required: False
Position: Named
Default value: False
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

### The following may come up if you did not publish the App Script as API Executable.
### "error": {
### "code": 404,
### "message": "Requested entity was not found.",
### "status": "NOT_FOUND"
### done response
### ---- --------
### True @{@type=type.googleapis.com/google.apps.script.v1.ExecutionResponse}
### done error
### ---- -----
### True @{code=3; message=ScriptError; details=System.Object[]}
### $return.error.details.errorMessage
### Script function not found: ShowProperties
### }
## NOTES

## RELATED LINKS
