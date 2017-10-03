`include "mipsfpga_ahb_const.vh"

module mipsfpga_ahb_dmaregs(
    input           HCLK,
    input           HRESETn,
    input  [  3: 0] HADDR,
    input  logic    [ 31: 0] HWDATA,
    input           HWRITE,
    input           HSEL,
    output logic    [ 31: 0] HRDATA,
    
    output          DMA_INTERRUPT, // asserted when start and size!=0
    input           CLEAR_START // asynchronous reset of the start
);

logic [31:0] dma_start;
logic [31:0] dma_dst;
logic [31:0] dma_size;
logic [31:0] dma_src;
logic [31:0] dma_keylo;
logic [31:0] dma_keyhi;
logic [1:0] dma_ed; //encrypt/decryp 


always_ff @(posedge HCLK or negedge HRESETn)
begin
       if(CLEAR_START)begin
            dma_start <= 0;
       end
       if (~HRESETn) begin
            dma_start <= 0;
            dma_dst <= 0;
            dma_size <= 0;
            dma_src <= 0;
       end else if (HWRITE & HSEL) begin
            case (HADDR)
                `DMA_START_ADDR:    dma_start<=HWDATA;
                `DMA_SRC_ADDR :     dma_src<=HWDATA;
                `DMA_SIZE_ADDR:     dma_size<=HWDATA;
                `DMA_DST_ADDR :     dma_dst<=HWDATA; 
                `DMA_KEYHI_ADDR:    dma_keyhi <= HWDATA;
                `DMA_KEYLO_ADDR:    dma_keylo <= HWDATA;
                `DMA_ED_ADDR :      dma_ed <= HWDATA[1:0];
            endcase
       end
end     
       
always_comb
     case (HADDR)
        `DMA_START_ADDR:    HRDATA = dma_start;
        `DMA_SRC_ADDR :     HRDATA = dma_src;
        `DMA_SIZE_ADDR:     HRDATA = dma_size;
        `DMA_DST_ADDR :     HRDATA = dma_dst; 
        `DMA_KEYLO_ADDR:    HRDATA = dma_keylo;
        `DMA_KEYHI_ADDR:    HRDATA = dma_keyhi;
        `DMA_ED_ADDR:       HRDATA = {30'h0 , dma_ed};
        default:            HRDATA = 32'h00000000;
     endcase       
       
assign  DMA_INTERRUPT = (dma_start!=0) && (dma_size!=0);
       
endmodule
