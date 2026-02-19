import defines ::*;
module transmitter_tb ();
    event header_valid_event;
    logic clk;
    logic rst_n;
    address header_addr;
    logic [1:0] [7:0] number_of_bytes;
    logic [7:0] tx_data;
    logic tx_valid;
    logic tready;
    logic rx_header_valid;
    logic [7:0] tdata;
    logic btx_full;
    logic tvalid;
    logic tlast;
    transmitter transmitter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .header_addr(header_addr),
        .number_of_bytes(number_of_bytes),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tready(tready),
        .rx_header_valid(rx_header_valid),
        .tdata(tdata),
        .btx_full(btx_full),
        .tvalid(tvalid),
        .tlast(tlast)
    );
    task driver (logic [1:0] [7:0] bytes, logic [7:0] data);
            @(posedge clk);
            header_addr.dst = '{6{8'h3F}};
            header_addr.src = '{6{8'h3F}};
            number_of_bytes=bytes;
            rx_header_valid=1;
            @(posedge clk);
            rx_header_valid=0;
            @(posedge clk);
            tready=1;
            repeat (bytes)begin
                tx_data=data;
                tx_valid=1;
                @(posedge clk);
                tx_valid=0;
                @(posedge clk); 
            end
            tready=0;
    endtask
    task monitor;
            @(posedge clk);
            if (tvalid) begin
                $display("Time: %0t, Data: %h, Last: %b",$time,tdata,tlast);
        end
    endtask
    initial begin 
        clk=0;
        forever #5 clk=~clk;
    end
    initial begin
        rst_n=0;
        tready=0;
        header_addr.dst = '{6{8'h00}};
        header_addr.src = '{6{8'h00}};
        number_of_bytes= {8'h00,8'h00};
        tx_data=8'h00;
        rx_header_valid=0;
        tx_valid=0;
        #50;
        rst_n=1;
        #10;
            fork 
                for (int i=0;i<5;i++) begin
                    driver({8'h00,8'h20},8'hCC);
                    monitor();
                end
                
            join_any
        $stop;

    end


endmodule