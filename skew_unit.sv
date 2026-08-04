module skew_unit #(
    parameter DATA_WIDTH = 8,
    parameter GRID_SIZE  = 8,
    // How many pipeline stages a signal takes to cross one PE
    parameter DELAY_PER_STEP = 2 
)(
    input  logic clk,
    input  logic rst_n, // Changed to active-low standard
    input  logic [GRID_SIZE-1:0][DATA_WIDTH-1:0] in_data,
    output logic [GRID_SIZE-1:0][DATA_WIDTH-1:0] out_data
);

    genvar row;
    generate
        for (row = 0; row < GRID_SIZE; row++) begin : gen_skew_rows
            localparam DELAY = row * DELAY_PER_STEP;
            
            if (DELAY == 0) begin : gen_no_delay
                assign out_data[row] = in_data[row];
            end else begin : gen_delay
                // Create a shift register of exact required depth
                logic [DELAY-1:0][DATA_WIDTH-1:0] pipe;
                
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        pipe <= '0;
                    end else begin
                        pipe[0] <= in_data[row];
                        for (int k = 1; k < DELAY; k++) begin
                            pipe[k] <= pipe[k-1];
                        end
                    end
                end
                
                // Tap the end of the shift register
                assign out_data[row] = pipe[DELAY-1];
            end
        end
    endgenerate

endmodule