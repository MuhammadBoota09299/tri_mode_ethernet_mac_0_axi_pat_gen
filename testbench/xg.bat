@echo off
call xv.bat
if %ERRORLEVEL% GEQ 1 EXIT /B 1
vsim -gui -voptargs=+acc work.tri_mode_ethernet_mac_0_axi_pat_gen_tb -do "add wave -r sim:/tri_mode_ethernet_mac_0_axi_pat_gen_tb/*;run -all; quit" 
call clean.bat
