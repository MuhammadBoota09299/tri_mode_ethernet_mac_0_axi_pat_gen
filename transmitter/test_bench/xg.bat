@echo off
call xv.bat
if %ERRORLEVEL% GEQ 1 EXIT /B 1
vsim -gui -voptargs=+acc work.transmitter_tb -do "add wave -r sim:/transmitter_tb/*;run -all; quit" 
call clean.bat
