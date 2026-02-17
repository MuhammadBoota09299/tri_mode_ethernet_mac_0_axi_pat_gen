import defines::*;
module controller #(parameter SIZE = 2048)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_axis_tready,
    input  logic        rx_header_valid,
    input  logic        remain_zero,
    input  logic        btx_empty,
    input  logic        tx_axis_tlast,
    input  logic        data,
    output logic        btx_rd_en,
    output logic        address_wr,
    output logic        payload_cal,
    output logic        payload_en,
    output logic        shift_wr,
    output logic        shift_en,
    output logic        count_en,
    output logic        data_select,
    output logic        tx_tvalid_sel
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
            if (tx_axis_tready & !btx_empty) begin
                next_state = HEADER_BYTES;
            end else begin
                next_state = IDLE;
            end
        end

        HEADER_BYTES: begin
            if (tx_axis_tready & data) begin
                next_state = DATA_BYTES;
            end else begin
                next_state = HEADER_BYTES;
            end
        end

        DATA_BYTES: begin
            if (tx_axis_tlast & tx_axis_tready & !btx_empty) begin
                if(!remain_zero) begin
                    next_state = HEADER_BYTES;
                end else begin
                    next_state = IDLE;
                end
            end else begin
                next_state = DATA_BYTES;
            end
        end

        default: next_state = IDLE;
    endcase
end

always_comb begin
    address_wr = 0;
    payload_cal = 0;
    payload_en = 0;
    count_en = 0;
    data_select = 0;
    tx_tvalid_sel = 1'b0;
    shift_wr = 0;
    shift_en = 0;
    btx_rd_en = 0;  

    case (current_state)
        IDLE: begin
            if (tx_axis_tready & !btx_empty) begin
                shift_wr=1'b1;
            end else begin
                payload_en=1'b1;
                address_wr=rx_header_valid;
            end
        end

        HEADER_BYTES: begin
                count_en=1'b1;
                shift_en=1'b1;
                tx_tvalid_sel=1'b1;
                if (tx_axis_tready & data) begin
                    btx_rd_en=1'b1;
                end else begin
                    btx_rd_en=1'b0;
                end
        end

        DATA_BYTES: begin
            if (tx_axis_tlast & tx_axis_tready & !btx_empty) begin
                if(!remain_zero) begin
                    count_en=1'b1;
                    data_select=1'b1;
                    shift_wr=1'b1;
                    payload_cal=1'b1;
                end else begin
                    count_en=1'b1;
                    data_select=1'b1;
                    payload_en=1'b1;
                    address_wr=1'b1;
                end
            end else begin
                count_en= !btx_empty && tx_axis_tready;
                data_select=1'b1;
                btx_rd_en=tx_axis_tready;
                payload_cal=1'b0;
            end
        end

        default:begin
            count_en=1'b0;
            data_select=1'b0;
            btx_rd_en=1'b0;
            shift_wr=1'b0;
            tx_tvalid_sel=1'b0;
            shift_en=1'b0;
            payload_cal=1'b0;
            payload_en=0;
            address_wr=0;
        end 
    endcase
end
endmodule
