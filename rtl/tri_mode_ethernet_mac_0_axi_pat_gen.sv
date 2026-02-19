//------------------------------------------------------------------------------
// File       : tri_mode_ethernet_mac_0_axi_pat_gen.v
// Author     : Muhammad Boota
// -----------------------------------------------------------------------------

import defines::*;
module tri_mode_ethernet_mac_0_axi_pat_gen #(
   parameter               DEST_ADDR      = 48'hda0102030405,
   parameter               SRC_ADDR       = 48'h5a0102030405,
   parameter               MAX_SIZE       = 16'd500,
   parameter               MIN_SIZE       = 16'd64,
   parameter               ENABLE_VLAN    = 1'b0,
   parameter               VLAN_ID        = 12'd2,
   parameter               VLAN_PRIORITY  = 3'd2
)(
   input logic               clk,
   input logic               rst_n,

   input logic [7:0]        r_data,
   input logic              r_valid,
   input logic              r_last,
   output logic             r_ready,

   output logic  [7:0]      tdata,
   output logic             tvalid,
   output logic             tlast,
   input logic              tready
);
header rx_header;
address header_addr;
logic [7:0] rx_data;
logic brx_empty,rx_header_valid;
logic [1:0] [7:0] payload_len;
logic brx_rd_en;
logic [7:0] tx_data;
logic tx_valid;
logic [1:0][7:0] number_of_bytes;
logic btx_full;

assign header_addr=rx_header.addr;
assign payload_len=rx_header.payload_len;

receiver U_receiver(
    .*
); 
transmitter U_transmitter(
    .*
); 
dut U_dut(
    .*
);


endmodule
