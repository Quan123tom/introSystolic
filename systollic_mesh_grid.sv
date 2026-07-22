
module systollic_grid #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 16,
    parameter GRID_SIZE = 8;
) (
    input logic clk,
    input logic rst,
    // the following is the top, bottom interconnects  
    input logic [DATA_WIDTH-1:0] in_left [0:GRID_SIZE-1], 
    input logic [DATA_WIDTH-1:0] in_top [0:GRID_SIZE-1],
    output logic [DATA_WIDTH-1:0] out_right [0:GRID_SIZE-1],
    output logic [DATA_WIDTH-1:0] out_bottom [0:GRID_SIZE-1]
);
    // now i need to make the modules that connect the PE's with eachother
    logic [DATA_WIDTH-1:0] sum_bus [0:GRID_SIZE][0:GRID_SIZE-1];
    logic [DATA_WIDTH-1:0] act_bus [0:GRID_SIZE-1][0:GRID_SIZE-1];
    // now we have the wires that connect the PE's with eachother
    genvar b;
    generate
        for (b = 0; b<GRID_SIZE; b++) begin : code_for_boundaries
            assign act_bus[b][0] = in_left[b]; // connect activations to the module
            assign sum_bus[0][b] = in_top[b]; // connect summs to the top
            assign out_bottom[b] = sum_bus[GRID_SIZE][b]; // connect the output to the actual output bus
        end
    endgenerate

    // now i must do the initializarion of the 64 PE's required for my module 
    genvar i,j;
    
endmodule