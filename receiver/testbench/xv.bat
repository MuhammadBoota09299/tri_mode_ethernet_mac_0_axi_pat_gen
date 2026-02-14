@echo off
del wlf*
rmdir /s /q work
vlog -work work   -sv -stats=none C:/Users/boota/OneDrive/Desktop/pakect_gen/receiver/defines/*.sv
if %ERRORLEVEL% GEQ 1 pause /B 1
vlog -work work   -sv -stats=none *.sv
if %ERRORLEVEL% GEQ 1 pause /B 1
vlog -work work   -sv -stats=none C:/Users/boota/OneDrive/Desktop/pakect_gen/receiver/rtl/*.sv 
if %ERRORLEVEL% GEQ 1 pause /B 1 