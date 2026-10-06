`timescale 1ns / 1ps

module tpu_axi_wrapper #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 6, 
    
    // parameters
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 19,
    parameter GRID_SIZE  = 8,
    parameter ADDR_WIDTH = 10
)(
    input  logic S_AXI_ACLK,
    input  logic S_AXI_ARESETN,

    input  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  logic [2:0]                    S_AXI_AWPROT,
    input  logic                          S_AXI_AWVALID,
    output logic                          S_AXI_AWREADY,

    input  logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  logic                          S_AXI_WVALID,
    output logic                          S_AXI_WREADY,

    output logic [1:0]                    S_AXI_BRESP,
    output logic                          S_AXI_BVALID,
    input  logic                          S_AXI_BREADY,

    input  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  logic [2:0]                    S_AXI_ARPROT,
    input  logic                          S_AXI_ARVALID,
    output logic                          S_AXI_ARREADY,

    output logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output logic [1:0]                    S_AXI_RRESP,
    output logic                          S_AXI_RVALID,
    input  logic                          S_AXI_RREADY
);
    logic aw_en;
    logic axi_awready;
    logic axi_wready;
    logic axi_bvalid;
    logic axi_arready;
    logic axi_rvalid;
    logic [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = 2'b00; // OKAY response
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = 2'b00; // OKAY response
    assign S_AXI_RVALID  = axi_rvalid;

    // Memory Map:
    // 0x00 : Control Reg (Bit 0: Start - auto clears)
    // 0x04 : Status Reg  (Bit 0: Busy, Bit 1: Done)
    // 0x08 : Weight Base Address
    // 0x0C : Activation Base Address
    // 0x10 : Output Base Address
    // 0x14 : Activation Rows
    
    logic start_pulse;
    logic [ADDR_WIDTH-1:0] reg_weight_base;
    logic [ADDR_WIDTH-1:0] reg_act_base;
    logic [ADDR_WIDTH-1:0] reg_out_base;
    logic [15:0]           reg_act_rows;
    
    logic tpu_busy;
    logic tpu_done;
    always_ff @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            axi_wready <= 1'b0;
        end else begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
                axi_wready <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            axi_bvalid <= 1'b0;
            start_pulse <= 1'b0;
            reg_weight_base <= '0;
            reg_act_base <= '0;
            reg_out_base <= '0;
            reg_act_rows <= '0;
        end else begin
            start_pulse <= 1'b0; 

            if (axi_awready && S_AXI_AWVALID && axi_wready && S_AXI_WVALID) begin
                axi_bvalid <= 1'b1;
                
                // Write Decode
                case (S_AXI_AWADDR[5:2])
                    4'h0: if (S_AXI_WDATA[0]) start_pulse <= 1'b1; // 0x00: Trigger Start
                    4'h2: reg_weight_base <= S_AXI_WDATA[ADDR_WIDTH-1:0]; // 0x08
                    4'h3: reg_act_base    <= S_AXI_WDATA[ADDR_WIDTH-1:0]; // 0x0C
                    4'h4: reg_out_base    <= S_AXI_WDATA[ADDR_WIDTH-1:0]; // 0x10
                    4'h5: reg_act_rows    <= S_AXI_WDATA[15:0];           // 0x14
                    default: ;
                endcase
            end else begin
                if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
            end
        end
    end
    always_ff @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rdata   <= '0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
                axi_rvalid  <= 1'b1;
                
                // Read Decode
                case (S_AXI_ARADDR[5:2])
                    4'h1: axi_rdata <= {30'd0, tpu_done, tpu_busy}; // 0x04: Status
                    4'h2: axi_rdata <= reg_weight_base;
                    4'h3: axi_rdata <= reg_act_base;
                    4'h4: axi_rdata <= reg_out_base;
                    4'h5: axi_rdata <= reg_act_rows;
                    default: axi_rdata <= '0;
                endcase
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid  <= 1'b0;
                axi_arready <= 1'b0;
            end
        end
    end

    tpu_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .GRID_SIZE(GRID_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_tpu_core (
        .clk(S_AXI_ACLK),
        .rst_ni(S_AXI_ARESETN),
        .start(start_pulse),
        .csr_weight_base(reg_weight_base),
        .csr_act_base(reg_act_base),
        .csr_out_base(reg_out_base),
        .csr_act_rows(reg_act_rows),
        .busy(tpu_busy),
        .done(tpu_done)
    );

endmodule