@echo Deleting work directory...
del /s /f /q .Xil >> cleanup.log
rd /s /q .Xil >> cleanup.log
del /s /f /q hil_system.cache >> cleanup.log
rd /s /q hil_system.cache >> cleanup.log
del /s /f /q hil_system.runs >> cleanup.log
rd /s /q hil_system.runs >> cleanup.log
del /s /f /q hil_system.srcs >> cleanup.log
rd /s /q hil_system.srcs >> cleanup.log
del /s /f /q hil_system.hw >> cleanup.log
rd /s /q hil_system.hw >> cleanup.log
del /s /f /q hil_system.sdk >> cleanup.log
rd /s /q hil_system.sdk >> cleanup.log
del /s /f /q hil_system.sim >> cleanup.log
rd /s /q hil_system.sim >> cleanup.log
del /s /q hil_system.xpr >> cleanup.log
del /s /q vivado*.jou >> cleanup.log
del /s /q vivado*.log >> cleanup.log

REM Xilinx Vivado instalation folder
SET XIL_FOLDER=C:\Xilinx\Vivado\2018.3

%XIL_FOLDER%\bin\vivado.bat -mode batch -source build.tcl