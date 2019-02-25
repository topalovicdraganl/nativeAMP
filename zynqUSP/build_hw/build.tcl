#*****************************************************************************************
# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (system.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
#    "./system/system.srcs/sources_1/bd/system/system.bd"
#    "./system/system.srcs/sources_1/bd/system/hdl/system_wrapper.v"
#
# 3. The following remote source files that were added to the original project:-
#
#    "./system/system.srcs/constrs_1/imports/system/system.xdc"
#
#*****************************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Create project
create_project system $origin_dir -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects system]
set_property "part" "xczu3eg-sfva625-1-i" $obj 
set_property "compxlib.compiled_library_dir" "D:/Vivado_Libraries" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj
set_property "target_simulator" "ModelSim" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/../../peripheral_repository/MyProcessorIPLib/vivado_pcores/common"] [file normalize "$origin_dir/../../peripheral_repository/MyProcessorIPLib/vivado_pcores/HIL404"]" $obj

# Create block design
source $origin_dir/system.tcl

# Generate the wrapper
set design_name [get_bd_designs]
make_wrapper -files [get_files $design_name.bd] -top -import
set_property synth_checkpoint_mode None  [get_files $design_name.bd]



# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "system_wrapper" $obj

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 "[file normalize "$origin_dir/src/system_wrapper_tb.v"]"\
]
add_files -norecurse -fileset $obj $files

set file "$origin_dir/src/system_wrapper_tb.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "used_in_implementation" "0" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/system.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/src/system.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" "[file normalize "$origin_dir/src/system.xdc"]" $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "modelsim.log_all_signals" "0" $obj
set_property "modelsim.unifast" "0" $obj
set_property "modelsim.use_explicit_decl" "1" $obj
set_property "modelsim.vhdl_syntax" "93" $obj
set_property "top" "system_wrapper_tb" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xczu3eg-sfva625-1-i -flow {Vivado Synthesis 2018} -strategy "Vivado Synthesis Defaults" -mode global -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2018" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" "xczu3eg-sfva625-1-i" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xczu3eg-sfva625-1-i -flow {Vivado Implementation 2018} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2018" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" "xczu3eg-sfva625-1-i" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:system"

