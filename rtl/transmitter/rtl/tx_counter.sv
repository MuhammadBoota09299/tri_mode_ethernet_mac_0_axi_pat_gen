module tx_counter (
    input logic clk,rst_n,count_en,
    input logic [1:0][7:0] payload_len,
    output logic tlast,data
);
    logic [1:0][7:0] count,count_next,count_q;

    always_comb begin 
        if (count_en) begin
            count_q=count+1;
        end else begin
            count_q=count;
        end
    end
    always_comb begin 
        if (tlast & count_en) begin
            count_next = 16'b0;
        end else begin
            count_next =count_q;
        end
    end
    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            count <=16'b0;
        end else begin
            count <= count_next;
        end
    end

    assign tlast=(count==(payload_len+16'd13));
    assign data=(count==16'd13);
endmodule