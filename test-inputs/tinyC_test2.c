// This program tests function declaration and calling, as well as global variable scope.
// Also checks the recursive factorial function to check the function call and return methodology
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int global_var = 0;                         // Testing global variable
int counter = 0;

int factorial (int n);                           // Testing function declaration

int main () {
    counter++;
    global_var = counter;
    int n, reader;
    printStr("Enter n (n < 20): ");
    n = readInt(&reader);
    int i;
    int fact[50];

    // for loop to print the fibonacci series.
    for (i = 0; i < n; i++) {
        fact[i] = factorial(i+1);
        counter++;
        global_var = counter;
    }
    for (i = 0; i < n; i++) {
        printStr("fact[");
        printInt(i + 1);
        printStr("] = ");
        printInt(fact[i]);
        printStr("\n");
    }
    return 0;
}

int factorial (int n) {
    counter++;
    global_var = counter;

    if (n == 0) {
        return 1;
    }
 
    // Testing recursive function
    else {
        return n * factorial(n - 1);
    }
}
