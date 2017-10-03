// mipsfpga_nexys4_ddr.v
// 22 March 2015
//
// Instantiate the mipsfpga system and rename signals to
// match GPIO, LEDs and switches on Digilent's (Xilinx)
// Nexys4-DDR board

// Digilent's (Xilinx) Nexys4-DDR board:
// Outputs:
// 16 LEDs (IO_LEDR[15:0]) 
// Inputs:
// 16 slide switches (IO_Switch[15:0]), 5
// 5 pushbutton switches (IO_PB): {btnU, btnD, btnL, btnR, btnC}
//


module mipsfpga_nexys4_ddr( input     CLK100MHZ,
				 input         CPU_RESETN,
				 input         BTNU, BTND, BTNL, BTNC, BTNR, 
				 input  [15:0] SW,
				 output [15:0] LED,
				 inout  [ 8:1] JB,
                        output [ 7:0] AN,
                        output        CA, CB, CC, CD, CE, CF, CG,
                        output buzz,
                        output lcd_rs,
                        output lcd_sdo,
                        output lcd_sck,
                        output lcd_reset,
                        output lcd_rs1,
                        output lcd_sdo1,
                        output lcd_sck1,
                        output lcd_reset1
);

  // Press btnCpuReset to reset the processor. 
        
  wire clk_out; 
  wire tck_in, tck;
  
  clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .clk_out1(clk_out));
  IBUF IBUF1(.O(tck_in),.I(JB[4]));
  BUFG BUFG1(.O(tck), .I(tck_in));

  mipsfpga_sys mipsfpga_sys(
			   .SI_Reset_N(CPU_RESETN),
                    .SI_ClkIn(clk_out),
                    .HADDR(),
                    .HRDATA(),
                    .HWDATA(),
                    .HWRITE(),
                    .EJ_TRST_N_probe(JB[7]),
                    .EJ_TDI(JB[2]),
                    .EJ_TDO(JB[3]),
                    .EJ_TMS(JB[1]),
                    .EJ_TCK(tck),
                    .SI_ColdReset_N(JB[8]),
                    .EJ_DINT(1'b0),
                    .IO_Switch({2'b0,SW}),
                    .IO_PB({BTNU, BTND, BTNL, BTNC, BTNR}),
                    .IO_LEDR(LED),
                    .IO_LEDG(),
                    .IO_7SEGEN_N(AN),
                    .IO_7SEG_N({CA,CB,CC,CD,CE,CF,CG}),
                    .buzz,
                    .lcd_rs,
                    .lcd_sdo,
                    .lcd_sck                    
                    
);
   assign lcd_reset=CPU_RESETN;
   assign lcd_rs1=lcd_rs; 
   assign lcd_reset1=lcd_reset; 
   assign lcd_sck1=lcd_sck; 
   assign lcd_sdo1=lcd_sdo;        
endmodule
