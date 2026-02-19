@echo off
call xv
vsim -c work.tri_mode_ethernet_mac_0_axi_pat_gen_tb -do "run -all; quit" 
pause
