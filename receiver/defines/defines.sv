package defines;
typedef struct packed {
        logic [5:0] [7:0] dst ;
        logic [5:0] [7:0] src ;
} address;
typedef struct packed {
        address addr;
        logic [1:0] [7:0] payload_len;
} header;
typedef enum logic [1:0] {
    IDLE          = 2'b00,
    HEADER_BYTES  = 2'b01,
    DATA_BYTES    = 2'b11
} fsm;
endpackage

