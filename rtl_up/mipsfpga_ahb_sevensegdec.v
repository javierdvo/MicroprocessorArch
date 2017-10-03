/*
 * Seven-segment display decoder
 *
 * 12 April 2015
 */

module mipsfpga_ahb_sevensegdec(input      [3:0] data,
                                output reg [6:0] segments);
  always @(*)
    case(data)
                       // abc_defg
      4'h0: segments = 7'b000_0001;
      4'h1: segments = 7'b100_1111;
      4'h2: segments = 7'b001_0010;
      4'h3: segments = 7'b000_0110;
      4'h4: segments = 7'b100_1100;
      4'h5: segments = 7'b010_0100;
      4'h6: segments = 7'b010_0000;
      4'h7: segments = 7'b000_1111;
      4'h8: segments = 7'b000_0000;
      4'h9: segments = 7'b000_1100;
      4'ha: segments = 7'b000_1000;
      4'hb: segments = 7'b110_0000;
      4'hc: segments = 7'b111_0010;
      4'hd: segments = 7'b100_0010;
      4'he: segments = 7'b011_0000;
      4'hf: segments = 7'b011_1000;
      default: 
            segments = 7'b111_1111;
    endcase
endmodule
