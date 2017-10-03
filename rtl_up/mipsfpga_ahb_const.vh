// 
// mipsfpga_ahb_const.vh
//
// Verilog include file with AHB definitions
// 

//-------------------------------------------
// Memory-mapped I/O addresses
//-------------------------------------------
`define H_LEDR_ADDR   			(32'h1f800000)
`define H_LEDG_ADDR   			(32'h1f800004)
`define H_SW_ADDR   			(32'h1f800008)
`define H_PB_ADDR   			(32'h1f80000c)
`define H_7SEGEN_ADDR   		(32'h1f800010)
`define H_7SEG0_ADDR  			(32'h1f800014)
`define H_7SEG1_ADDR  			(32'h1f800018)
`define H_7SEG2_ADDR  			(32'h1f80001c)
`define H_7SEG3_ADDR  			(32'h1f800020)
`define H_7SEG4_ADDR  			(32'h1f800024)
`define H_7SEG5_ADDR  			(32'h1f800028)
`define H_7SEG6_ADDR  			(32'h1f80002c)
`define H_7SEG7_ADDR  			(32'h1f800030)

//DMA addresses
`define DMA_SRC_ADDR            (5'h00)
`define DMA_DST_ADDR            (5'h04)
`define DMA_SIZE_ADDR           (5'h08)
`define DMA_START_ADDR          (5'h0c)
`define DMA_KEYLO_ADDR  (5'h10)
`define DMA_KEYHI_ADDR  (5'h14)
`define DMA_ED_ADDR     (5'h18)


`define H_LEDR_IONUM   		(5'h0)
`define H_LEDG_IONUM   		(5'h1)
`define H_SW_IONUM  		(5'h2)
`define H_PB_IONUM  		(5'h3)
`define H_7SEGEN_IONUM  	(5'h4)
`define H_7SEG0_IONUM  		(5'h5)
`define H_7SEG1_IONUM  		(5'h6)
`define H_7SEG2_IONUM  		(5'h7)
`define H_7SEG3_IONUM  		(5'h8)
`define H_7SEG4_IONUM  		(5'h9)
`define H_7SEG5_IONUM  		(5'ha)
`define H_7SEG6_IONUM  		(5'hb)
`define H_7SEG7_IONUM  		(5'hc)

`define H_MILLIS_COUNTER_ADDR      (5'hd)
`define H_BUZZER_ADDR (5'he)
`define H_SPI_ADDR (5'hf)
`define H_SPI_DONE_ADDR (5'h10)

//-------------------------------------------
// RAM addresses
//-------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		(32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH	(15) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match 	(7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)
`define H_LEDR_ADDR_Match		(7'h7e)
`define H_DMA_ADDR_Match         (8'hf3)

