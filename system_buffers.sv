module buffers #(
        parameter DATA_WIDTH = 64, // because 8 bit num in an 8x8 matrix and i want to fit and shift one row at a time 
        parameter FIFO_DEPTH = 10 // how deep it is 
) (
    input logic clk,
    input logic rst,
    input logic write_valid,
    output logic write_ready,
    input  logic [DATA_WIDTH-1:0] write_data,
    

);
    
endmodule