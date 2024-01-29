// tests different arithmetic operations

// Include predefined functions 
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

// Global declarations
float d = 6.9;
char c; 
int i, j, k, l, m;
int w[20];                      
int a = 4, *p, b;               

int main () {
    int x;                      // Variable Declarations
    int y;
    int reader;
    printStr("Enter x: ");
    x = readInt(&reader);
    printStr("Enter y: ");
    y = readInt(&reader);
    char ch = 'c';              // Character definitions

    // Arithmetic Operators
    i = x + y;                  // Addition  
    printStr("i = ");
    printInt(x);
    printStr(" + ");
    printInt(y);
    printStr(" = ");
    printInt(i);
    printStr("\n");

    j = x - y;                  // Subtraction
    printStr("j = ");
    printInt(x);
    printStr(" - ");
    printInt(y);
    printStr(" = ");
    printInt(j);
    printStr("\n");

    k = x * y;                  // Multiplication
    printStr("k = ");
    printInt(x);
    printStr(" * ");
    printInt(y);
    printStr(" = ");
    printInt(k);
    printStr("\n");

    l = x / y;                  // Division
    printStr("l = ");
    printInt(x);
    printStr(" / ");
    printInt(y);
    printStr(" = ");
    printInt(l);
    printStr("\n");

    m = x % y;                  // Modulo
    printStr("m = ");
    printInt(x);
    printStr(" % ");
    printInt(y);
    printStr(" = ");
    printInt(m);
    printStr("\n");

    return 0;
}