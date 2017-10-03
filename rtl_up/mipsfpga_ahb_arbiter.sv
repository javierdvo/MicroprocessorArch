module mipsfpga_ahb_arbiter(
    //CPU master
    input               HCLKcpu,
    input               HRESETncpu,
    input      [ 31: 0] HADDRcpu,
    input      [  2: 0] HBURSTcpu,
    input               HMASTLOCKcpu,
    input      [  3: 0] HPROTcpu,
    input      [  2: 0] HSIZEcpu,
    input      [  1: 0] HTRANScpu,
    input      [ 31: 0] HWDATAcpu,
    input               HWRITEcpu,
    output     logic[ 31: 0] HRDATAcpu,
    output     logic         HREADYcpu,
    output     logic         HRESPcpu,
    
    // DMA master
    input               HCLKdma,
    input               HRESETndma,
    input      [ 31: 0] HADDRdma,
    input      [  2: 0] HBURSTdma,
    input               HMASTLOCKdma,
    input      [  3: 0] HPROTdma,
    input      [  2: 0] HSIZEdma,
    input      [  1: 0] HTRANSdma,
    input      [ 31: 0] HWDATAdma,
    input               HWRITEdma,
    output     logic[ 31: 0] HRDATAdma,
    output     logic         HREADYdma,
    output     logic         HRESPdma,
    
    //Slave
    output      logic         HCLK,
    output      logic         HRESETn,
    output      logic[ 31: 0] HADDR,
    output      logic[  2: 0] HBURST,
    output      logic         HMASTLOCK,
    output      logic[  3: 0] HPROT,
    output      logic[  2: 0] HSIZE,
    output      logic[  1: 0] HTRANS,
    output      logic [ 31: 0] HWDATA,
    output      logic         HWRITE,
    input       [ 31: 0] HRDATA,
    input              HREADY,
    input              HRESP
);

typedef enum {CPU,DMA} state_t;
state_t state=CPU;

logic clk;
logic resetn;
assign clk = HCLKdma & HCLKcpu;
assign resetn = HRESETncpu & HRESETndma;

always @(posedge clk, negedge resetn)
begin
    if(~resetn) begin
        state <= CPU;
    end else begin
        case (state)
            CPU:    begin
                        // always give priority to DMA
                        if(HTRANSdma==2'b10)
                            if(HTRANScpu==0)
                                state <= DMA;
                    end
            DMA:    begin
                        // gives access back to cpu only when dma has fibished
                        if(HTRANSdma==0)
                            state <= CPU;
                    end
            default: state <= state;
        endcase 
    end
end

always_comb 
begin
    case (state)
            CPU: begin
                    HRDATAcpu=HRDATA;
                    HREADYcpu=1;
                    HRESPcpu=HRESP;
                    
                    HRDATAdma=32'b0;
                    HREADYdma=0;
                    HRESPdma=1;
                    
                    HCLK=HCLKcpu;
                    HRESETn=HRESETncpu;
                    HADDR=HADDRcpu;
                    HBURST=HBURSTcpu;
                    HMASTLOCK=HMASTLOCKcpu;
                    HPROT=HPROTcpu;
                    HSIZE=HSIZEcpu;
                    HTRANS=HTRANScpu;
                    HWDATA=HWDATAcpu;
                    HWRITE=HWRITEcpu;
                 end
                 
            DMA: begin                    
                    HRDATAcpu=32'b0;
                    HREADYcpu=0;
                    HRESPcpu=1;
                 
                    HRDATAdma=HRDATA;
                    HREADYdma=1;
                    HRESPdma=0;
                 
                    HCLK=HCLKdma;
                    HRESETn=HRESETndma;
                    HADDR=HADDRdma;
                    HBURST=HBURSTdma;
                    HMASTLOCK=HMASTLOCKdma;
                    HPROT=HPROTdma;
                    HSIZE=HSIZEdma;
                    HTRANS=HTRANSdma;
                    HWDATA=HWDATAdma;
                    HWRITE=HWRITEdma;
            
                 end
            default: 
                 begin
                     HRDATAcpu=0;
                     HREADYcpu=0;
                     HRESPcpu=1;
                     
                     HRDATAdma=0;
                     HREADYdma=0;
                     HRESPdma=1;
                     
                     HCLK=HCLKcpu;
                     HRESETn=HRESETncpu;
                     HADDR=HADDRcpu;
                     HBURST=HBURSTcpu;
                     HMASTLOCK=HMASTLOCKcpu;
                     HPROT=HPROTcpu;
                     HSIZE=HSIZEcpu;
                     HTRANS=HTRANScpu;
                     HWDATA=HWDATAcpu;
                     HWRITE=HWRITEcpu; 
                 end
    endcase
end
        

endmodule
