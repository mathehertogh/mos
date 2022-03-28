#include <types.h>
#include <device/serial_port.h>

#define BAUDRATE     9600
#define MAX_BAUDRATE 115200

constexpr uint16_t DATA    = 0; // Transmitter Holding Buffer and Receiver Buffer
constexpr uint16_t DLL     = 0; // Divisor Latch Low (available iff DLAB is set)
constexpr uint16_t DLH     = 1; // Divisor Latch high (avaible iff DLAB is set)
constexpr uint16_t IER     = 1; // Interrupt Enable Register
constexpr uint16_t IIR     = 2; // Interrupt Identification Register (read-only)
constexpr uint16_t FCR     = 2; // FIFO Control Register (write-only)
constexpr uint16_t LCR     = 3; // Line Control Register
constexpr uint16_t MCR     = 4; // Modum Control Register
constexpr uint16_t LSR     = 5; // Line Status Register (read-only)
constexpr uint16_t MSR     = 6; // Modum Status Register (read-only)
constexpr uint16_t SCRATCH = 7; // Scratch Register

constexpr uint8_t IER_RDAI  = 1 << 0; // Receiver Data Availabe Interrupt
constexpr uint8_t IER_THREI = 1 << 1; // Transmitter Holding Register Empty Interrupt
constexpr uint8_t IER_RLSI  = 1 << 2; // Receiver Line Status Interrupt
constexpr uint8_t IER_MSI   = 1 << 3; // Modem Status Interrupt
constexpr uint8_t IER_SM    = 1 << 4; // Sleep Mode
constexpr uint8_t IER_LPM   = 1 << 5; // Low Power Mode

constexpr uint8_t FCR_EF = 1 << 0; // Enable FIFOs
constexpr uint8_t FCR_CRF = 1 << 1; // Clear Receive FIFO
constexpr uint8_t FCR_CTF = 1 << 2; // Clear Transmit FIFO 
constexpr uint8_t FCR_DMA = 1 << 3; // DMA Mode Select
constexpr uint8_t FCR_64B = 1 << 5; // Enable 64 Byte FIFO
constexpr uint8_t FCR_ITL_ONE =    0 << 6; // Interrupt Trigger Level  1B / 1B
constexpr uint8_t FCR_ITL_SMALL =  1 << 6; // Interrupt Trigger Level  4B / 16B
constexpr uint8_t FCR_ITL_MEDIUM = 2 << 6; // Interrupt Trigger Level  8B / 32B
constexpr uint8_t FCR_ITL_LARGE =  3 << 6; // Interrupt Trigger Level 14B / 56B

constexpr uint8_t LCR_5BITS        = 0 << 0;
constexpr uint8_t LCR_6BITS        = 1 << 0;
constexpr uint8_t LCR_7BITS        = 2 << 0;
constexpr uint8_t LCR_8BITS        = 3 << 0;
constexpr uint8_t LCR_1STOP        = 1 << 2;
constexpr uint8_t LCR_2STOP        = 1 << 2;
constexpr uint8_t LCR_NO_PARITY    = 0 << 3;
constexpr uint8_t LCR_ODD_PARITY   = 1 << 3;
constexpr uint8_t LCR_EVEN_PARITY  = 3 << 3;
constexpr uint8_t LCR_MARK_PARITY  = 5 << 3;
constexpr uint8_t LCR_SPACE_PARITY = 7 << 3;
constexpr uint8_t LCR_BREAK        = 1 << 6;
constexpr uint8_t LCR_DLAB         = 1 << 7;

constexpr uint8_t MCR_DTR = 1 << 0; // Data Terminal Ready
constexpr uint8_t MCR_RTS = 1 << 1; // Request To Send
constexpr uint8_t MCR_AO1 = 1 << 2; // Auxiliary Output 1
constexpr uint8_t MCR_AO2 = 1 << 3; // Auxiliary Output 2
constexpr uint8_t MCR_LM  = 1 << 4; // Loopback Mode
constexpr uint8_t MCR_AC  = 1 << 5; // Autoflow Control

constexpr uint8_t LSR_DR   = 1 << 0; // Data Ready
constexpr uint8_t LSR_OE   = 1 << 1; // Overrun Error
constexpr uint8_t LSR_PE   = 1 << 2; // Parity Error
constexpr uint8_t LSR_FE   = 1 << 3; // Framing Error
constexpr uint8_t LSR_BI   = 1 << 4; // Break Interrupt
constexpr uint8_t LSR_ETHR = 1 << 5; // Empty Transmitter Holding Register
constexpr uint8_t LSR_EDHR = 1 << 6; // Empty Data Holding Registers
constexpr uint8_t LSR_ERF  = 1 << 7; // Error in Received FIFO

constexpr uint8_t MSR_DCTS = 1 << 0; // Delta Clear To Send
constexpr uint8_t MSR_DDSR = 1 << 1; // Delta Data Set Ready
constexpr uint8_t MSR_TERI = 1 << 2; // Trailing Edge Ring Indicator
constexpr uint8_t MSR_DDCD = 1 << 3; // Delta Data Carrier Detect
constexpr uint8_t MSR_CTS = 1 << 4; // Clear To Send
constexpr uint8_t MSR_DSR = 1 << 5; // Data Set Ready
constexpr uint8_t MSR_RI = 1 << 6; // Ring Indicator
constexpr uint8_t MSR_CD = 1 << 7; // Carrier Detect

static inline void outb(uint16_t port, char data)
{
	asm volatile("outb %0, %w1" :: "a" (data), "d" (port));
}

SerialPort::SerialPort(uint16_t base_port)
	: base_port(base_port)
{
	/* We do not want to receive any interrupts. */
	outb(base_port+IER, 0);

	/* We do not do any hardware assisted flow control. */
	outb(base_port+MCR, 0);

	/* Enable 64B single-shot FIFOs and clear them. */
	outb(base_port+FCR, FCR_EF | FCR_64B | FCR_ITL_ONE | FCR_CRF | FCR_CTF);

	/* Set the baudrate. */
	outb(base_port+LCR, LCR_DLAB);
	outb(base_port+DLL, MAX_BAUDRATE / BAUDRATE);
	outb(base_port+DLH, (char)((MAX_BAUDRATE / BAUDRATE) << 8));

	/* Configure the protocol. */
	outb(base_port+LCR, LCR_8BITS | LCR_1STOP | LCR_NO_PARITY);

	send("\nserial port initialized\n");
}

void SerialPort::send_byte(char data)
{
	outb(base_port+DATA, data);
}

void SerialPort::send(const char *msg)
{
	while (*msg) {
		send_byte(*msg);
		++msg;
	}
}