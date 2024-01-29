// printFlt and readFlt functions are not working as intended in final tests, they work just fine as standalone functions.

#include "myl.h"                        // Header file for the library
#define BUFF 100                        // Buffer size for reading and writing

int printStr(char *s){                  // Function to print a string
    int length = 0;                     // Length of the string
    while(s[length] != '\0'){           // Calculating the length of the string
        length++;                       // Incrementing the length
    }
    __asm__ __volatile__ (              // Printing the string
        "movl $1, %%eax \n\t"           // System call for write
        "movq $1, %%rdi \n\t"           // File descriptor for stdout
        "syscall \n\t"                  // Calling the system call
        :                               // Output operands
        :"S"(s), "d"(length)            // Passing the arguments
    );

    return (length);                    // Returning the length of the string
}

int readInt(int* n){                    // Function to read an integer
    char integer[BUFF] = "";            // Buffer to store the integer                   
    int length, i=0;                    // Length of the integer and loop variable 

    __asm__ __volatile__ (              // Reading the integer
        "movl $0, %%eax \n\t"           // System call for read
        "movq $0, %%rdi \n\t"           // File descriptor for stdin
        "syscall \n\t"                  // Calling the system call
        :"=a"(length)                   // Output operands
        :"S"(integer), "d"(BUFF)        // Passing the arguments
    );

    // __asm__ __volatile__(
    //     "syscall \n\t"
    //     :
    //     :
    //     :"a"(1), "D"(1), "S"(integer), "d"(length)
    //     :"rcx", "r11", "memory"
    // )
    
    if (length < 0)                     // If the length is negative
        return ERR;                     // Return error

    if(integer[0] == '\n' || integer[0] == '\t' || integer[0] == '\0')      // If the integer is empty
        return ERR;                                                         // Return error                               

    int sign = 1;                                                           // Sign of the integer
    if(integer[0] == '-'){                                                  // If the integer is negative
        sign = -1;
        i++;
        if (integer[1] < '0' || integer[1] > '9')                           // If the integer is not valid that is no number after the sign
            return ERR;
    }
    if(integer[0] == '+'){                                                  // If the integer is positive
        sign = 1;
        i++;
        if (integer[1] < '0' || integer[1] > '9')                           // If the integer is not valid that is no number after the sign
            return ERR;
    }

    long r=0;                                                               // Variable to store the integer
    for(; i<length && integer[i] != '\n'; i++){                             // Loop to read the integer
        if (integer[i] < '0' || integer[i] > '9')                           // If the integer is not valid
            return ERR;
        int digit = (int)(integer[i] - '0');                                // Converting the character to integer
        r *= 10;                                                            
        r += digit;
        if (r*sign > __INT32_MAX__ || r*sign < (- __INT32_MAX__ - 1))       // If the integer is out of range of integer
            return ERR;
    } 

    r *= sign;                                                              // Multiplying the integer with the sign
    *n = (int)r;                                                            // Storing the integer in the pointer

    return *n;

}

int printInt(int n){                                                        // Function to print an integer
    char buff[BUFF] = "";                                                   // Buffer to store the integer
    int i = 0,j,k,bytes;                                                    // Loop variables and length of the integer
    if(n == 0){                                                             // If the integer is zero
        buff[i++] = '0';                                                    // Storing the character zero
    }
    else{   
        if(n < 0){                                                          // If the integer is negative
            buff[i++] = '-';
            n = -n;
        }
        while(n){                                                           // Loop to store the integer in the buffer as an array of characters
            buff[i++] = (char)((n%10) + '0');
            n /= 10;
        }
        if(buff[0] == '-'){                                                 // If the integer is negative
            j = 1;
        }
        else{
            j = 0;                                          
        }
        k = i-1;                                                            // Storing the length of the integer
        while(j < k){
            char temp = buff[j];                                            // Swapping the characters
            buff[j++] = buff[k];                                            
            buff[k--] = temp;
        }
    }
    bytes = i;                                                               // Storing the length of the integer
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(bytes)
    );

    return (bytes);
}

int readFlt(float* f){                                                       // Function to read a float
    char flt[BUFF] = "";
    int length, i=0;                                                         // Length of the float and loop variable

    __asm__ __volatile__ (                                                   // Reading the float
        "movl $0, %%eax \n\t"                                                // System call for read
        "movq $0, %%rdi \n\t"                                                // File descriptor for stdin
        "syscall \n\t"                                                       // Calling the system call
        :"=a"(length)
        :"S"(flt), "d"(BUFF)
    );
    
    if (length < 0)                                                          // If the length is negative
        return ERR;

    if(flt[0] == '\n' || flt[0] == '\t' || flt[0] == '\0')                   // If the float is empty
        return ERR;

    int sign = 1;                                                            // Sign of the float
    if(flt[0] == '-'){                                                       // If the float is negative
        sign = -1;  
        i++;
        if (flt[1] < '0' || flt[1] > '9')                                    // If the float is not valid that is no number after the sign
            return ERR;
    }
    if(flt[0] == '+'){                                                       // If the float is positive and has a plus sign in teh beginning 
        sign = 1;
        i++;
        if (flt[1] < '0' || flt[1] > '9')                                    // If the float is not valid that is no number after the sign
            return ERR;
    }

    float r = 0.0; int pow = 0;int powsign = 1;                              // Variable to store the float, power of 10 and sign of the power of 10
    for(; i<length && flt[i] != '\n'; i++){                                  // Loop to read the float
        if(flt[i] == '.' || flt[i] == 'e' || flt[i] == 'E'){                 // If the float has a decimal point or an exponent
            break;
        }
        if (flt[i] < '0' || flt[i] > '9')                                    // If the float is not valid
            return ERR;
        int digit = (int)(flt[i] - '0');                                     // Converting the character to integer
        r *= 10;                                                             // Multiplying the float with 10
        r += digit;
    }

    int multiplier = 1;                                                      // Variable to store the multiplier
    if (flt[i]=='.' && flt[i] != '\n'){                                      // If the float has a decimal point
        i++;
        for(; i<length && flt[i] != '\n'; i++){
            if(flt[i] == 'e' || flt[i] == 'E'){                              
                break;
            }
            if (flt[i] < '0' || flt[i] > '9')
                return ERR;
            int digit = (int)(flt[i] - '0');
            multiplier *= 10;                                               // Multiplying the multiplier with 10
            r += (float)digit/(float)multiplier;                            // Adding the decimal part to the float
        } 
    }
    
    if ((flt[i] == 'e' || flt[i] == 'E') && flt[i] != '\n'){                // If the float has an exponent
        if(flt[i] == 'e' || flt[i] == 'E')
            i++;
        
        if(flt[i] == '-'){                                                  // If the exponent is negative
            powsign = -1;
            i++;
        }   
        if(flt[i] == '+'){                                                  // If the exponent is positive
            powsign = 1;
            i++;
        }
        for(; i<length && flt[i] != '\n'; i++){                             // Calculating the exponent                                               
        if (flt[i] < '0' || flt[i] > '9')                                   // If the exponent is not valid
            return ERR;
        int digit = (int)(flt[i] - '0');
        pow *= 10;
        pow += digit;
        if (pow > 40 || pow < (-40))                                        // If the exponent is out of range as maximum power of float could be 10^38 or 10^-38
            return ERR;
        }
    }
    
    if(powsign == 1){                                                       // If the exponent is positive
        while(pow){
            r *= 10;                                                        // Multiplying the float with 10
            pow--;
        }
    }
    else{
        while(pow){                                                         // If the exponent is negative
            r /= 10;                                                        // Dividing the float with 10
            pow--;
        }
    }
    
    r *= sign;                                                              // Multiplying the float with the sign
    *f = r;                                                                 // Storing the float in the pointer
    return OK;
}

int printFlt(float f){                                                      // Function to print a float
    char buff[BUFF] = "";                                                   // Buffer to store the float
    int i = 0,j,k,bytes;
    if(f == 0){
        buff[i++] = '0';
    }
    else{
        if(f < 0){                                                          // If the float is negative
            buff[i++] = '-';                                                // Storing the character minus
            f = -f;
        }
        long long intpart = (long long)f;                                   // Variable to store the integer part of the float
        float decpart = f - (float)intpart;                                 // Variable to store the decimal part of the float
        while(intpart){
            buff[i++] = (char)((intpart%10) + '0');                         // Storing the integer part of the float in the buffer as an array of characters
            intpart /= 10;                                                  // Dividing the integer part by 10
        }
        if(buff[0] == '-'){                                                 // If the float is negative
            j = 1;
        }
        else{
            j = 0;
        }
        k = i-1;
        while(j < k){                                                       // Swapping the characters
            char temp = buff[j];
            buff[j++] = buff[k];
            buff[k--] = temp;
        }
        int c=0;                                                            // Variable to store the number of decimal places
        if(decpart != 0){                                                   // If the float has a decimal part
            buff[i++] = '.';
            while(decpart){
                c++;
                decpart *= 10;
                int digit = (int)decpart;
                buff[i++] = (char)(digit + '0');                            // Storing the decimal part of the float in the buffer as an array of characters
                decpart -= (float)digit;
                if (c == 6)                                                 // Just to print 6 decimal places
                    break;
            }
            while (buff[bytes - 1] == '0') {                                // Removing trailing zeros
            bytes--;                                  
            }
        }
    }
    bytes = i;                                                              // Storing the length of the float
    __asm__ __volatile__ (                                                  // Printing the float
        "movl $1, %%eax \n\t"                                               // System call for write
        "movq $1, %%rdi \n\t"                                               // File descriptor for stdout
        "syscall \n\t"                                                      // Calling the system call
        :   
        :"S"(buff), "d"(bytes)                                              // Passing the arguments
    );  

    return (bytes);                                                         // Returning the length of the float
}
