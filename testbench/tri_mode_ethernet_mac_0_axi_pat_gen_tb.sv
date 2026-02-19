import defines::*;
module tri_mode_ethernet_mac_0_axi_pat_gen_tb #(
   parameter               MAX_SIZE       = 16'd500
)();
logic clk,rst_n;
logic [7:0] r_data;
logic       r_valid;
logic       r_last;
logic       r_ready;
logic [7:0] tdata;
logic       tvalid;
logic       tlast;
logic       tready;


tri_mode_ethernet_mac_0_axi_pat_gen U_tri_mode_ethernet_mac_0_axi_pat_gen(
    .*
);


int sent_bytes;
typedef struct packed {
    header Header;
    logic [0:MAX_SIZE-1] [7:0] data ;
} frame;
frame test_frame;
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end

task automatic transfer(input logic [7:0] data);
    r_data=data;
    r_valid=1'b1;
    @(posedge clk);
    while (!r_ready) begin
        @(posedge clk);
    end
endtask //automatic

task automatic transfer_of_frame(input frame test_frame, input int bytes);
    logic [111:0] hdr_flat; // header = 6+6+2 = 14 bytes = 112 bits
    r_valid=1'b0;
    r_last=1'b0;

    // Cast header struct to flat bits, send MSB-first (dst[5] first, payload_len[0] last)
    hdr_flat = test_frame.Header;
    for (int j=13; j>=0; j--) begin
        r_last = 1'b0;
        transfer(hdr_flat[j*8 +: 8]);
    end

    // Send payload bytes in forward order
    for (int i=0; i<bytes; i++) begin
        r_last=(i==bytes-1) ? 1'b1 : 1'b0;
        transfer(test_frame.data[i]);
    end

    r_valid=1'b0;
    r_last=1'b0;
endtask //automatic

task automatic driver(input int length);
    sent_bytes=length + 14; //14 is the header size
    // dst: 6 bytes, src: 6 bytes — each field is logic [5:0][7:0]
    test_frame.Header.addr.dst = {$urandom(), $urandom()};  // 64-bit, upper 16 bits ignored by 48-bit field
    test_frame.Header.addr.src = {$urandom(), $urandom()};
    test_frame.Header.payload_len = length[15:0];
    for (int i=0; i<length; i++) begin
        test_frame.data[i] = $urandom();
    end
    transfer_of_frame(test_frame, length);
endtask //automatic

task automatic monitor();
    int received_bytes;
    logic [111:0] hdr_flat;
    tready=1'b1;
    received_bytes=0;
    hdr_flat = test_frame.Header;

    // Check header bytes first
    while (received_bytes < 14) begin
        @(posedge clk);
        if (tvalid) begin
            // Header sent MSB-first: byte 13 was sent first, byte 0 last
            $display("Received byte %0d: %h and expected header byte: %h",
                     received_bytes, tdata, hdr_flat[(13-received_bytes)*8 +: 8]);
            received_bytes+=1;
        end
    end

    // Check payload bytes
    while (received_bytes < sent_bytes) begin
        @(posedge clk);
        if (tvalid) begin
            $display("Received byte %0d: %h and expected payload byte: %h",
                     received_bytes, tdata, test_frame.data[received_bytes-14]);
            received_bytes+=1;
        end
    end
endtask //automatic

initial begin
    rst_n=1'b0;
    test_frame='0;
    r_data='0;
    r_valid=1'b0;
    r_last=1'b0;
    tready=1'b0;
    #20;
    rst_n=1'b1;
    fork
        driver(16);
        monitor();
    join
    @(posedge clk);
    $stop;
end

endmodule