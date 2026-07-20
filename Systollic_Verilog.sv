
module PE #(
    parameter DATA_WIDTH = 8;
    input logic clk;
    input logic rst;
    input logic [DATA_WIDTH - 1 : 0] activations_in; //left -> right
    input logic [DATA_WIDTH-1:0] sums_in; // top -> bottom
    input logic [DATA_WIDTH-1:0] weight_reg;  // weight stationary so it stays put
    output logic [DATA_WIDTH-1:0] sums_out;
    output logic [DATA_WIDTH-1:0] activations_out;
);
    always_ff @( posedge clk or posedge rst ) begin : 
        if (rst) begin
            activations_out <= '0;
            sums_out <= 0'
        end
        else begin
            activations_out <= activations_in;
            // will use pipelining for the MAC operation here. 
            // sum1 <= 
    end
    
endmodule