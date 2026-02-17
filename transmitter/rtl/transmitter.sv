import defines::*;
module transmitter (
    input logic clk,rst_n,
    input address header_addr,
    input logic [1:0] [7:0] number_of_bytes,
    input logic [7:0] tx_data,
    input logic tx_valid,
    input logic tx_axis_tready,
    input logic rx_header_valid,
    output logic [7:0] tx_axis_tdata,
    output logic btx_full,
    output logic tx_axis_tvalid,
    output logic tx_axis_tlast
);
logic address_wr,btx_rd_en,payload_en,payload_cal,shift_en,tx_tvalid_sel;
logic shift_wr,data_select,data,remain_zero,btx_empty,count_en,tx_valid_reg;
logic [7:0] header_bits,btx_data;
logic [1:0] [7:0] payload_len;
address tx_address;
header tx_header;

assign tx_axis_tvalid = (tx_tvalid_sel) ? 1'b1 : tx_valid_reg;
assign tx_header={tx_address,payload_len};
assign tx_axis_tdata=(data_select) ? btx_data:header_bits;

tx_address_reg address_reg(
    .*
);
payload_len_cal payload_calculator(
    .*
);

controller ctrl(
    .*
);

Buffer tx_buffer(
    .*
);

counter payload_counter(
    .*
);

shift_reg shift_register(
    .*
);

always_ff @( posedge clk ) begin : blockName
    if (!rst_n) begin
        tx_valid_reg <= 1'b0;
    end else begin
        tx_valid_reg <= btx_rd_en;
    end
end

endmodule