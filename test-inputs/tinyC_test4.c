// Include predefined functions 
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

// Function to find maximum subarray sum
int maxSubArrSum (int a[], int n) {                 // Array as parameter                 
    int max_so_far = -1000, max_ending_here = 0; 
    int i;
    for (i = 0; i < n; i++) { 
        max_ending_here = max_ending_here + a[i]; 
        if (max_so_far < max_ending_here) {
            max_so_far = max_ending_here; 
        }
  
        if (max_ending_here < 0) {
            max_ending_here = 0; 
        }
    } 
    return max_so_far; 
} 
  
// Driver program to test maxSubArrSum
int main() { 
    int a[8];
    a[0]= -20;
    a[1]= -40;
    a[2]= 50;
    a[3]= -15;
    a[4]= -25;
    a[5]= 15;
    a[6]= 65;
    a[7]= -690;
    printStr("Array is:");
    int i;
    for(i=0;i<8;i++){
        printStr(" ");
        printInt(a[i]);
    }
    printStr("\n");
    int max_subArr_sum = maxSubArrSum(a, 8);        // Passing array as argument
    printStr("Maximum contiguous sum is ");
    printInt(max_subArr_sum);
    printStr("\n");
    return 0; 
}
