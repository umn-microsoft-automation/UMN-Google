function New-GOAuthTokenCode {
    param (
        [Parameter(Mandatory)]
        [string]$RedirectURI
    )
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("$RedirectURI/")
    $listener.Start()
    $Context = $listener.GetContext()
    $URL = $Context.Request.Url
    $Content = 
@"
<html>
<head>
<title>You may close this page</title>
</head>
<body>
You may close this page and return to your Powershell terminal
</body>
</html>
"@
    $Encoding = [system.Text.Encoding]::UTF8
    $Content = $Encoding.GetBytes($Content)
    $Context.Response.ContentType = "text/html"
    $Context.Response.ContentLength64 = $Content.Length
    $Context.Response.OutputStream.Write($Content, 0, $Content.Length)
    $Context.Response.Close()
    $listener.Stop()
    $null = $URL -match 'code=([^&]*)'
    $matches[1]
}
