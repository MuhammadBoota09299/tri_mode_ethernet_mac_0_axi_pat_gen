module buffer #(parameter SIZE = 64)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx_valid,
    input  logic        btx_ready,
    input  logic [7:0]  tx_data,
    output logic        tx_ready,
    output logic        btx_valid,
    output logic [7:0]  btx_data
);

    // Buffer size is num_msg_bytes, pointers are 13 bits
    logic [$clog2(SIZE)-1:0] wptr, rptr, wptr_n, rptr_n, w_count;
    logic [7:0] buffer [0:SIZE-1]; // 11 bits addressable (max 2048 bytes)
    logic empty,full;
    
    assign wptr_n = wptr+1;
    assign empty    = (wptr == rptr);
    assign w_count  = (wptr + 1);
    assign full = (w_count == rptr);
    assign rptr_n = rptr+1;





    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wptr <= 0;
            buffer[wptr] <= 8'b0;
        end else begin
            if (rx_valid && !full) begin
                buffer[wptr] <= tx_data;
                wptr         <= wptr_n;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rptr <= 1'b0;
            btx_data <= 1'b0;
        end else begin
            if (btx_ready && !empty) begin
                btx_data  <= buffer[rptr];
                rptr     <= rptr_n;
        end
            
        end
    end

    always_ff @( posedge clk ) begin 
        if (!rst_n) begin
            btx_valid <= 1'b0;
            tx_ready <= 1'b0;
        end else begin
            btx_valid <= !empty;
            tx_ready <= !full;
        end
    end
endmodule