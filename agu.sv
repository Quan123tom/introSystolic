module agu #(
    parameter int ADDR_WIDTH = 10
)(
    input  logic clk,
    input  logic rst_ni,           
    
    input  logic load_base,        
    input  logic en,               
    input  logic [ADDR_WIDTH-1:0] base_addr,
    output logic [ADDR_WIDTH-1:0] current_addr
);

    always_ff @(posedge clk or negedge rst_ni) begin
        if (!rst_ni) begin
            current_addr <= '0;
        end else begin
            if (load_base) begin
                current_addr <= base_addr;
            end else if (en) begin
                current_addr <= current_addr + 1'b1;
            end
        end
    end

endmodule