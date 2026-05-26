#include "sleep.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xparameters.h"

#define GPIO_DATA_OFFSET       0x00U
#define GPIO_TRI_OFFSET        0x04U
#define GPIO2_DATA_OFFSET      0x08U
#define GPIO2_TRI_OFFSET       0x0CU

#define SWITCH_MASK            0x0000FFFFU
#define LED_MASK               0x0000FFFFU
#define BUTTON_MASK            0x0000001FU

/*
 * Nexys4 DDR 的 push_buttons_5bits 按键位顺序：
 * bit0 对应 BTNC，bit1 对应 BTNU，bit2 对应 BTNL，
 * bit3 对应 BTNR，bit4 对应 BTND。
 */
#define BTN_C                  0x01U
#define BTN_U                  0x02U
#define BTN_R                  0x08U
#define BTN_D                  0x10U

/*
 * 下面的地址与 vivado_add_parallel_io.tcl 中的地址分配保持一致。
 * 如果手动搭建硬件时修改了 GPIO 地址，需要同步修改这里，
 * 或者使用 BSP 自动生成的 XPAR_*_BASEADDR 宏。
 */
#ifndef AXI_GPIO_INPUT_BASEADDR
# ifdef XPAR_AXI_GPIO_IN_BASEADDR
#  define AXI_GPIO_INPUT_BASEADDR XPAR_AXI_GPIO_IN_BASEADDR
# elif defined(XPAR_AXI_GPIO_INPUT_BASEADDR)
#  define AXI_GPIO_INPUT_BASEADDR XPAR_AXI_GPIO_INPUT_BASEADDR
# elif defined(XPAR_AXI_GPIO_0_BASEADDR)
#  define AXI_GPIO_INPUT_BASEADDR XPAR_AXI_GPIO_0_BASEADDR
# else
#  define AXI_GPIO_INPUT_BASEADDR 0x40000000U
# endif
#endif

#ifndef AXI_GPIO_LED_BASEADDR
# ifdef XPAR_AXI_GPIO_LED_BASEADDR
#  define AXI_GPIO_LED_BASEADDR XPAR_AXI_GPIO_LED_BASEADDR
# elif defined(XPAR_AXI_GPIO_OUTPUT_BASEADDR)
#  define AXI_GPIO_LED_BASEADDR XPAR_AXI_GPIO_OUTPUT_BASEADDR
# elif defined(XPAR_AXI_GPIO_1_BASEADDR)
#  define AXI_GPIO_LED_BASEADDR XPAR_AXI_GPIO_1_BASEADDR
# else
#  define AXI_GPIO_LED_BASEADDR 0x40010000U
# endif
#endif

static u32 read_switches(void)
{
    return Xil_In32(AXI_GPIO_INPUT_BASEADDR + GPIO_DATA_OFFSET) & SWITCH_MASK;
}

static u32 read_buttons(void)
{
    return Xil_In32(AXI_GPIO_INPUT_BASEADDR + GPIO2_DATA_OFFSET) & BUTTON_MASK;
}

static void write_leds(u32 value)
{
    Xil_Out32(AXI_GPIO_LED_BASEADDR + GPIO_DATA_OFFSET, value & LED_MASK);
}

int main(void)
{
    u32 input_a = 0U;
    u32 input_b = 0U;

    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_TRI_OFFSET, SWITCH_MASK);
    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO2_TRI_OFFSET, BUTTON_MASK);
    Xil_Out32(AXI_GPIO_LED_BASEADDR + GPIO_TRI_OFFSET, 0x00000000U);

    write_leds(0U);

    while (1) {
        u32 buttons = read_buttons();

        if ((buttons & BTN_C) != 0U) {
            input_a = read_switches();
            write_leds(input_a);
        } else if ((buttons & BTN_R) != 0U) {
            input_b = read_switches();
            write_leds(input_b);
        } else if ((buttons & BTN_U) != 0U) {
            write_leds(input_a + input_b);
        } else if ((buttons & BTN_D) != 0U) {
            write_leds(input_a * input_b);
        }

        usleep(10000U);
    }
}
