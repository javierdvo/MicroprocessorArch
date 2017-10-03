#!/bin/bash

# File: loadMIPSfpga.sh
# Description: Compiles program, creates memory files for simulation/synthesis, a$
#      loads program onto MIPSfpga using Open OCD and Codescape Essentials (gdb)
#
# Based in loadMIPSfpga.bat by "Imagination Technologies"
#
# DATE:   15-SEP-2015

if [ -z "$1" ]; then
	echo -e "ERROR: Your must enter the program directory."
	echo -e "\tExample:"
	echo -e "\tloadMIPSfpga.sh ../../Module02_C/ReadSwitches"
	exit 
else
	ELF_FILE=$1/FPGA_Ram.elf
fi

MIPS_TOOLS_BIN=/usr/local/share/imgtec/Toolchains/mips-mti-elf/2015.06-05/bin
gdbStartupFile=`pwd`"/startup.txt"
echo "gdbStartupFile: $gdbStartupFile"

# Invoque openocd
openocd -f interface/mips_busblaster.cfg -f target/xilinx_nexys4_mips.cfg &

#Invoque gdb and connect to openocd with "gdbstartupfile" configuration
${MIPS_TOOLS_BIN}/mips-mti-elf-gdb -q ${ELF_FILE} -x ${gdbStartupFile}

# kill openocd process
kill $!
