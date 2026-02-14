import defines::*;
module rx_controller (
    input logic clk,
    input logic rst_n,
    input logic rx_axis_tvalid,
    input logic rx_axis_tlast,
    input logic [3:0] count,
    input logic brx_full,
    output logic header_en,
    output logic count_en,
    output logic brx_valid,
    output logic rx_axis_tready
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
            if (rx_axis_tvalid) begin
                next_state = HEADER_BYTES;
            end else begin
                next_state = IDLE;
            end
        end

        HEADER_BYTES: begin
            if ((count == 4'd13) & rx_axis_tvalid) begin
                next_state = DATA_BYTES;
            end else begin
                next_state = HEADER_BYTES;
            end
        end
        DATA_BYTES: begin
            if (rx_axis_tlast) begin
                next_state = IDLE;
            end else begin
                next_state = DATA_BYTES;
            end
        end

        default: next_state = IDLE;
    endcase
end
always_comb begin
    header_en      = 1'b0;
    count_en       = 1'b0;
    brx_valid       = 1'b0;
    rx_axis_tready = 1'b0;
    case (current_state) 
    IDLE: begin
            header_en      = 1'b0;
            count_en       = 1'b0;
            brx_valid       = 1'b0;
            rx_axis_tready = 1'b0;
        end       
        HEADER_BYTES: begin
            header_en      = rx_axis_tvalid;
            count_en       = rx_axis_tvalid;
            rx_axis_tready = 1'b1;
        end
        DATA_BYTES: begin
            rx_axis_tready = !brx_full; // Backpressure when buffer is full
            brx_valid       = rx_axis_tvalid;
        end
        default: begin
            header_en      = 1'b0;
            count_en       = 1'b0;
            brx_valid       = 1'b0;
            rx_axis_tready = 1'b0;
        end
    endcase
end
endmodule