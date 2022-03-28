#include <console.h>

Console console;

Console::Console()
	: serial_port(COM1_PORT) { }

void Console::print(const char *msg)
{
	serial_port.send(msg);
}