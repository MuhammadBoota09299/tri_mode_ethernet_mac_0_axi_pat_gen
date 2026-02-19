module payload_len_cal (
    input logic clk,rst_n,payload_cal,payload_en,
    input logic [1:0][7:0] number_of_bytes,
    output logic remain_zero,
    output logic [1:0][7:0]payload_len
);
    logic [1:0][7:0] remain_next,remain,payload,remain_cal,next_payload_len;
    logic remain_sel,payload_sel;

    assign next_payload_len = remain - payload_len;
    // muxes
    assign remain_next=(payload_en) ? number_of_bytes:remain_cal;
    assign remain_cal=(payload_cal) ? (next_payload_len) : remain;
    assign payload = (remain_sel) ? (remain >> 1) : remain ;
    assign payload_len =( payload_sel) ? 16'd1500:payload;
    //comparaters
    assign remain_zero = (next_payload_len==16'b0);
    assign payload_sel = (remain > 16'd1600);
    assign remain_sel  =  (remain > 16'd1500);

    // payload_len_reg
    always_ff @( posedge clk ) begin
        if(!rst_n) begin
            remain <= 16'b0;
        end else begin
            remain <= remain_next;
        end
    end

endmodule