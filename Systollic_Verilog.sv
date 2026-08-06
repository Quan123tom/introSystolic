module PE#(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 19
)(
    input  logic clk,
    input  logic rst_ni, 
    input  logic load_en,
    output logic load_en_out,
    input  logic signed [DATA_WIDTH-1:0] activations_in,
    input  logic signed [ACC_WIDTH-1:0]  sums_in,
    output logic signed [DATA_WIDTH-1:0] activations_out,
    output logic signed [ACC_WIDTH-1:0]  sums_out
);

    logic signed [DATA_WIDTH-1:0] weight_reg;
    logic signed [DATA_WIDTH-1:0] stage1_act;
    logic signed [ACC_WIDTH-1:0]  stage1_sum;
    logic signed [ACC_WIDTH-1:0]  stage1_prod;

    logic stage1_load_en;
    always_ff @(posedge clk or negedge rst_ni) begin
        if (!rst_ni) begin
            weight_reg <= '0;
            stage1_act <= '0;
            stage1_sum <= '0;
            stage1_prod <= '0;
            stage1_load_en  <= 1'b0;
            activations_out <= '0;
            sums_out <= '0;
            load_en_out <= 1'b0;
        end else begin

            stage1_load_en <= load_en;
            
            if (load_en) begin
                weight_reg  <= sums_in[DATA_WIDTH-1:0]; 
                stage1_sum  <= sums_in;                 
                stage1_act  <= '0;                      
                stage1_prod <= '0;
            end else begin
                stage1_act  <= activations_in;
                stage1_sum  <= sums_in;                 
                stage1_prod <= gated_act * gated_wt;
            end

            load_en_out <= stage1_load_en;
            
            if (stage1_load_en) begin
                sums_out <= stage1_sum;
                activations_out <= '0;
            end else begin
                sums_out <= stage1_prod + stage1_sum;
                activations_out <= stage1_act;
            end
        end
    end
endmodule