/*
 * main.c for MIPSfpga running on the Nexys4 DDR board.
 *
 * This program copy the the first five elements of array x into y using dma
 * It then display the value of y on the segments 
 */

#include <stdlib.h>

void delay_ms(unsigned int num);
void writeHexValTo7Segs(unsigned int val);

int main() {

    volatile int * DMA_SRC = (int*)0xbf300000;
    volatile int * DMA_DST = (int*)0xbf300004;
    volatile int * DMA_SIZE =(int*)0xbf300008;
    volatile int * DMA_START = (int*)0xbf30000c;
    int *x = (int*)80000000;
    int *y = (int*)80000100;
    //Display x
    int i=0;
    for(i=0; i<8; i++)
    {
        writeHexValTo7Segs(*(x+i));
        delay_ms(2000);
    }
    //To copy x to y using dma

   // *DMA_SRC = (int)x;
   // *DMA_DST = (int)y;
   // *DMA_SIZE=5;
   // *DMA_START=1;
    return 0;
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
