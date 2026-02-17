import defines::*;
module tx_address_reg (
    input logic clk,rst_n,address_wr,
    input address header_addr,
    output address tx_address
);
    address address_next;
    always_comb begin 
        if (address_wr) begin
            address_next={header_addr.src,header_addr.dst};
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