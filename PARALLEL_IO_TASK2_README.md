# 并行 IO 实验任务 2 说明

本工程面向 Vivado/SDK 2018.2 + MicroBlaze + Nexys4 DDR。现在已经补齐开关、按键、LED 的 AXI GPIO 连接，并提供两份软件：

- 程序控制方式：`mini_io.sdk/mini_io/src/main.c`
- 快速中断方式：`mini_io.sdk/mini_io_fast_interrupt/src/main.c`

## 关键生成物

- Bitstream：`mini_io.runs/impl_1/design_1_wrapper.bit`
- 程序控制版 ELF：`mini_io.sdk/mini_io/Debug/mini_io_polling.elf`
- 快速中断版 ELF：`mini_io.sdk/mini_io_fast_interrupt/Debug/mini_io_fast_interrupt.elf`

## 硬件连接

| IP | 地址 | 通道 | 板卡接口 | 方向 |
| --- | --- | --- | --- | --- |
| `axi_gpio_in` | `0x40000000` | Channel 1 | `dip_switches_16bits` | 输入 |
| `axi_gpio_in` | `0x40000000` | Channel 2 | `push_buttons_5bits` | 输入 |
| `axi_gpio_led` | `0x40010000` | Channel 1 | `led_16bits` | 输出 |
| `axi_intc_0` | `0x41200000` | input 0 | `axi_gpio_in/ip2intc_irpt` | 快速中断 |

按键位定义：bit0 BTNC，bit1 BTNU，bit2 BTNL，bit3 BTNR，bit4 BTND。

## 板上测试

开发板连接 USB-JTAG 且上电后，在 PowerShell 中二选一：

```powershell
cd D:\file\github_pro\mini_io
C:\Xilinx\SDK\2018.2\bin\xsct.bat xsct_download_polling.tcl
C:\Xilinx\SDK\2018.2\bin\xsct.bat xsct_download_fast_interrupt.tcl
```

测试流程：

1. 拨动开关但不按 BTNC/BTNR，LED 不应更新保存值。
2. 设置开关为第一个数，按 BTNC，LED 显示该值。
3. 设置开关为第二个数，按 BTNR，LED 显示该值。
4. 按 BTNU，LED 显示两个保存值相加后的低 16 位。
5. 按 BTND，LED 显示两个保存值相乘后的低 16 位。
