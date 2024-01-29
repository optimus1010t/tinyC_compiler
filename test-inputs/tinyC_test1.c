// binary search

int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int global_var = 0;                         // Testing global variable

int binarySearch (int a[], int l, int r, int x) {   
    while (l <= r) {
        int m = (l + r) / 2;
        if (a[m] == x) {                  // Testing conditionals                                         
            return m;                     // Testing return statement
        } else if (a[m] < x) {            // Testing array arithmetic
            l = m + 1;
        } else {   
            r = m - 1;
        }
    }
    return -1;                              // Testing return statement
}

int main() {
    global_var++;

    int a[10];                              // Testing 1-D array declaration
    int i, n, reader;                            // Testing variable declarations

    // Testing read numbers
    printStr("Enter 10 array elements in sorted order, separated by newlines:\n");
    for (i = 0; i < 10; i++) {
        a[i] = readInt(&reader);                 // Testing readInt
    }

    // Testing print numbers
    printStr("Entered array :");
    for (i = 0; i < 10; i++) {              // Testing for loop
        printStr(" ");                      // Testing printStr     
        printInt(a[i]);                     // Testing printInt
    }
    printStr("\n");

    int x;
    printStr("Enter the number to search: ");
    x = readInt(&reader);
    int index = binarySearch(a, 0, 9, x);
    if (index == -1) {
        printStr("Invalid search, element not found");
    } else { 
        printStr("Element found at position: ");
        printInt(index+1);
    }
    printStr("\n");
    return 0;
}
