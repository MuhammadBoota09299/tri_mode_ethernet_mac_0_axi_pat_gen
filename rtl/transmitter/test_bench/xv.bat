@echo off
del wlf*
rmdir /s /q work
vlog -work work   -sv -stats=none C:/Users/boota/OneDrive/Desktop/packect_gen/defines/*.sv
if %ERRORLEVEL% GEQ 1 pause /B 1
vlog -work work   -sv -stats=none *.sv
if %ERRORLEVEL% GEQ 1 pause /B 1
vlog -work work   -sv -stats=none C:/Users/boota/OneDrive/Desktop/packect_gen/rtl/transmitter/rtl/*.sv 
if %ERRORLEVEL% GEQ 1 pause /B 1 