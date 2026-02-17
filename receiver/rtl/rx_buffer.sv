module Buffer #(parameter SIZE = 2048)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        brx_valid,
    input  logic        brx_rd_en,
    input  logic [7:0]  rx_axis_tdata,
    output logic        brx_full,
    output logic        brx_empty,
    output logic [7:0]  rx_data
);

    // Buffer size is num_msg_bytes, pointers are 13 bits
    logic [$clog2(SIZE)-1:0] wptr, rptr, wptr_n,wptr_next, rptr_n;
    logic [7:0] buffer [0:SIZE-1]; // 11 bits addressable (max 2048 bytes)
    
    // Write in Buffer
    always_ff @(posedge clk) begin
        if (brx_valid & !brx_full) begin
            buffer[wptr] <= rx_axis_tdata;  
        end
    end
    
    //Read from Buffer
    always_ff @(posedge clk) begin
        if (brx_rd_en & !brx_empty) begin
            rx_data <= buffer[rptr];
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
        if (brx_valid & !brx_full) begin
            wptr_n = wptr_next;
        end else begin
            wptr_n = wptr;
        end
    end

    // read pointer next value logic
    always_comb begin
        if (brx_rd_en & !brx_empty) begin
            rptr_n = rptr + 1;
        end else begin
            rptr_n = rptr;
        end
    end

// Buffer full and empty logic
    assign wptr_next = wptr + 1;
    assign brx_full = (wptr_next == rptr) ? 1 : 0; // Buffer is full when next write pointer equals read pointer
    assign brx_empty = (wptr == rptr) ? 1 : 0; // Buffer is empty when write pointer equals read pointer

endmodule