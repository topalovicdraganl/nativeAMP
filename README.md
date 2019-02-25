# nativeAMP
One solution of Unsupervised AMP, concept where multiple operating systems or bare-metal applications run on individual CPU cores.


All examples are build using Vivado 2018.3.
All examples are tested on UltraZed board (http://zedboard.org/product/ultrazed-EG).
All examples are using same Vivado project.

Provided examples are based on fallowing tutorials:
    - ug1209 (https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug1209-embedded-design-tutorial.pdf)
    - ug1169-zynqmp-qemu (https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_2/ug1169-zynqmp-qemu.pdf)
    - https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841820/Zynq+UltraScale+Plus+Restart+solution
    - http://zedboard.org/content/ultrazed-eg-starter-kit-tutorial-%E2%80%93-vivado-20164

Examples:
    1. hello_world_from APU, represent model where APU0 control APU1 execution using CRF_APB.RST_FPD_APU register.
    2. hello_world_from RTPU, represent model where APU0 control R0 execution using CRF_APB.RST_LPD_TOP register.

Short Guide for all exampes from \nativeAMP\zynqUSP\bm_app\:
    1. navigate to the folder .\nativeAMP\zynqUSP\build_hw\ and run creat_project.cmd script. 
    2. Open Viado and load project from .\nativeAMP\zynqUSP\build_hw
    3. Generate Bitstream.
    4. Export hardware design:
        a. File/Export/Export Hardware to the .\nativeAMP\zynqUSP\build_hw/SDK/SDK_Export
    4. Load Xilinx SDK workspace .\nativeAMP\zynqUSP\bm_app\hello_world_from_APU\SDK_Workspace.
    5. Import existing projects:
        a. Go to File/Import/General/Existing Projects into workspace/ 
        b. Select root directory => .\nativeAMP\zynqUSP\bm_app\hello_world_from_APU\SDK_Workspace
    6. navigate to the nativeAMP\zynqUSP\bm_app\hello_world_from_APU\BOOT
    7. Run genboot.cmd 
    8. copy generated *.bin file on SD
    9. Power on Board and observe terminal

