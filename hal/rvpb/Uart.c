#include "stdint.h"
#include "Uart.h"
#include "HalUart.h"

extern volatile PL011_t* Uart;

void Hal_uart_init(void)
{
	// Enable UART
	Uart->uartcr.bits.UARTEN = 0; // Turn off a Hardware
	Uart->uartcr.bits.TXE = 1; // Turn on UART output
	Uart->uartcr.bits.RXE = 1; // Turn on UART input
	Uart->uartcr.bits.UARTEN = 1; // Turn on entire UART Hardware
}

void Hal_uart_put_char(uint8_t ch) //  Show only one alphabet through UART
{
	while(Uart->uartfr.bits.TXFF); // Waiting until Uart hardware's buffer is 0
	Uart->uartdr.all = (ch & 0xFF); // Send an alphabet through data register
}
