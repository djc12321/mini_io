# mini_io

Vivado/SDK 2018.2 + MicroBlaze + Nexys4 DDR 的“并行 IO 实验任务 2”工程。任务要求使用 16 位独立开关作为输入、5 个独立按键作为控制、16 位 LED 作为输出，并分别用程序控制方式和快速中断方式实现。

## 已完成内容

- 硬件：在原 MicroBlaze 系统中加入 `axi_gpio_in`、`axi_gpio_led` 和 `axi_intc_0`。
- 程序控制方式：循环读取按键，根据 BTNC/BTNR/BTNU/BTND 完成读入、加法、乘法和 LED 输出。
- 快速中断方式：只使能按键通道中断，按键触发后进入中断服务函数处理任务。
- 已在 Nexys4 DDR 开发板上测试通过两种方式。

## 目录说明

| 路径 | 说明 |
| --- | --- |
| `mini_io.xpr` | Vivado 2018.2 工程入口 |
| `mini_io.srcs/` | Block Design、IP 配置和 wrapper |
| `mini_io.sdk/mini_io/src/main.c` | 程序控制/轮询版源码 |
| `mini_io.sdk/mini_io_fast_interrupt/src/main.c` | 快速中断版源码 |
| `mini_io.runs/impl_1/design_1_wrapper.bit` | 已验证 bitstream |
| `mini_io.sdk/mini_io/Debug/mini_io_polling.elf` | 已验证程序控制版 ELF |
| `mini_io.sdk/mini_io_fast_interrupt/Debug/mini_io_fast_interrupt.elf` | 已验证快速中断版 ELF |
| `PARALLEL_IO_TASK2_README.md` | 实验任务说明和测试步骤 |

## 环境要求

- Vivado 2018.2
- Xilinx SDK 2018.2
- Digilent Nexys4 DDR board files
- Nexys4 DDR 开发板，USB-JTAG 正常连接

本仓库的脚本默认假设 SDK 安装在 `C:\Xilinx\SDK\2018.2`。如果安装路径不同，请在 PowerShell 中先设置：

```powershell
$env:XILINX_SDK = "你的SDK路径"
```

## 快速使用

1. 克隆仓库后进入根目录。

   ```powershell
   git clone git@github.com:djc12321/mini_io.git
   cd mini_io
   ```

2. 用 Vivado 2018.2 打开 `mini_io.xpr`。

3. 可选：检查工程能否正常打开。

   ```tcl
   source vivado_check_project.tcl
   ```

4. 如果 Vivado 提示工程路径异常或需要重建工程入口，在 Vivado Tcl Console 中运行：

   ```tcl
   source vivado_recreate_project.tcl
   ```

5. 如果需要重新生成硬件描述文件：

   ```tcl
   source vivado_export_hwdef.tcl
   ```

6. 如果需要重新生成 bitstream：

   ```tcl
   source vivado_build_bitstream.tcl
   ```

## 重新编译软件

关闭 SDK/Eclipse 后，在 PowerShell 中运行：

```powershell
<Xilinx SDK>\bin\xsct.bat sdk_rebuild.tcl
.\build_parallel_io_elfs.ps1
```

默认安装路径示例：

```powershell
C:\Xilinx\SDK\2018.2\bin\xsct.bat sdk_rebuild.tcl
.\build_parallel_io_elfs.ps1
```

## 下载到开发板

开发板连接 USB-JTAG 并上电后，进入仓库根目录。

查看 JTAG 目标：

```powershell
<Xilinx SDK>\bin\xsct.bat xsct_list_targets.tcl
```

下载程序控制版：

```powershell
<Xilinx SDK>\bin\xsct.bat xsct_download_polling.tcl
```

下载快速中断版：

```powershell
<Xilinx SDK>\bin\xsct.bat xsct_download_fast_interrupt.tcl
```

两个下载脚本都会先烧录 `mini_io.runs/impl_1/design_1_wrapper.bit`，再下载对应 ELF。

## 实验功能

| 按键 | 功能 |
| --- | --- |
| BTNC | 读入 16 位开关值，保存为第一个无符号数，并显示到 LED |
| BTNR | 读入 16 位开关值，保存为第二个无符号数，并显示到 LED |
| BTNU | 对两个保存值做无符号加法，LED 显示低 16 位 |
| BTND | 对两个保存值做无符号乘法，LED 显示低 16 位 |

没有按下 BTNC/BTNR 时，单独拨动开关不会更新保存值。

## 可复现性说明

- Tcl 和 XSCT 脚本使用脚本所在目录作为工程根目录，不依赖作者本机路径。
- `mini_io.xpr` 已改为相对工程路径，并已用 Vivado 2018.2 验证可打开。
- `build_parallel_io_elfs.ps1` 支持通过 `XILINX_SDK` 环境变量指定 SDK 路径。
- `.gitignore` 排除了 Vivado/SDK 缓存、日志、BSP 编译产物和实现中间文件。
- 仓库保留已验证的 bitstream 和两个 ELF，便于直接下载测试。
