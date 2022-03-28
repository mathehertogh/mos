#pragma once

#include <device/serial_port.h>

class Console
{
public:
	Console();
	void print(const char *msg);

private:
	SerialPort serial_port;
};

extern Console console;
