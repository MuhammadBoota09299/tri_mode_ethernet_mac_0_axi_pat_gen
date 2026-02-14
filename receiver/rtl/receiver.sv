import defines::*;
module receiver (
    input logic clk,
    input logic rst_n,
    input logic brx_rd_en,
    input logic [7:0] rx_axis_tdata,
    input logic rx_axis_tvalid,
    input logic rx_axis_tlast,
    output logic rx_axis_tready,
    output logic brx_empty,
    output header rx_header,
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
    counter U_counter (
        .*
    );
    
    // Instantiate RX Buffer
    Buffer U_rx_buffer (
        .*
    );
    
    //Instantiate RX FSM
    rx_controller RX_controller (
        .*
    );

endmodule