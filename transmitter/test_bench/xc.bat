@echo off
call xv
vsim -c work.transmitter_tb -do "run -all; quit" 
pause
