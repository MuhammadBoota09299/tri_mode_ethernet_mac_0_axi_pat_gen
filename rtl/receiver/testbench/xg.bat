@echo off
call xv.bat
if %ERRORLEVEL% GEQ 1 EXIT /B 1
vsim -gui -voptargs=+acc work.receiver_tb -do "add wave -r sim:/receiver_tb/*;run -all; quit" 
call clean.bat
