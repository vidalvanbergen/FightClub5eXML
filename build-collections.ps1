#Requires -Version 5.1
<#
.SYNOPSIS
  Compile FightClub5eXML collections into compendiums (parallel).
.DESCRIPTION
  Cross-platform equivalent of build-collections.sh. XSLT transformations are
  run in parallel (up to one job per logical CPU) using xsltproc.
.PARAMETER CollectionsDir
  Directory containing the collection XML files. Defaults to .\Collections.
.PARAMETER Merge
  Path to merge.xslt. Defaults to .\Utilities\merge.xslt.
.PARAMETER Schema
  Path to compendium.xsd, used by -Validate. Defaults to .\Utilities\compendium.xsd.
.PARAMETER OutDir
  Output directory for compiled compendiums. Defaults to .\Compendiums.
.PARAMETER RemoveVersionTag
  Remove ' [5.5e]' from the generated compendiums (same as -5.5e).
.PARAMETER Android
  Put item detail (rarity/attunement) into item descriptions. Prefixes output with [ANDROID]_.
.PARAMETER Validate
  Validate output XML against the schema.
.PARAMETER Help
  Show this help.
.PARAMETER CollectionNames
  Optional list of collection file names (or wildcards) to compile. Defaults to all *.xml.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$CollectionsDir,
    [string]$Merge,
    [string]$Schema,
    [string]$OutDir,
    [switch]$RemoveVersionTag,
    [switch]$Android,
    [switch]$Validate,
    [switch]$Help,
    [int]$MaxJobs = 0,
    [int]$MemoryPerJobMB = 700,
    [int]$MinFreeMemoryMB = 512,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CollectionNames
)

# Resolve the repo root here rather than in the parameter defaults: $PSScriptRoot
# is not always populated while parameter defaults are evaluated (notably on
# Windows PowerShell 5.1), which made Join-Path fail with an empty path.
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
if (-not $CollectionsDir) { $CollectionsDir = Join-Path $ScriptDir 'Collections' }
if (-not $Merge) { $Merge = Join-Path $ScriptDir 'Utilities/merge.xslt' }
if (-not $Schema) { $Schema = Join-Path $ScriptDir 'Utilities/compendium.xsd' }
if (-not $OutDir) { $OutDir = Join-Path $ScriptDir 'Compendiums' }

function Show-Help {
    @"
Usage: build-collections.ps1 [-RemoveVersionTag] [-Android] [-Validate] [-Help] [collection_names...]

  -RemoveVersionTag  Remove ' [5.5e]' from the generated compendiums.
  -Android           Put item detail (rarity and attunement requirements) into item descriptions.
  -Validate          Validate output XML against the schema (requires xmllint).
  -MaxJobs N         Maximum parallel xsltproc jobs. 0 = auto (CPU count, capped by memory). Default: 0.
  -MemoryPerJobMB N  Estimated peak memory per xsltproc job, used to cap parallelism. Default: 700.
  -MinFreeMemoryMB N Keep at least this much physical memory free; new jobs pause below it. Default: 512.
  -Help              Display this help message.
  collection_names   Optional list of specific collections to compile (wildcards allowed).

If no collection names are provided, all XML files in '$CollectionsDir' will be processed.
"@ | Write-Host
}

function Get-AvailableMemoryMB {
    try {
        if ($env:OS -eq 'Windows_NT' -or $IsWindows) {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            return [int]($os.FreePhysicalMemory / 1024)
        }
        elseif (Test-Path -LiteralPath '/proc/meminfo') {
            $m = Select-String -LiteralPath '/proc/meminfo' -Pattern '^MemAvailable:\s+(\d+)' | Select-Object -First 1
            if ($m) { return [int]([int]$m.Matches[0].Groups[1].Value / 1024) }
        }
    }
    catch { }
    return -1
}

function Remove-VersionTag {
    param([Parameter(Mandatory)][string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    $new = [regex]::Replace($text, ' \[5\.5e\]', '')
    if ($new -ne $text) {
        [System.IO.File]::WriteAllText($Path, $new, (New-Object System.Text.UTF8Encoding($false)))
    }
}

function Test-Compendium {
    param([Parameter(Mandatory)][string]$Path)
    & xmllint --noout --schema $Schema $Path 2>&1 | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Start-Compile {
    param([Parameter(Mandatory)][System.IO.FileInfo]$File)
    $name = $File.Name
    if ($Android) { $name = '[ANDROID]_' + [System.IO.Path]::GetFileNameWithoutExtension($name) + '.xml' }
    $outPath = Join-Path $OutDir $name

    # Run xsltproc from the collection's own directory and pass the bare filename.
    # A relative base avoids libxml2's inability to resolve nested XInclude hrefs
    # against a Windows drive path ("Building relative URI failed").
    $xsltArgs = New-Object System.Collections.Generic.List[string]
    $xsltArgs.Add('--xinclude')
    if ($Android) { $xsltArgs.Add('--stringparam'); $xsltArgs.Add('android'); $xsltArgs.Add('true') }
    $xsltArgs.Add('-o'); $xsltArgs.Add($outPath); $xsltArgs.Add($Merge); $xsltArgs.Add($File.Name)

    # ProcessStartInfo.Arguments is a single command line (there is no ArgumentList
    # on .NET Framework), so quote any argument that contains whitespace.
    $quoted = foreach ($arg in $xsltArgs) {
        if ($arg -match '[\s"]') { '"' + ($arg -replace '"', '\"') + '"' } else { $arg }
    }

    # Use System.Diagnostics.Process rather than Start-Process -PassThru: the
    # latter does not reliably retain the handle on Windows PowerShell 5.1, so
    # ExitCode comes back empty and successful builds get reported as failures.
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'xsltproc'
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WorkingDirectory = $File.DirectoryName
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.Arguments = ($quoted -join ' ')

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $stdoutTask = $proc.StandardOutput.ReadToEndAsync()
    $stderrTask = $proc.StandardError.ReadToEndAsync()

    return [pscustomobject]@{
        Process    = $proc
        File       = $File
        Out        = $outPath
        Name       = $name
        StdoutTask = $stdoutTask
        StderrTask = $stderrTask
        Command    = "xsltproc $($psi.Arguments)  (cwd: $($File.DirectoryName))"
    }
}

if ($Help) { Show-Help; exit 0 }

if (-not (Get-Command xsltproc -ErrorAction SilentlyContinue)) {
    Write-Host "xsltproc not found. Install it (e.g. 'choco install xsltproc') and ensure it is on PATH." -ForegroundColor Red
    exit 1
}
if ($Validate -and -not (Get-Command xmllint -ErrorAction SilentlyContinue)) {
    Write-Host "xmllint not found (required for -Validate)." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -LiteralPath $CollectionsDir)) {
    Write-Host "Collections directory not found: $CollectionsDir" -ForegroundColor Red
    exit 1
}

# Resolve the set of collection files to compile
$files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
if (-not $CollectionNames) {
    Get-ChildItem -LiteralPath $CollectionsDir -Filter '*.xml' -File | Sort-Object Name | ForEach-Object { $files.Add($_) }
}
else {
    foreach ($n in $CollectionNames) {
        if ($n -match '[*?]') {
            # Split into directory + leaf and use -LiteralPath + -Filter rather than
            # a -Path wildcard, which is more reliable across PowerShell versions.
            $full = Join-Path $CollectionsDir $n
            $dir = Split-Path -Parent $full
            $leaf = Split-Path -Leaf $full
            Get-ChildItem -LiteralPath $dir -Filter $leaf -File -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object { $files.Add($_) }
        }
        elseif (Test-Path -LiteralPath (Join-Path $CollectionsDir $n)) {
            $files.Add((Get-Item -LiteralPath (Join-Path $CollectionsDir $n)))
        }
        else {
            Write-Host "Warning: '$n' does not exist, skipping." -ForegroundColor Yellow
        }
    }
}
if ($files.Count -eq 0) {
    Write-Host "No XML files to process." -ForegroundColor Red
    exit 1
}

Write-Host "Collections dir: $CollectionsDir"
Write-Host "Requested      : $(if ($CollectionNames) { $CollectionNames -join ', ' } else { '(all)' })"
Write-Host "Resolved       : $($files.Count) file(s)"

if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

# Determine parallelism: CPU count, optionally overridden and always capped by
# available physical memory so parallel jobs cannot exhaust RAM.
$cpuJobs = [Math]::Max(1, [Environment]::ProcessorCount)
$maxJobs = if ($MaxJobs -gt 0) { $MaxJobs } else { $cpuJobs }

$freeMemMB = Get-AvailableMemoryMB
if ($freeMemMB -ge 0) {
    $jobsByMemory = [Math]::Floor(($freeMemMB - $MinFreeMemoryMB) / [Math]::Max(1, $MemoryPerJobMB))
    if ($jobsByMemory -lt 1) { $jobsByMemory = 1 }
    if ($jobsByMemory -lt $maxJobs) {
        Write-Host "Available memory is ${freeMemMB} MiB; limiting to $jobsByMemory parallel job(s) (~${MemoryPerJobMB} MiB each)."
        $maxJobs = [int]$jobsByMemory
    }
}
Write-Host "Starting compilation using $maxJobs parallel job(s)."

$queue = New-Object System.Collections.Queue
foreach ($f in $files) { $queue.Enqueue($f) }

$running = New-Object System.Collections.ArrayList
$failures = 0
$clock = [System.Diagnostics.Stopwatch]::StartNew()
$lastMemCheck = 0
$memPaused = $false

while ($queue.Count -gt 0 -or $running.Count -gt 0) {
    # Harvest any finished jobs
    for ($i = $running.Count - 1; $i -ge 0; $i--) {
        $job = $running[$i]
        if (-not $job.Process.HasExited) { continue }

        $running.RemoveAt($i)
        try { $job.Process.WaitForExit() } catch { }

        $err = if ($job.StderrTask) { [string]$job.StderrTask.Result } else { '' }
        $out = if ($job.StdoutTask) { [string]$job.StdoutTask.Result } else { '' }
        $exitCode = $job.Process.ExitCode

        if ($exitCode -ne 0) {
            Write-Host "Failed to compile '$($job.File.Name)' (exit code $exitCode)" -ForegroundColor Red
            Write-Host "  command: $($job.Command)" -ForegroundColor DarkGray
            if ($err) { Write-Host "  stderr: $($err.Trim())" -ForegroundColor Red }
            if ($out) { Write-Host "  stdout: $($out.Trim())" -ForegroundColor Red }
            $failures++
            continue
        }

        Write-Host "> Created: '$($job.Name)'"

        if ($RemoveVersionTag) { Remove-VersionTag -Path $job.Out }

        if ($Validate -and -not (Test-Compendium -Path $job.Out)) {
            Write-Host "Validation failed for '$($job.Out)'" -ForegroundColor Red
            $failures++
        }

        # If filename contains '_5.5e' (and we are not stripping tags), also emit an [UNTAGGED] copy
        if (-not $RemoveVersionTag -and $job.Name -match '_5\.5e') {
            $untaggedName = [System.IO.Path]::GetFileNameWithoutExtension($job.Name) + '_[UNTAGGED].xml'
            $untaggedPath = Join-Path $OutDir $untaggedName
            Copy-Item -LiteralPath $job.Out -Destination $untaggedPath -Force
            Remove-VersionTag -Path $untaggedPath
            Write-Host "> Created: '$untaggedName'"

            if ($Validate -and -not (Test-Compendium -Path $untaggedPath)) {
                Write-Host "Validation failed for '$untaggedPath'" -ForegroundColor Red
                $failures++
            }
        }
    }

    # Refill the pool. Periodically re-check free memory and pause launching new
    # jobs if it drops below the reserve (running jobs are never killed).
    if ($freeMemMB -ge 0 -and $clock.ElapsedMilliseconds - $lastMemCheck -ge 2000) {
        $lastMemCheck = $clock.ElapsedMilliseconds
        $nowFree = Get-AvailableMemoryMB
        if ($nowFree -ge 0 -and $nowFree -lt $MinFreeMemoryMB) {
            if (-not $memPaused) {
                Write-Host "Low available memory (${nowFree} MiB); pausing new jobs until it recovers." -ForegroundColor Yellow
                $memPaused = $true
            }
        }
        elseif ($memPaused) {
            Write-Host "Memory recovered; resuming."
            $memPaused = $false
        }
    }

    while ($queue.Count -gt 0 -and $running.Count -lt $maxJobs) {
        if ($memPaused -and $running.Count -gt 0) { break }
        try {
            $running.Add((Start-Compile -File $queue.Dequeue())) | Out-Null
        }
        catch {
            Write-Host "Failed to launch xsltproc: $($_.Exception.Message)" -ForegroundColor Red
            $failures++
        }
    }

    if ($running.Count -gt 0) { Start-Sleep -Milliseconds 50 }
}

if ($failures -gt 0) {
    Write-Host "Compilation completed with $failures failure(s)." -ForegroundColor Red
    exit 1
}
Write-Host "Compilation completed!"
exit 0
