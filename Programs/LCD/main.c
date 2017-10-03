/*
 * main.c for MIPSfpga running on the Nexys4 DDR board.
 *
 * This code prompts the user for a number
 * and check if it is equal to a "random" number
 */

#include <stdlib.h>
#include <stdio.h>

void initLCD();
void clearLCD();
void waitTillLCDDone();
void writeValToLCD(unsigned int val);
void writeStringToLCD(char *str);
void delay_ms(unsigned int num);
void writeHexValTo7Segs(unsigned int val);

//------------------
// main()
//------------------
int main() {

    initLCD();
    volatile int *SWITCHES = (int*) 0xbf800008;
    volatile int *PBUTTON = (int*) 0xbf80000c; 
    volatile int *MILLIS = (int*)0xbf800034;

    volatile int goal = 0;
    volatile int user = 0;
    char msg[6];

    writeStringToLCD("Hello!");
    writeStringToLCD("Guess a");
    writeStringToLCD("Number");
    delay_ms(1000);
    do {
        // Generate a number in [0,10[
        // based on the MILLIS counter
        goal = *MILLIS % 10;

        //When the button are not pressed
        while(*PBUTTON==0){
            user = *(SWITCHES);
        } 
        //write guessed number to segments
        writeHexValTo7Segs(user);
        delay_ms(2000);

        // msg to be written to the lcd
        if(user == goal){
            sprintf(msg,"Yes %d",goal);
            //writes ones then the guested values
            writeHexValTo7Segs(0x1111);
            delay_ms(1000);
            writeHexValTo7Segs(goal);
        }else{
            sprintf(msg,"No %d",goal);
            //writes zeros then the guested values
            writeHexValTo7Segs(0x0000);
            delay_ms(1000);
            writeHexValTo7Segs(goal);
        }

        // write msg to the lcd
        writeStringToLCD(msg);

        //wait 1 sec and write new msg
        delay_ms(1000);
        writeStringToLCD("Play");
        writeStringToLCD("again");

    }while(user != goal);
    return 0;
}

void initLCD() {
    unsigned int initCmds[9] = {0x31, 0x14, 0x55, 0x6d, 0x7c, 0x30, 0x0f,
        0x06, 0x01};
    unsigned int i;
    for (i=0; i<9; i++) {
        writeValToLCD(initCmds[i]);
        writeHexValTo7Segs(initCmds[i]);
        delay_ms(2);
    }
}

void clearLCD() {
    writeValToLCD(0x01);
    delay_ms(2);
}

void waitTillLCDDone() {
    volatile int *IO_SPI_DONE = (int*)0xbf800040;
    volatile unsigned int done;
    do {
        done = *IO_SPI_DONE;
    } while (!done);
}

void writeValToLCD(unsigned int val) {
    volatile int *IO_SPI_DATA = (int*)0xbf80003c;

    *IO_SPI_DATA = val; 
    waitTillLCDDone();
}

void writeStringToLCD(char *str) {
    volatile unsigned int i=0;
    volatile unsigned int val;

    clearLCD();
    while (str[i] != '\0') {
        val = str[i];
        val = val | 0x100;  // prepend bit indicating that sending data
        writeHexValTo7Segs(val); 
        writeValToLCD(val);
        i++;
    }
    delay_ms(500);
}


void delay_ms(unsigned int num) {
    volatile int *IO_MILLIS = (int*)0xbf800034;
    volatile unsigned int start_ms=0, curr_ms=0, diff = 0;

    start_ms = *IO_MILLIS;
    while ( diff < num) {
        curr_ms = *IO_MILLIS;
        diff = curr_ms - start_ms;
    }
}

void writeHexValTo7Segs(unsigned int val) {
    volatile int *IO_7SEGEN = (int*)0xbf800010;
    volatile int *IO_7SEG0  = (int*)0xbf800014;
    volatile int *IO_7SEG1  = (int*)0xbf800018;
    volatile int *IO_7SEG2  = (int*)0xbf80001c;
    volatile int *IO_7SEG3  = (int*)0xbf800020;

    volatile unsigned int i = 0;

    *IO_7SEGEN = 0xF0; // enable lower 4 7-segment displays

    *IO_7SEG0 = val;   // write lowest hex digit to 7-seg disp
    val = val >> 4;    // shift off lowest hex digit
    *IO_7SEG1 = val;   // write lowest hex digit to 7-seg disp
    val = val >> 4;    // shift off lowest hex digit
    *IO_7SEG2 = val;   // write lowest hex digit to 7-seg disp
    val = val >> 4;    // shift off lowest hex digit
    *IO_7SEG3 = val;   // write lowest hex digit to 7-seg disp
}
void _mips_handle_exception(void* ctx, int reason) {
    volatile int *IO_LEDR = (int*)0xbf800000;

    *IO_LEDR = 0x8001;  // Display 0x8001 on LEDs to indicate error state
    while (1) ;
}
