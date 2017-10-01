[CmdletBinding()]
Param(
	[string]$Target = "Default",
    [Parameter(Position=0,Mandatory=$false,ValueFromRemainingArguments=$true)]
    [string[]]$ScriptArgs
)

Write-Host "Running Cake bootstrapper with target '$Target'..."
try
{
	$pwd = $MyInvocation.MyCommand.Path
	Write-Host $pwd
	Invoke-Expression "& ./bootstrapper.ps1 -target $Target $ScriptArgs"
}
catch 
{
	throw $_.Exception.Message
}
exit $LASTEXITCODE