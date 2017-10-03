`include "mipsfpga_ahb_const.vh"

`define DMA_BASE_ADDR 27'hf98000
`define FIFO_SIZE 256

module mipsfpga_dma_engine (
output                      HCLK,
output                      HRESETn,
output logic    [ 31: 0]    HADDR,
output          [  2: 0]    HBURST,
output                      HMASTLOCK,
output          [  3: 0]    HPROT,
output          [  2: 0]    HSIZE,
output logic    [  1: 0]    HTRANS,
output logic    [ 31: 0]    HWDATA,
output logic                HWRITE,
input  logic    [ 31: 0]    HRDATA,
input                       HREADY,
input                       HRESP,

input                       CPU_CLK,
input                       CPU_RESETn,
input                       DMA_INTERRUPT,
output logic                CLEAR_START 
);

//synchronize cpu and dma engine
assign HCLK = CPU_CLK;
assign HRESETn = CPU_RESETn; 

assign HMASTLOCK = 0;
assign HPROT = 4'b0010;
assign HSIZE = 3'b010;
assign HBURST = 3'b000;

typedef enum { IDLE, GET_SIZE, GET_SRC, GET_DST, GET_DATA, GET_ED, DES, GET_KEYLO, GET_KEYHI, SEND_DATA} state_t;
state_t dma_state;

logic [31:0] fifo [`FIFO_SIZE-1:0];
integer fifo_counter = 0;

logic [31:0] dma_src;
logic [31:0] dma_dst;
logic [31:0] dma_size;
logic [63:0] des_key;
logic [63:0] des_data_in;
logic [63:0] des_data_out;
logic [1:0] des_encryptDecrypt;
    
always @(posedge CPU_CLK, negedge CPU_RESETn)
begin
    if(~CPU_RESETn) begin 
        dma_state <= IDLE;
        fifo_counter <= 0;
        
        dma_src <= 0;
        dma_dst <= 0;
        dma_size <= 0;
        
        HTRANS <= 2'b00;
        HWRITE <= 0;
        HWDATA <= 0;
        HADDR <= 0;
        
    end else begin
        CLEAR_START<=0;
        case (dma_state)
             IDLE :     begin
                            if(HREADY) begin
                                HWDATA<= 0;
                                HTRANS<= 2'b00;
                            end
                            if(DMA_INTERRUPT) begin
                                HTRANS <= 2'b10;
                                HADDR  <= {`DMA_BASE_ADDR ,`DMA_SIZE_ADDR};
                                if(HREADY) begin 
                                    dma_state <= GET_SIZE;
                                    fifo_counter <= 0;
                                    CLEAR_START <= 1;
                                end 
                                
                            end 
                        end 
             GET_SIZE:  begin
                            if(~HRESP && HREADY) begin
                                dma_size <= HRDATA;
                                dma_state <= GET_SRC;
                                HADDR  <= {`DMA_BASE_ADDR ,`DMA_SRC_ADDR};
                            end
                        end
             GET_SRC:   begin
                            if(~HRESP && HREADY) begin
                                dma_src <= HRDATA;
                                dma_state <= GET_DST;
                                HADDR  <= {`DMA_BASE_ADDR ,`DMA_DST_ADDR};
                            end 
                        end
             GET_DST:   begin
                            if(~HRESP && HREADY) begin
                                dma_dst <= HRDATA;
                                dma_state <= GET_ED;
                                HADDR  <= {`DMA_BASE_ADDR,`DMA_ED_ADDR};
                            end 
                        end

             GET_ED:   begin
                            if(~HRESP && HREADY) begin
                                des_encryptDecrypt <= HRDATA;
                                if(HRDATA==0) begin
                                    dma_state <= GET_DATA;
                                    HADDR <= dma_src;
                                end else begin
                                    dma_state <= GET_KEYHI;
                                    HADDR <= {`DMA_BASE_ADDR, `DMA_KEYHI_ADDR};
                                end
                            end
                       end
             GET_KEYHI: begin
                         if(~HRESP && HREADY) begin
                             des_key[63:32] <= HRDATA;
                             dma_state <= GET_KEYLO;
                             HADDR <= {`DMA_BASE_ADDR, `DMA_KEYLO_ADDR};
                         end
                        end 
             GET_KEYLO: begin
                         if(~HRESP && HREADY) begin
                             des_key[31:0] <= HRDATA;
                             dma_state <= GET_DATA;
                             HADDR <= dma_src;
                         end
                        end 
             GET_DATA: begin 
                            if(~HRESP && HREADY) begin 
                                fifo[fifo_counter] <= HRDATA;
                                if(fifo_counter<dma_size-1) begin
                                        fifo_counter++;
                                        HADDR <= HADDR+4;
                                end else begin
                                        fifo_counter <= 0;
                                        if(des_encryptDecrypt==0) begin
                                            HADDR <= dma_dst;
                                            HWRITE <= 1;
                                            dma_state <= SEND_DATA;
                                        end else begin
                                            dma_state <= DES;
                                            HADDR <= 32'h0;
                                            des_data_in <= {fifo[0],fifo[1]};
                                            fifo_counter <= 2;
                                        end;
                                end 
                            end
                       end 
             DES:       begin
                            fifo[fifo_counter-2] = des_data_out[63:32];
                            fifo[fifo_counter-1] = des_data_out[31:0];
                            if(fifo_counter>=dma_size) begin
                                fifo_counter <= 0;
                                dma_state <= SEND_DATA;
                                HADDR <= dma_dst;
                                HWRITE <= 1;
                            end else begin
                                des_data_in <= {fifo[fifo_counter], fifo[fifo_counter+1]};
                                fifo_counter <= fifo_counter+2;
                            end
                        end

             SEND_DATA: begin 
                            if(~HRESP && HREADY) begin 
                                HWDATA <= fifo[fifo_counter];
                                if(fifo_counter<dma_size-1) begin
                                        fifo_counter++;
                                        HADDR <= HADDR+4;
                                end else begin
                                        fifo_counter <= 0;
                                        HADDR <= 0;
                                        HWRITE<= 0;
                                        dma_state <= IDLE;
                                end 
                            end
                       end 
        endcase
                                 
    end
end
dma_des  des_engine (
    des_encryptDecrypt,
    des_key,
    des_data_in,
    des_data_out
);

endmodule
