/*
 * SPI interface for MIPSfpga
 */
`define PERIOD_LCD 25000

module mipsfpga_ahb_spi(
           input  logic       clk,
           input  logic       resetn,
           input  logic [7:0] data,
           input  logic       send,
           output logic       done,
           output logic       sdo,
           output logic       sck);

  integer clock_counter = 0; // counter for sck
  byte counter = 0; //Data counter
  logic done_s = 0;

  parameter IDLE_S = 2'b01,
            ACTIVE_S = 2'b10;
  logic [1:0] state;
  always_ff @(posedge clk, negedge resetn)
  begin
    if(resetn==0) begin
        clock_counter<=0;
        sck <= 0;
        done <= 1;
        state <= IDLE_S;
    end else begin
        if(state==ACTIVE_S) begin
            clock_counter <= clock_counter+1;
            if(clock_counter==`PERIOD_LCD-1) begin 
                clock_counter<=0;
                sck <= !sck;
                if(done_s && sck)begin
                    done <= 1;
                    state <= IDLE_S;
                    sck<=0;
                end
            end
        end else begin
            sck<=0;
            if(send && done) begin 
                state <= ACTIVE_S;
                done <= 0;
            end;
        end 
    end 
   end 
  
  logic reset_sdo;
  assign reset_sdo = (state==IDLE_S) & send;
       
  always_ff @(negedge resetn, negedge sck, posedge reset_sdo)
  begin
    if(resetn==0) begin
        counter<=0;
        done_s <=0;
        sdo<=0;
    end else if(reset_sdo) begin
        counter <= 1;
        done_s <= 0; 
        sdo <= data[7];
    end else begin
        done_s <= 0;
        sdo <= data[7-counter];
        if(counter==7)begin
            done_s <= 1;
            counter <=0;
        end else begin
            counter++;
        end
        
    end       
  end


endmodule