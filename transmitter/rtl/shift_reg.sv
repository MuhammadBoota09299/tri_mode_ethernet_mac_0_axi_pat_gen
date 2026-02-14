module shift_reg (
    input header tx_header,
    input logic clk,rst_n,shift_en,shift_wr,
    output logic [7:0] header_bits
);
header header_next,header_reg;
    always_comb begin 
        if (shift_en) begin
            tx_header_next={header_reg[103:0],header_reg[111:104]};
        end else begin
            tx_header_next=header_reg;
        end
    end
    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            header_reg<=112'b0;
        end else begin
            if (shift_wr) begin
                header_reg <= tx_header;
            end else begin
                header_reg <= tx_header_next;
            end
        end
    end
endmodule