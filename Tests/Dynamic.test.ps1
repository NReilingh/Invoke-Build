
<#
.Synopsis
	Tests dynamic parameters.
#>

# fixed v2.4.5 cmdlet binding
task DynamicExampleParam {
	Set-Content z.ps1 {
		param(
			[Parameter()]
			$Platform = 'Win32',
			$Configuration = 'Release'
		)
		task . {
			$d.Platform = $Platform
			$d.Configuration = $Configuration
		}
	}

	$d = @{}
	Invoke-Build . z.ps1
	equals $d.Platform Win32
	equals $d.Configuration Release

	$d = @{}
	Invoke-Build . z.ps1 -Platform x64 -Configuration Debug
	equals $d.Platform x64
	equals $d.Configuration Debug

	Remove-Item z.ps1
}

task DynamicConflictParam {
	Set-Content z.ps1 {
		param(
			$Own1,
			$File
		)
	}

	($r = try {Invoke-Build . z.ps1} catch {$_})
	equals "$r" "Script uses reserved parameter 'File'."

	Remove-Item z.ps1
}

# 3.0.0 Explicitly throw 'Invalid script syntax?'
task DynamicSyntaxError {
	Set-Content z.ps1 @'
param($p1)
{
'@

	($r = try { Invoke-Build . z.ps1 -p1 v1 } catch {$_})
	equals "$r" 'Invalid script syntax?'

	Remove-Item z.ps1
}

task DynamicMissingScript {
	Set-Location $env:TEMP

	# missing custom
	$$ = try {Invoke-Build . missing.ps1} catch {$_}
	assert ($$ -like "Missing script '*\missing.ps1'.")
	assert ($$.InvocationInfo.Line -like '*{Invoke-Build . missing.ps1}*')

	# missing default
	$$ = try {Invoke-Build} catch {$_}
	assert ($$ -like 'Missing default script.')
	assert ($$.InvocationInfo.Line -like '*{Invoke-Build}*')
}
