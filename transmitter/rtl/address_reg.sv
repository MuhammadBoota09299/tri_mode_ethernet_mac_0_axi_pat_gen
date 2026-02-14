module tx_address_reg (
    input logic clk,rst_n,address_wr,
    input address rx_address,
    output address tx_address
);
    logic address address_next;
    always_comb begin 
        if (address_wr) begin
            address_next={rx_address.src,rx_address.dst};
        end else begin
            address_next=tx_address;
        end
    end

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            tx_address<=96'h0;
        end else begin
            tx_address<= address_next;
        end
    end

endmodule