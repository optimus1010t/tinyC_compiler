// to the number of steps requiured to reach 1 collatz conjencture

// Include predefined functions 
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int counter = 0;                         // Testing global variable

int main () {
    int n, reader;
    printStr("Enter n for testing Collatz conjecture on it (n < 20): ");
    n = readInt(&reader);
    int i;
    if(n==0){
        printStr("Input a positive integer\n");
        return 0;
    }
    while (n != 1) {
        if (n % 2 == 0) {
            n = n / 2;
        }
        else {
            n = 3 * n + 1;
        }
        counter++;
    }
    printStr("Number of steps required to reach 1 in Collatz conjecture: ");
    printInt(counter);
    printStr("\n");
    return 0;
}