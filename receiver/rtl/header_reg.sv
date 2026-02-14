import defines::*;
module header_reg(
    input wire clk,
    input wire rst_n,
    input logic [7:0] rx_axis_tdata,
    input logic header_en,
    output header rx_header
);
header header_next, header_reg;
always_ff @(posedge clk) begin
    if (!rst_n) begin
        header_reg <= 112'h0;
    end else 
        header_reg <= header_next;
    end
always_comb begin
    if (header_en) begin
        header_next = {header_reg[103:0], rx_axis_tdata};
    end
    else begin
        header_next = header_reg;
    end
end

assign rx_header = header_reg;
endmodule