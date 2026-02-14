@echo off
call xv
vsim -c work.receiver_tb -do "run -all; quit" 
pause
