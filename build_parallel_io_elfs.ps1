$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SdkRoot = $env:XILINX_SDK
if ([string]::IsNullOrWhiteSpace($SdkRoot)) {
    $SdkRoot = "C:\Xilinx\SDK\2018.2"
}

$Gcc = Join-Path $SdkRoot "gnu\microblaze\nt\bin\mb-gcc.exe"
$Size = Join-Path $SdkRoot "gnu\microblaze\nt\bin\mb-size.exe"
$Bsp = Join-Path $Root "mini_io.sdk\mini_io_bsp\microblaze_0"
$Include = Join-Path $Bsp "include"
$LibXil = Join-Path $Bsp "lib\libxil.a"
$LibGloss = Join-Path $Bsp "lib\libgloss.a"
$Linker = Join-Path $Root "mini_io.sdk\mini_io\src\lscript.ld"

if (!(Test-Path -LiteralPath $Gcc)) {
    throw "Cannot find mb-gcc.exe. Set XILINX_SDK to your SDK 2018.2 path, for example C:\Xilinx\SDK\2018.2."
}
if (!(Test-Path -LiteralPath $LibXil)) {
    throw "Cannot find libxil.a. Rebuild mini_io_bsp in SDK first, or run sdk_rebuild.tcl after closing SDK."
}

New-Item -ItemType Directory -Force -Path (Join-Path $Root "mini_io.sdk\mini_io\Debug") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root "mini_io.sdk\mini_io_fast_interrupt\Debug") | Out-Null

$CommonArgs = @(
    "-Wall", "-Wextra", "-O0", "-g3",
    "-I$Include",
    "-mlittle-endian", "-mxl-soft-mul", "-mcpu=v10.0"
)

$PollingSrc = Join-Path $Root "mini_io.sdk\mini_io\src\main.c"
$PollingElf = Join-Path $Root "mini_io.sdk\mini_io\Debug\mini_io_polling.elf"
& $Gcc @CommonArgs $PollingSrc $LibXil $LibGloss "-Wl,-T" "-Wl,$Linker" "-o" $PollingElf
if ($LASTEXITCODE -ne 0) { throw "Failed to build polling ELF." }

$FastSrc = Join-Path $Root "mini_io.sdk\mini_io_fast_interrupt\src\main.c"
$FastElf = Join-Path $Root "mini_io.sdk\mini_io_fast_interrupt\Debug\mini_io_fast_interrupt.elf"
& $Gcc @CommonArgs $FastSrc $LibXil $LibGloss "-Wl,-T" "-Wl,$Linker" "-o" $FastElf
if ($LASTEXITCODE -ne 0) { throw "Failed to build fast-interrupt ELF." }

& $Size $PollingElf
& $Size $FastElf
