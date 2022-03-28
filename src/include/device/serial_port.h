#define COM1_PORT 0x3F8
#define COM2_PORT 0x2F8
#define COM3_PORT 0x3E8
#define COM4_PORT 0x2E8
#define COM5_PORT 0x5F8
#define COM6_PORT 0x4F8
#define COM7_PORT 0x5E8
#define COM8_PORT 0x4E8 

class SerialPort
{
public:
	SerialPort(uint16_t base_port);
	void send(const char *msg);

private:
	uint16_t base_port;

	void send_byte(char data);
};
