#!/bin/bash

set -e

BASEDIR=$PWD
CM_FOLDER=coremark

ITERATIONS=$1
RISCVTOOLS=/opt/riscv
RV_GNU=riscv64-unknown-elf-
cd $BASEDIR/$CM_FOLDER

# run the compile
echo "Start compilation"
#make PORT_DIR=../riscv64 ITERATIONS=$ITERATIONS RISCVTOOLS=${RISCVTOOLS} compile
#mv coremark.riscv ../

make PORT_DIR=../riscv64-baremetal ITERATIONS=$ITERATIONS RISCVTOOLS=${RISCVTOOLS} ARCH=rv64gc ABI=lp64d compile
cp coremark.bare.riscv ../${ITERATIONS}coremark64.bare.riscv -v

make PORT_DIR=../riscv32-baremetal ITERATIONS=$ITERATIONS RISCVTOOLS=${RISCVTOOLS} ARCH=rv32imaf_zicsr ABI=ilp32f compile
mv coremark.bare.riscv ../${ITERATIONS}coremark32.bare.riscv -v

cd ..

${RISCVTOOLS}/bin/${RV_GNU}objdump -D        ${ITERATIONS}coremark64.bare.riscv > ${ITERATIONS}coremark64.bare.riscv.objdump
${RISCVTOOLS}/bin/${RV_GNU}objcopy -O binary ${ITERATIONS}coremark64.bare.riscv   ${ITERATIONS}coremark64.bare.riscv.bin --strip-debug

${RISCVTOOLS}/bin/${RV_GNU}objdump -D        ${ITERATIONS}coremark32.bare.riscv > ${ITERATIONS}coremark32.bare.riscv.objdump
${RISCVTOOLS}/bin/${RV_GNU}objcopy -O binary ${ITERATIONS}coremark32.bare.riscv   ${ITERATIONS}coremark32.bare.riscv.bin --strip-debug

#printf "4 " | cat - ${ITERATIONS}coremark64.bare.riscv.bin | ./bin2hex.elf > ${ITERATIONS}coremark64.bare.riscv.hex
#printf "4 " | cat - ${ITERATIONS}coremark32.bare.riscv.bin | ./bin2hex.elf > ${ITERATIONS}coremark32.bare.riscv.hex

#cp ${ITERATIONS}coremark64.bare.riscv.hex ../yonca_soc/sw/outputs
#cp ${ITERATIONS}coremark64.bare.riscv.objdump ../yonca_soc/sw/outputs
#cp ${ITERATIONS}coremark64.bare.riscv.bin ../yonca_soc/sw/outputs
#cp ${ITERATIONS}coremark64.bare.riscv ../yonca_soc/sw/outputs
#cp ${ITERATIONS}coremark64.bare.riscv ../yonca_soc/rtl/core/yonca/submodules/verification/test_code/executable/

spike -g -l --log-commits --log=${ITERATIONS}coremark64.bare.riscv.golden.log ${ITERATIONS}coremark64.bare.riscv 2> ${ITERATIONS}coremark64pc.log
printf "\n\n"
spike -g -l --log-commits --log=${ITERATIONS}coremark32.bare.riscv.golden.log --isa=rv32imafd_zicsr_zicntr ${ITERATIONS}coremark32.bare.riscv 2> ${ITERATIONS}coremark32pc.log
#cat ${ITERATIONS}coremark64.bare.riscv.golden.log | grep "mem 0x0000000080008000" | awk  '{printf $8}' | xxd -r -p  
#spike coremark64.bare.riscv

#cat ${ITERATIONS}coremark64.bare.riscv.golden.log | grep "mem 0x0000000080008000" | awk  '{printf $8}' | xxd -r -p  > ${ITERATIONS}out.log
