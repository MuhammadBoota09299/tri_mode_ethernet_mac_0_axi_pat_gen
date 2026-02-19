module rx_counter (
    input logic clk,
    input logic rst_n,
    input logic count_en,
    output logic [3:0] count
);
logic [3:0] count_next,count_q;
always_comb begin
    if (count_en) begin
        count_next = count_q;
    end else begin
        count_next = count;
    end
end
always_comb begin 
    if (count==4'd13) begin
        count_q=0;
    end else begin
        count_q = count + 1;
    end
end
always_ff @(posedge clk) begin
    if (!rst_n) begin
        count <= 0;
    end else begin
        count <= count_next;
    end
end

endmodule