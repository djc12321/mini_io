# 并行 IO 实验任务 2 说明

本工程面向 Vivado/SDK 2018.2 + MicroBlaze + Nexys4 DDR，完成“独立开关/按键输入，LED 输出”的并行 IO 实验任务 2。

工程包含两份软件实现：

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

打开 PowerShell，进入仓库根目录后运行：

```powershell
cd <repo root>
<Xilinx SDK>\bin\xsct.bat xsct_download_polling.tcl
<Xilinx SDK>\bin\xsct.bat xsct_download_fast_interrupt.tcl
```

如果 SDK 安装在默认位置，则 `<Xilinx SDK>` 通常是 `C:\Xilinx\SDK\2018.2`。

测试流程：

1. 拨动开关但不按 BTNC/BTNR，LED 不应更新保存值。
2. 设置开关为第一个数，按 BTNC，LED 显示该值。
3. 设置开关为第二个数，按 BTNR，LED 显示该值。
4. 按 BTNU，LED 显示两个保存值相加后的低 16 位。
5. 按 BTND，LED 显示两个保存值相乘后的低 16 位。
