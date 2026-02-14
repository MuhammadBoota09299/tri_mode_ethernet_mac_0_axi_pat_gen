import pkg ::*;
module transmitter_tb ();
    logic clk;
    logic rst_n;
    address header_addr;
    logic [1:0] [7:0] number_of_bytes;
    logic [7:0] tx_data;
    logic tx_vlaid;
    logic tx_axis_tready;
    logic rx_header_valid;
    logic [7:0] tx_axis_tdata;
    logic btx_full;
    logic tx_axis_tvalid;
    logic tx_axis_tlast;
    transmitter transmitter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .header_addr(header_addr),
        .number_of_bytes(number_of_bytes),
        .tx_data(tx_data),
        .tx_vlaid(tx_vlaid),
        .tx_axis_tready(tx_axis_tready),
        .rx_header_valid(rx_header_valid),
        .tx_axis_tdata(tx_axis_tdata),
        .btx_full(btx_full),
        .tx_axis_tvalid(tx_axis_tvalid),
        .tx_axis_tlast(tx_axis_tlast)
    );
    task driver (logic [1:0] [7:0] number_of_bytes, logic [7:0] tx_data);
            @(negedge clk);
            header_addr.dst=6{8'h3F};
            header_addr.src=6{8'h3F};
            number_of_bytes=number_of_bytes;
            repeat (number_of_bytes)begin
                tx_data=tx_data;
                tx_vlaid=1;
                @(posedge clk);
                tx_vlaid=0;
                @(posedge clk); 
            end
    endtask
    task monitor;
        forever begin
            @(posedge clk);
            if (tx_axis_tvalid) begin
                $display("Time: %0t, Data: %h, Last: %b",$time,tx_axis_tdata,tx_axis_tlast);
            end
        end
    endtask
    initial begin 
        clk=0;
        forever #5 clk=~clk;
    end
    initial begin
        rst_n=0;
        header_addr.dst=6{8'h00};
        header_addr.src=6{8'h00};
        number_of_bytes=2'{8'h00,8'h00};
        tx_data=8'h00;
        tx_vlaid=0;
        #10;
        rst_n=1;
        #10;
            fork
                monitor();
                driver(2'{8'hAA,8'hBB},8'hCC);
            join
        $stop;

    end


endmodule