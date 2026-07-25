#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"

int main()
{
    init_platform();          // from "platform.h"

    XGpio input, output;      // from "xgpio.h"
    int a;                    // the input to the inverter
    int y;                    // output from the inverter

    XGpio_Initialize(&input, XPAR_AXI_GPIO_0_DEVICE_ID);   // set the input address
    XGpio_Initialize(&output, XPAR_AXI_GPIO_1_DEVICE_ID);  // set the output address

    XGpio_SetDataDirection(&input, 1, 1);   // channel 1 in AXI GPIO, 1 = input
    XGpio_SetDataDirection(&output, 1, 0);  // channel 1 in AXI GPIO, 0 = output

    while(1) {
        a = XGpio_DiscreteRead(&input, 1);  // read input value and store in "a"
        y = ~a;                             // invert "a" and store in "y"
        XGpio_DiscreteWrite(&output, 1, y); // write output "y"
    }

    cleanup_platform();       // from "platform.h"
    return 0;
}
