
# nativeAMP
One solution of Unsupervised AMP, concept where multiple operating systems or bare-metal applications run on individual CPU cores.

## Examples:
1. `hello_world_from_APU`, represent example where APU0 control APU1 execution using CRF_APB.RST_FPD_APU register.
2. `hello_world_from_RTPU`, represent example where APU0 control R0 execution using CRF_APB.RST_LPD_TOP register.
3. `hello_world_from_APU_and_RTPU`, represent example where APU0 control APU1 and R0 execution.

## Provided examples are based on fallowing tutorials:
1. [ug1209 Embedded Design Tutorial](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug1209-embedded-design-tutorial.pdf)
2. [ug1169 ZynqMP QEMU](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_2/ug1169-zynqmp-qemu.pdf)
3. [Zynq US+ Restart Solution](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841820/Zynq+UltraScale+Plus+Restart+solution)
4. [UltraZed tutorial](http://zedboard.org/content/ultrazed-eg-starter-kit-tutorial-%E2%80%93-vivado-20164)

## Short Guide for all exampes from .\nativeAMP\zynqUSP\bm_app:
1. Navigate to the folder `.\nativeAMP\zynqUSP\build_hw` and run `creat_project.cmd` script. 
2. Open Vivado and load project from `.\nativeAMP\zynqUSP\build_hw`.
3. Generate Bitstream.
4. Export hardware design: Click `File\Export\Export Hardware` and navigate to the `.\nativeAMP\zynqUSP\build_hw\SDK\SDK_Export`.
5. Load Xilinx SDK workspace `.\nativeAMP\zynqUSP\bm_app\app_example\SDK_Workspace`.
6. Click `File\New\Other` take `Xilix\Hardware Platfrom Specification`. Get `system_wrapper.hdf` file from `.\nativeAMP\zynqUSP\build_hw\SDK\SDK_Export`. 
Name should be set to `system_wrapper_hw_platform_0`.
7. Import existing projects: Go to `File\Import\General\Existing Projects into Workspace`. 
Select root directory `.\nativeAMP\zynqUSP\bm_app\app_example\SDK_Workspace`. 
And wait until all sources are rebuilded.
8. Navigate to the `.\nativeAMP\zynqUSP\bm_app\app_example\BOOT`.
9. Open command linad and run `genboot.cmd`.
10. Copy generated *.bin file on SD.
11. Power on Board and observe terminal.

## Important notes
1. All examples are build using Vivado 2018.3.
2. All examples are tested on [UltraZed](http://zedboard.org/product/ultrazed-EG).
3. All examples are using same Vivado project.
4. `app_example` refers to the any application from the section ##Examples.

