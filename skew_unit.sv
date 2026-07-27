module skew_unit #(
    parameter DATA_WIDTH = 8,
    parameter PIPELINE_DEPTH = 2
) (
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0][DATA_WIDTH-1:0] in_data,
    output logic [DATA_WIDTH-1:0][DATA_WIDTH-1:0] out_data
);

    assign out_data[0] = in_data[0];
    genvar i;
    generate
        for (i = 1; i < DATA_WIDTH; i++) begin : gen_skew_pipeline
            logic [DATA_WIDTH-1:0] pipe [0:i-1];
            localparam delay = i * PIPELINE_DEPTH;
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    for (int k = 0; k < delay; k++) begin
                        pipe[k] <= '0;
                    end
                end else begin
                    pipe[0] <= in_data[i];

                    for (int k = 1; k < delay; k++) begin
                        pipe[k] <= pipe[k-1];
                    end
                end
            end

            assign out_data[i] = pipe[i-1];
        end
    endgenerate

endmodule