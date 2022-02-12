
int main() __attribute__((section (".entry")));

int main() {
	int x;

	x = 7;
	x += 2;

	return x;
}