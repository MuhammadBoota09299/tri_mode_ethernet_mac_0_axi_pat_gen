module dut (
    input logic clk,rst_n,
    // from receiver
    input logic [7:0] rx_data,
    input logic brx_empty,
    input logic [1:0] [7:0] payload_len,
    output logic brx_rd_en,

    //from transmitter
    output logic [7:0] tx_data,
    output logic tx_valid,
    output logic [1:0][7:0] number_of_bytes,
    input logic btx_full
);
assign tx_data = rx_data;
assign number_of_bytes = payload_len;
    always_comb begin 
        if (!brx_empty && !btx_full) begin
            brx_rd_en=1'b1;
        end else begin
            brx_rd_en=1'b0;
        end
    end

    always_ff @( posedge clk ) begin 
        if (!rst_n) begin
            tx_valid <= 1'b0;
        end else begin
            tx_valid <= brx_rd_en;
        end
    end
endmodule