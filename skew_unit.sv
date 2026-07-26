module skew_unit #(
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0][DATA_WIDTH-1:0] in_data,
    output logic [DATA_WIDTH-1:0][DATA_WIDTH-1:0] out_data,
);
    genvar i,j;
    generate
    assign out_data[0] = in_data[0];

    for (genvar i = 1; i < DATA_WIDTH; i++) begin
        logic [i-1:0][DATA_WIDTH-1:0] pipe;

        always_ff @(posedge clk or posedge rst) begin
            if (rst)
                pipe <= '0;
                
            else begin
                pipe[0] <= in_data[i];
                for (int k = 1; k < i; k++)
                    pipe[k] <= pipe[k-1];
            end
        end

        assign out_data[i] = pipe[i-1];
    end
endgenerate
    
endmodule