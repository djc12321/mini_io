$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Split-Path -Parent $MyInvocation.MyCommand.Path)).Path

$CacheDirs = @(
    (Join-Path $Root ".Xil"),
    (Join-Path $Root "mini_io.sdk\webtalk")
)

foreach ($Dir in $CacheDirs) {
    if (Test-Path -LiteralPath $Dir) {
        $Resolved = (Resolve-Path -LiteralPath $Dir).Path
        if ($Resolved.StartsWith($Root)) {
            Remove-Item -LiteralPath $Resolved -Recurse -Force
        }
    }
}

Get-ChildItem -LiteralPath $Root -File |
    Where-Object { $_.Name -like "vivado*.log" -or $_.Name -like "vivado*.jou" } |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }

$SdkLog = Join-Path $Root "mini_io.sdk\SDK.log"
if (Test-Path -LiteralPath $SdkLog) {
    Remove-Item -LiteralPath $SdkLog -Force
}

Write-Host "Cleaned transient Vivado/SDK files."
