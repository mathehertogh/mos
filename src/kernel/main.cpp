
int y = 5;


int main() __attribute__((section (".entry")));

int main() {
	int x;

	x = 7;
	x += 2;
	x *= y;

	return x;
}