// mipsfpga_ahb.v
// 
// 20 Oct 2014
//
// AHB-lite bus module with 3 slaves: RAM1, RAM2,and
// GPIO (memory-mapped I/O: switches and LEDs from the FPGA board).
// The module includes an address decoder and multiplexer (for 
// selecting which slave module produces HRDATA).

`timescale 100ps/1ps

`include "mipsfpga_ahb_const.vh"



module mipsfpga_ahb
(
    input               HCLK,
    input               HRESETn,
    input      [ 31: 0] HADDR,
    input      [  2: 0] HBURST,
    input               HMASTLOCK,
    input      [  3: 0] HPROT,
    input      [  2: 0] HSIZE,
    input      [  1: 0] HTRANS,
    input      [ 31: 0] HWDATA,
    input               HWRITE,
    output     [ 31: 0] HRDATA,
    output              HREADY,
    output              HRESP,
    input               SI_Endian,

// memory-mapped I/O
    input      [ 17: 0] IO_Switch,
    input      [  4: 0] IO_PB,
    output     [ 17: 0] IO_LEDR,
    output     [  8: 0] IO_LEDG,
    output     [  7: 0] IO_7SEGEN_N,
    output     [  6: 0] IO_7SEG_N,
    output              buzz,
    output              lcd_rs,
    output              lcd_sdo,
    output              lcd_sck,
    
    output              DMA_INTERRUPT, //asserted when we write !0 to DMA_START_ADDR
    input               CLEAR_START  // Must be asserted by the dma engine when it has finished one dma request
);


  wire [31:0] HRDATA3, HRDATA2, HRDATA1, HRDATA0;
  wire [ 3:0] HSEL;
  wire [31:0] HADDR_d;   // HADDR delayed 1 cycle to align with HWDATA
  wire        HWRITE_d;  // HWRITE delayed 1 cycle to align with HWDATA

  flop #(32)  adrreg(HCLK, HADDR, HADDR_d);
  flop #(1)   writereg(HCLK, HWRITE, HWRITE_d);

  assign HREADY = 1;
  assign HRESP = 0;

 


  // Module 0
  mipsfpga_ahb_ram_reset mipsfpga_ahb_ram_reset(HCLK, HRESETn, HADDR, HWDATA, HWRITE_d, HSEL[0], HRDATA0);
  // Module 1
  mipsfpga_ahb_ram mipsfpga_ahb_ram(HCLK, HRESETn, HADDR, HWDATA, HWRITE_d, HSEL[1], HRDATA1);
  // Module 2
  mipsfpga_ahb_gpio mipsfpga_ahb_gpio(HCLK, HRESETn, HADDR_d[6:2], HWDATA, HWRITE_d, HSEL[2], HRDATA2, IO_Switch, IO_PB, IO_LEDR, IO_LEDG,
IO_7SEGEN_N, IO_7SEG_N, buzz,lcd_rs,lcd_sdo,lcd_sck);
  // Module 3: DMA registers
  mipsfpga_ahb_dmaregs dmaregs(HCLK,HRESETn,HADDR[5:0],HWDATA,HWRITE,HSEL[3],HRDATA3, DMA_INTERRUPT, CLEAR_START);

  

  ahb_decoder ahb_decoder(HADDR_d, HSEL);
  ahb_mux ahb_mux(HSEL, HRDATA3, HRDATA2, HRDATA1, HRDATA0, HRDATA);

endmodule


module ahb_decoder
(
    input  [31:0] HADDR,
    output [ 3:0] HSEL
);

  // Decode based on most significant bits of the address
  assign HSEL[0] = (HADDR[28:22] == `H_RAM_RESET_ADDR_Match); // 128 KB RAM  at 0xbfc00000 (physical: 0x1fc00000)
  assign HSEL[1] = (HADDR[28]    == `H_RAM_ADDR_Match);         // 256 KB RAM at 0x80000000 (physical: 0x00000000)
  assign HSEL[2] = (HADDR[28:22] == `H_LEDR_ADDR_Match );      // GPIO at 0xbf800000 (physical: 0x1f800000)
  assign HSEL[3] = (HADDR[27:20] == `H_DMA_ADDR_Match);
  
endmodule


module ahb_mux
(
    input      [ 3:0] HSEL,
    input      [31:0] HRDATA3, HRDATA2, HRDATA1, HRDATA0,
    output reg [31:0] HRDATA
);

    always @(*)
      casez (HSEL)
	      4'b???1:     HRDATA = HRDATA0;
	      4'b??10:     HRDATA = HRDATA1;
	      4'b?100:     HRDATA = HRDATA2;
	      4'b1000:     HRDATA = HRDATA3;
	      default:   HRDATA = HRDATA1;
      endcase
endmodule


module flop #(parameter WIDTH = 8)
              (input                  clk,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk)
    q <= d;
endmodule

