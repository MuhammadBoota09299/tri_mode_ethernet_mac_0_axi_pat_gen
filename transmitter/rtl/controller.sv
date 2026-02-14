import defines::*;
module controller #(parameter SIZE = 2048)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_axis_tready,
    input  logic        rx_header_valid,
    input  header       remain_zero,
    input logic         btx_empty,
    input logic         tx_axis_tlast,
    input logic         data,
    output logic        btx_rd_en,
    output logic        address_wr,
    output logic        payload_cal,
    output logic        playload_en,
    output logic        count_en,
    output logic        data_select,
    output logic        tx_axis_tvalid
);
fsm current_state, next_state;
always_ff @(posedge clk) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    case (current_state)
        IDLE: begin
            if (rx_header_valid) begin
                next_state = HEADER_BYTES;
            end else begin
                next_state = IDLE;
            end
        end

        HEADER_BYTES: begin
            if (remain_zero) begin
                next_state = DATA_BYTES;
            end else begin
                next_state = HEADER_BYTES;
            end
        end

        DATA_BYTES: begin
            if (tx_axis_tlast & !btx_empty) begin
                next_state = IDLE;
            end else begin
                next_state = DATA_BYTES;
            end
        end

        default: next_state = IDLE;
    endcase
end
