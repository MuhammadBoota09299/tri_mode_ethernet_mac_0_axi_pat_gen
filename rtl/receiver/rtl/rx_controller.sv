import defines::*;
module rx_controller (
    input logic clk,
    input logic rst_n,
    input logic r_valid,
    input logic r_last,
    input logic [3:0] count,
    input logic brx_full,
    output logic rx_header_valid,
    output logic header_en,
    output logic count_en,
    output logic brx_valid,
    output logic r_ready
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
            if (r_valid) begin
                next_state = HEADER_BYTES;
            end else begin
                next_state = IDLE;
            end
        end

        HEADER_BYTES: begin
            if ((count == 4'd13) & r_valid) begin
                next_state = DATA_BYTES;
            end else begin
                next_state = HEADER_BYTES;
            end
        end
        DATA_BYTES: begin
            if (r_last) begin
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
    r_ready = 1'b0;
    rx_header_valid = 1'b0;
    case (current_state) 
    IDLE: begin
            header_en      = 1'b0;
            count_en       = 1'b0;
            brx_valid       = 1'b0;
            rx_header_valid = 1'b1;
            r_ready = 1'b0;
        end       
        HEADER_BYTES: begin
            header_en      = r_valid;
            count_en       = r_valid;
            r_ready = 1'b1;
        end
        DATA_BYTES: begin
            r_ready = !brx_full; // Backpressure when buffer is full
            brx_valid       = r_valid;
            rx_header_valid = 1'b1; // Keep header valid during data reception
        end
        default: begin
            rx_header_valid = 1'b0;
            header_en      = 1'b0;
            count_en       = 1'b0;
            brx_valid       = 1'b0;
            r_ready = 1'b0;
        end
    endcase
end
endmodule