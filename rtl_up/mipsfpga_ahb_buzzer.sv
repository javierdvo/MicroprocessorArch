/*
 * Buzzer hardware for MIPSfpga
 */

module mipsfpga_ahb_buzzer(
              input  logic        clk,
              input  logic        resetn,
              input  logic [31:0] numMicros,
              output logic        buzz);

  // Internal counter
  logic [31:0] internal_counter_millis;
  logic resethelp;
  logic [31:0] numMicros_d;  
  
  mipsfpga_ahb_microsCounter buzzer_couter(clk,resethelp,internal_counter_millis);

 always_ff @(negedge clk ) begin
    numMicros_d <= numMicros;
    if(resetn==0 || numMicros_d != numMicros)begin
        buzz<=0;
        resethelp<=1;
    end
    else begin
      if (numMicros) begin
            if(numMicros_d<internal_counter_millis) begin
                resethelp<=1;
                buzz <= !buzz;
                end
            else begin
                resethelp<=0;
                buzz<=buzz;
                end
            end
     else begin
        buzz <= 0;
        resethelp<=1;
        end
     end
    end
 
endmodule

 
