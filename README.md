# Tri-Mode Ethernet MAC with AXI Pattern Generator

A SystemVerilog-based Ethernet Media Access Control (MAC) implementation with integrated AXI pattern generation for testing and validation.

## Overview

This project implements a tri-mode Ethernet MAC with support for 10/100/1000 Mbps operation. The design includes a pattern generator for creating Ethernet frames with configurable headers and payloads, making it suitable for simulation and validation purposes.

## Features

- **Tri-Mode Ethernet Support**: Compatible with 10 Mbps, 100 Mbps, and 1000 Mbps Ethernet standards
- **Configurable Frame Parameters**:
  - Destination and source MAC addresses
  - Frame size (minimum 64 bytes, maximum 500 bytes configurable)
  - Optional VLAN support with priority tagging
- **Receiver Module**: Captures incoming Ethernet frames and buffers data
- **Transmitter Module**: Generates and transmits Ethernet frames with proper formatting
- **AXI Pattern Generator**: Integrates with AXI protocol for pattern-based frame generation
- **Full Testbench**: Comprehensive simulation testbenches for validation

## Project Structure

```
├── README.md                          # Project documentation
├── defines/                           # Shared SystemVerilog definitions
│   └── defines.sv                     # Data types, FSM definitions, and packages
├── rtl/                               # Hardware design files
│   ├── tri_mode_ethernet_mac_0_axi_pat_gen.sv  # Top-level module
│   ├── dut.sv                         # Device Under Test (datapath)
│   ├── receiver/                      # Receiver subsystem
│   │   └── rtl/
│   │       ├── receiver.sv            # Receiver top-level
│   │       ├── rx_controller.sv       # Reception FSM controller
│   │       ├── rx_buffer.sv           # Receive data buffer
│   │       ├── rx_counter.sv          # Byte counter
│   │       └── header_reg.sv          # Header register
│   └── transmitter/                   # Transmitter subsystem
│       └── rtl/
│           ├── transmitter.sv         # Transmitter top-level
│           ├── controller.sv          # Transmission FSM controller
│           ├── tx_buffer.sv           # Transmit data buffer
│           ├── tx_counter.sv          # Payload byte counter
│           ├── address_reg.sv         # Address register
│           ├── shift_reg.sv           # Shift register for bit-level operations
│           └── payload_len_cal.sv     # Payload length calculator
├── testbench/                         # Top-level testbench
│   └── tri_mode_ethernet_mac_0_axi_pat_gen_tb.sv
└── docx/                              # Documentation
    └── packet_gen.drawio              # Architecture diagram
```

## Key Modules

### tri_mode_ethernet_mac_0_axi_pat_gen
**Top-level module integrating receiver, transmitter, and pattern generator.**

**Parameters:**
- `DEST_ADDR`: Destination MAC address (default: 48'hda0102030405)
- `SRC_ADDR`: Source MAC address (default: 48'h5a0102030405)
- `MAX_SIZE`: Maximum frame payload size (default: 500 bytes)
- `MIN_SIZE`: Minimum frame payload size (default: 64 bytes)
- `ENABLE_VLAN`: Enable VLAN tagging (default: disabled)
- `VLAN_ID`: VLAN ID (default: 12'd2)
- `VLAN_PRIORITY`: VLAN priority (default: 3'd2)

**Ports:**
- Input: Clock (`clk`), Reset (`rst_n`), Receive data (`r_data`, `r_valid`, `r_last`)
- Output: Transmit data (`tdata`, `tvalid`, `tlast`)

### Receiver Module
Handles incoming Ethernet frames, extracts header information, and buffers payload data.

**Components:**
- `rx_controller`: State machine controlling reception phases (IDLE, HEADER_BYTES, DATA_BYTES)
- `rx_buffer`: FIFO-like buffer for received data
- `rx_counter`: Tracks byte count during reception
- `header_reg`: Stores destination address, source address, and payload length

### Transmitter Module
Constructs and transmits Ethernet frames from received data.

**Components:**
- `controller`: Manages transmission sequence and header formatting
- `tx_buffer`: Buffers data ready for transmission
- `tx_counter`: Counts payload bytes
- `shift_reg`: Performs bit-level operations for frame construction
- `address_reg`: Stores source and destination addresses
- `payload_len_cal`: Calculates and maintains payload length

### DUT (Device Under Test)
Simple datapath that forwards received data to transmitter when both buffers have space.

## Simulation

### Prerequisites
- SystemVerilog simulator (ModelSim, QuestaSim, etc.)
- SystemVerilog compiler with package support

### Running Simulations

**Top-level testbench:**
```bash
cd testbench
vsim -do "do xv.bat" tri_mode_ethernet_mac_0_axi_pat_gen_tb
```

**Receiver testbench:**
```bash
cd rtl/receiver/testbench
vsim -do "do xv.bat" receiver_tb
```

**Transmitter testbench:**
```bash
cd rtl/transmitter/test_bench
vsim -do "do xv.bat" transmitter_tb
```

## Data Types

The `defines` package provides key data structures:

```systemverilog
typedef struct packed {
    logic [5:0] [7:0] dst;  // Destination MAC address (48-bit)
    logic [5:0] [7:0] src;  // Source MAC address (48-bit)
} address;

typedef struct packed {
    address addr;
    logic [1:0] [7:0] payload_len;  // Payload length (16-bit)
} header;

typedef enum logic [1:0] {
    IDLE        = 2'b00,
    HEADER_BYTES = 2'b01,
    DATA_BYTES  = 2'b11
} fsm;
```

## Design Flow

1. **Frame Reception**: Incoming data is received via AXI interface and buffered
2. **Header Extraction**: MAC addresses and payload length are extracted and stored
3. **Buffering**: Complete frame is buffered in receive FIFO
4. **Frame Transmission**: Data is retrieved from buffer and formatted for transmission
5. **Header Insertion**: Extracted header is prepended to payload
6. **Transmission**: Complete frame is transmitted via transmit interface

## Author

Muhammad Boota

## Notes

- The design uses SystemVerilog packages and structs for cleaner, more maintainable code
- Testbenches are included for unit testing individual modules
- The tri-mode capability allows the design to adapt to different Ethernet speeds
- VLAN support is optional and can be enabled via parameter configuration