module Buffer #(parameter SIZE = 2048)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_valid,
    input  logic        btx_rd_en,
    input  logic [7:0]  tx_data,
    output logic        btx_full,
    output logic        btx_empty,
    output logic [7:0]  btx_data
);

    // Buffer size is num_msg_bytes, pointers are 13 bits
    logic [$clog2(SIZE)-1:0] wptr, rptr, wptr_n,wptr_next, rptr_n, w_count;
    logic [7:0] buffer [0:SIZE-1]; // 11 bits addressable (max 2048 bytes)
    
    // Write in Buffer
    always_ff @(posedge clk) begin
        if (tx_valid & !btx_full) begin
            buffer[wptr] <= tx_data;  
        end
    end
    
    //Read from Buffer
    always_ff @(posedge clk) begin
        if (btx_rd_en & !btx_empty) begin
            btx_data <= buffer[rptr];
        end
    end

    // write and read pointer registers
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wptr <= 0;
            rptr <= 0;
        end else begin
            wptr <= wptr_n;
            rptr <= rptr_n;
        end
    end

    // write pointer next value logic
    always_comb begin
        if (tx_valid & !btx_full) begin
            wptr_n = wptr_next;
        end else begin
            wptr_n = wptr;
        end
    end

    // read pointer next value logic
    always_comb begin
        if (btx_rd_en & !btx_empty) begin
            rptr_n = rptr + 1;
        end else begin
            rptr_n = rptr;
        end
    end

// Buffer full and empty logic
    assign wptr_next = wptr + 1;
    assign btx_full = (wptr_next == rptr) ? 1 : 0; // Buffer is full when next write pointer equals read pointer
    assign btx_empty = (wptr == rptr) ? 1 : 0; // Buffer is empty when write pointer equals read pointer

endmodule