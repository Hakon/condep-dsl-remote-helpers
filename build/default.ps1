properties {
	$pwd = Split-Path $psake.build_script_file	
	$build_directory  = "$pwd\output\condep-dsl-remote-helpers"
	$configuration = "Release"
	$releaseNotes = ""
	$nuget = "$pwd\..\tools\nuget.exe"
}
 
include .\..\tools\psake_ext.ps1

function GetNugetAssemblyVersion($assemblyPath) {
    
    if(Test-Path Env:\APPVEYOR_BUILD_VERSION)
    {
        #When building on appveyor, set correct beta number.
        $appVeyorBuildVersion = $env:APPVEYOR_BUILD_VERSION
        
        $version = $appVeyorBuildVersion.Split('-') | Select-Object -First 1
        $betaNumber = $appVeyorBuildVersion.Split('-') | Select-Object -Last 1 | % {$_.replace("beta","")}

        switch ($betaNumber.length) 
        { 
            1 {$betaNumber = $betaNumber.Insert(0, '0').Insert(0, '0').Insert(0, '0').Insert(0, '0')} 
            2 {$betaNumber = $betaNumber.Insert(0, '0').Insert(0, '0').Insert(0, '0')} 
            3 {$betaNumber = $betaNumber.Insert(0, '0').Insert(0, '0')}
            4 {$betaNumber = $betaNumber.Insert(0, '0')}                
            default {$betaNumber = $betaNumber}
        }

        return "$version-beta$betaNumber"
    }
    else
    {
        $versionInfo = Get-Item $assemblyPath | % versioninfo
        return "$($versionInfo.FileVersion)"
    }
}

task default -depends Build-All, Pack-All
task ci -depends Build-All, Pack-All

task Build-All -depends Clean, Build, Create-BuildSpec-ConDep-Dsl-Remote-Helpers
task Pack-All -depends Pack-ConDep-Dsl-Remote-Helpers

task Build {
	Exec { msbuild "$pwd\..\src\condep-dsl-remote-helpers.sln" /t:Build /p:Configuration=$configuration /p:OutDir=$build_directory /p:GenerateProjectSpecificOutputFolder=true}
}

task Clean {
	Write-Host "Cleaning Build output"  -ForegroundColor Green
	Remove-Item $build_directory -Force -Recurse -ErrorAction SilentlyContinue
}

task Create-BuildSpec-ConDep-Dsl-Remote-Helpers {
	Generate-Nuspec-File `
		-file "$build_directory\condep.dsl.remote.helpers.$(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Remote.Helpers\ConDep.Dsl.Remote.Helpers.dll).nuspec" `
		-version $(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Remote.Helpers\ConDep.Dsl.Remote.Helpers.dll) `
		-id "ConDep.Dsl.Remote.Helpers" `
		-title "ConDep.Dsl.Remote.Helpers" `
		-licenseUrl "http://www.con-dep.net/license/" `
		-projectUrl "http://www.con-dep.net/" `
		-description "Remote helpers used by ConDep operations server side." `
		-iconUrl "https://raw.github.com/condep/ConDep/master/images/ConDepNugetLogo.png" `
		-releaseNotes "$releaseNotes" `
		-tags "Continuous Deployment Delivery Infrastructure WebDeploy Deploy msdeploy IIS automation powershell remote aws azure" `
		-files @(
			@{ Path="ConDep.Dsl.Remote.Helpers\ConDep.Dsl.Remote.Helpers.dll"; Target="lib/net45"}
		)
}

task Pack-ConDep-Dsl-Remote-Helpers {
	Exec { & $nuget pack "$build_directory\condep.dsl.remote.helpers.$(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Remote.Helpers\ConDep.Dsl.Remote.Helpers.dll).nuspec" -OutputDirectory "$build_directory" }
}