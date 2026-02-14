import defines::*;

module receiver_tb;
  logic clk, rst_n;
  logic brx_rd_en;
  logic [7:0] rx_axis_tdata;
  logic rx_axis_tvalid, rx_axis_tlast;
  logic rx_axis_tready, brx_empty;
  logic [7:0] rx_data;
  header rx_header;
  
  // Instantiate DUT
  receiver dut (.*);
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Task to send a byte
  task send_byte(input logic [7:0] data, input logic last = 0);
    @(posedge clk);
    rx_axis_tdata = data;
    rx_axis_tvalid = 1;
    rx_axis_tlast = last;
    wait(rx_axis_tready);
    @(posedge clk);
    rx_axis_tvalid = 0;
    rx_axis_tlast = 0;
  endtask
  
  // Task to send header (6 dst + 6 src + 2 length)
  task send_header(input logic [47:0] dst, src, input logic [15:0] len);
    for (int i = 0; i < 6; i++) send_byte(dst[47-i*8 -: 8]);
    for (int i = 0; i < 6; i++) send_byte(src[47-i*8 -: 8]);
    for (int i = 0; i < 2; i++) send_byte(len[15-i*8 -: 8]);
  endtask
  
  // Task to send data
  task send_data(input int n, input logic [7:0] start = 0);
    for (int i = 0; i < n; i++) 
      send_byte(start + i, (i == n-1));
  endtask
  
  // Main test
  initial begin
    // Initialize
    {rst_n, brx_rd_en, rx_axis_tdata, rx_axis_tvalid, rx_axis_tlast} = 0;
    
    // Reset
    repeat(5) @(posedge clk);
    rst_n = 1;
    repeat(2) @(posedge clk);
    
    // Test 1: Basic packet
    $display("\n=== Test 1: Basic Packet ===");
    send_header(48'hAABBCCDDEEFF, 48'h112233445566, 16'd10);
    send_data(10, 8'hA0);
    
    // Read data
    repeat(3) @(posedge clk);
    brx_rd_en = 1;
    repeat(10) @(posedge clk);
    brx_rd_en = 0;
    
    // Test 2: Another packet
    $display("\n=== Test 2: Second Packet ===");
    repeat(5) @(posedge clk);
    send_header(48'h123456789ABC, 48'hDEF012345678, 16'd5);
    send_data(5, 8'hB0);
    
    repeat(3) @(posedge clk);
    brx_rd_en = 1;
    repeat(5) @(posedge clk);
    brx_rd_en = 0;
    
    // Test 3: Minimum packet
    $display("\n=== Test 3: Minimum Packet ===");
    repeat(5) @(posedge clk);
    send_header(48'h0, 48'h0, 16'd1);
    send_data(1, 8'h55);
    
    repeat(3) @(posedge clk);
    brx_rd_en = 1;
    repeat(1) @(posedge clk);
    brx_rd_en = 0;
    
    // Done
    repeat(10) @(posedge clk);
    $display("\n=== Test Complete ===");
    $finish;
  end
  
  // Monitor
  always @(posedge clk) begin
    if (!brx_empty && brx_rd_en)
      $display("[%0t] TX Data: 0x%h", $time, rx_data);
  end
  
  // Timeout
  initial #100000 $finish;

endmodule