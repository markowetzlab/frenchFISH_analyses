#! /bin/sh
#
# run_focus_selector.sh
# Copyright (C) 2015 macint01 <macint01@3CR465J>
#
# Distributed under terms of the MIT license.
#


imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/PS11.10021_2B_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/PS11_167511L_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL024199_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/PS09_287383C_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/PS09.20676_2B_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL_024216_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL32080_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL24212_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL32077_Myc_Terc/
imagej -b select_focus_project_x.ijm ~/frenchFISH_analyses/image_processing/input_data/BL010243_Myc_Terc/

#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/PS11_167511L_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL024199_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL010243_Myc_Terc/
#for i in `seq 1 5`
#do
#	imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/BL_024216_Myc_Terc_rescan/BL_024216_Myc_Terc_2016_02_11_$i/
#done

#for i in `seq 1 5`
#do
#	imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/PS08_21605_Myc_Terc_2016_02_11/PS08_21605_Myc_Terc_2016_02_11_$i/
#done
#for i in `seq 1 5`
#do
#	imagej -b select_focus_project_x.ijm  /HDD/brenton_lab/FISH/input_data/PS11_15328_Myc_Terc_2016_02_11/PS11_15328_Myc_Terc_2016_02_11_$i/
#done
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL24212_Myc_Terc/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/PS0952671C_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL32077_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/PS09.20676_2B_Myc_Terc/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/PS10_27791H_Myc_Terc/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/BL007028_Myc_Terc_2ndRun/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/BL_024216_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL_024216_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/BL32080_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/PS09_287383C_Myc_Terc/
#imagej -b select_focused_slices.ijm /HDD/brenton_lab/FISH/input_data/PS11.10021_2B_Myc_Terc/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/Ania_5981/
#imagej -b select_focus_project_x.ijm /HDD/brenton_lab/FISH/input_data/PS11_153283G_Myc_Terc/

#imagej -b combine_files.ijm /HDD/brenton_lab/FISH/input_data/Ania_5981/
#imagej -b combine_files.ijm PS11_153283G_Myc_Terc
#imagej -b combine_files.ijm PS11_167511L_Myc_Terc
#imagej -b combine_files.ijm BL024199_Myc_Terc
#imagej -b combine_files.ijm BL010243_Myc_Terc
#imagej -b combine_files.ijm BL_024216_Myc_Terc
#imagej -b combine_files.ijm BL24212_Myc_Terc
#imagej -b combine_files.ijm PS0952671C_Myc_Terc
#imagej -b combine_files.ijm BL32077_Myc_Terc
#imagej -b combine_files.ijm PS09.20676_2B_Myc_Terc
#imagej -b combine_files.ijm PS10_27791H_Myc_Terc_2
#imagej -b combine_files.ijm BL007028_Myc_Terc_2ndRun
#imagej -b combine_files.ijm BL_024216_Myc_Terc
#imagej -b combine_files.ijm BL32080_Myc_Terc
#imagej -b combine_files.ijm PS09_287383C_Myc_Terc
#imagej -b combine_files.ijm PS11.10021_2B_Myc_Terc
