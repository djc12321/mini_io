#include "mb_interface.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xparameters.h"

#define GPIO_DATA_OFFSET       0x00U
#define GPIO_TRI_OFFSET        0x04U
#define GPIO2_DATA_OFFSET      0x08U
#define GPIO2_TRI_OFFSET       0x0CU

#define GPIO_GIER_OFFSET       0x11CU
#define GPIO_ISR_OFFSET        0x120U
#define GPIO_IER_OFFSET        0x128U
#define GPIO_GIER_ENABLE       0x80000000U
#define GPIO_CH2_INTERRUPT     0x00000002U

#define INTC_ISR_OFFSET        0x00U
#define INTC_IER_OFFSET        0x08U
#define INTC_IAR_OFFSET        0x0CU
#define INTC_MER_OFFSET        0x1CU
#define INTC_IMR_OFFSET        0x20U
#define INTC_IVAR_OFFSET       0x100U
#define INTC_MASTER_ENABLE     0x00000001U
#define INTC_HARDWARE_ENABLE   0x00000002U
#define INTC_GPIO_MASK         0x00000001U

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

#ifndef AXI_GPIO_INPUT_BASEADDR
# ifdef XPAR_AXI_GPIO_IN_BASEADDR
#  define AXI_GPIO_INPUT_BASEADDR XPAR_AXI_GPIO_IN_BASEADDR
# else
#  define AXI_GPIO_INPUT_BASEADDR 0x40000000U
# endif
#endif

#ifndef AXI_GPIO_LED_BASEADDR
# ifdef XPAR_AXI_GPIO_LED_BASEADDR
#  define AXI_GPIO_LED_BASEADDR XPAR_AXI_GPIO_LED_BASEADDR
# else
#  define AXI_GPIO_LED_BASEADDR 0x40010000U
# endif
#endif

#ifndef AXI_INTC_BASEADDR
# define AXI_INTC_BASEADDR 0x41200000U
#endif

static volatile u32 input_a;
static volatile u32 input_b;

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

static void handle_buttons(u32 buttons)
{
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
}

void fast_gpio_isr(void) __attribute__ ((interrupt_handler));

void fast_gpio_isr(void)
{
    u32 gpio_status = Xil_In32(AXI_GPIO_INPUT_BASEADDR + GPIO_ISR_OFFSET);

    if ((gpio_status & GPIO_CH2_INTERRUPT) != 0U) {
        handle_buttons(read_buttons());
    }

    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_ISR_OFFSET, gpio_status);
    Xil_Out32(AXI_INTC_BASEADDR + INTC_IAR_OFFSET, INTC_GPIO_MASK);
}

static void setup_fast_interrupt(void)
{
    microblaze_disable_interrupts();

    Xil_Out32(AXI_INTC_BASEADDR + INTC_MER_OFFSET, 0U);
    Xil_Out32(AXI_INTC_BASEADDR + INTC_IER_OFFSET, 0U);
    Xil_Out32(AXI_INTC_BASEADDR + INTC_IAR_OFFSET, 0xFFFFFFFFU);

    Xil_Out32(AXI_INTC_BASEADDR + INTC_IVAR_OFFSET, (u32)fast_gpio_isr);
    Xil_Out32(AXI_INTC_BASEADDR + INTC_IMR_OFFSET, INTC_GPIO_MASK);
    Xil_Out32(AXI_INTC_BASEADDR + INTC_IER_OFFSET, INTC_GPIO_MASK);

    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_ISR_OFFSET, 0xFFFFFFFFU);
    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_IER_OFFSET, GPIO_CH2_INTERRUPT);
    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_GIER_OFFSET, GPIO_GIER_ENABLE);

    Xil_Out32(AXI_INTC_BASEADDR + INTC_MER_OFFSET,
              INTC_MASTER_ENABLE | INTC_HARDWARE_ENABLE);

    microblaze_enable_interrupts();
}

int main(void)
{
    input_a = 0U;
    input_b = 0U;

    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO_TRI_OFFSET, SWITCH_MASK);
    Xil_Out32(AXI_GPIO_INPUT_BASEADDR + GPIO2_TRI_OFFSET, BUTTON_MASK);
    Xil_Out32(AXI_GPIO_LED_BASEADDR + GPIO_TRI_OFFSET, 0x00000000U);
    write_leds(0U);

    setup_fast_interrupt();

    while (1) {
        /* 按键状态变化后会进入 fast_gpio_isr，中断服务函数中完成任务处理。 */
    }
}
