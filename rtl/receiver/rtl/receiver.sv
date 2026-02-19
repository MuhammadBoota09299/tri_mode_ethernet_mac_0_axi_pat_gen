import defines::*;
module receiver (
    input logic clk,
    input logic rst_n,
    input logic brx_rd_en,
    input logic [7:0] r_data,
    input logic r_valid,
    input logic r_last,
    output logic r_ready,
    output logic brx_empty,
    output header rx_header,
    output logic rx_header_valid,
    output logic [7:0] rx_data
);
    // Internal signals
    logic [3:0] count;
    logic header_en,count_en,brx_valid,brx_full;
    
    // Instantiate Header Register
    header_reg U_header_reg (
        .*
    );
    
    // Instantiate Counter
    rx_counter Rx_counter (
        .*
    );
    
    // Instantiate RX Buffer
    rx_buffer U_rx_buffer (
        .*
    );
    
    //Instantiate RX FSM
    rx_controller RX_controller (
        .*
    );

endmodule