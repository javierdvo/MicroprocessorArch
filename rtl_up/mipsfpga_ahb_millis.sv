/*
 * Millisecond counter hardware for MIPSfpga
 */
 `define PERIOD 50000

module mipsfpga_ahb_millisCounter(input  logic         clk,
                                  input  logic         resetn,
                                  output logic [31:0]  millis);

integer counter; 
integer next_counter = 0;
logic [31:0] next_millis=0; 

assign millis = next_millis;
assign counter = next_counter;

always_ff @(posedge clk or negedge resetn) begin
    if (~resetn) begin 
        next_counter <= 0;
        next_millis <= 0;
    end else begin
        if(counter == `PERIOD-1) begin 
            next_counter <= 0;
            next_millis <= millis + 1;
        end else begin
        next_counter <= counter + 1;
        end
    end
end
    
endmodule
