
module PE #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 19
)(
    input logic clk,
    input logic rst,
    input logic signed [DATA_WIDTH - 1 : 0] activations_in, //left -> right
    input logic signed [ACC_WIDTH-1:0] sums_in, // top -> bottom
    input logic signed [DATA_WIDTH-1:0] weight_reg,  // weight stationary so it stays put
    output logic signed [ACC_WIDTH-1:0] sums_out,
    output logic signed [DATA_WIDTH-1:0] activations_out
);
    // stage 1 registers
    logic signed [DATA_WIDTH-1:0] stage1_acts;
    logic signed [ACC_WIDTH-1:0] stage1_product;
    logic signed [ACC_WIDTH-1:0] stage1_sums_in;
    wire signed [DATA_WIDTH-1:0] gated_act = is_zero ? '0 : activations_in;
    wire signed [DATA_WIDTH-1:0] gated_wt  = is_zero ? '0 : weight_reg;
    always_ff @( posedge clk or posedge rst ) begin  
        if (rst) begin
            stage1_acts <= '0;
            stage1_product <= '0;
            stage1_sums_in <= '0;
        end
        else begin
            stage1_acts <= activations_in;
            stage1_sums_in <= sums_in;
            stage1_product <= gated_act * gated_wt;
        end 
    end

    always_ff @( posedge clk or posedge rst ) begin 
        if (rst) begin
            sums_out <= '0;
            activations_out <= '0;
        end
        else begin
            sums_out <= stage1_product + stage1_sums_in;
            activations_out <= stage1_acts;
        end
    end
endmodule

