/*
 * main.c for MIPSfpga running on the Nexys4 DDR board.
 *
 * This code writes a string to the LCD repeatedly.
 */

#include <stdlib.h>


//------------------
// main()
//------------------
int main() {
	volatile int *DMA_SRC=(int*)0xbf300000;
	volatile int *DMA_DST=(int*)0xbf300004;
	volatile int *DMA_SIZE=(int*)0xbf300008;
	volatile int *DMA_START=(int*)0xbf300012;

	
  while (1) {
	*DMA_SRC=0xbf800008;
	*DMA_DST=0xbf800000;
	*DMA_SIZE=0x00000005;
	*DMA_START=0x00000001;
	*DMA_START=0x00000000;
	*DMA_SRC=0xbf80000c;
	*DMA_DST=0xbf800000;
	*DMA_SIZE=0x00000003;
	*DMA_START=0x00000001;
  }
  return 0;
}

void _mips_handle_exception(void* ctx, int reason) {
  volatile int *IO_LEDR = (int*)0xbf800000;

  *IO_LEDR = 0x8001;  // Display 0x8001 on LEDs to indicate error state
  while (1) ;
}
