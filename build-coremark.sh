#!/bin/bash

set -e

BASEDIR=$PWD
CM_FOLDER=coremark
ITERATIONS=$1
RISCVTOOLS=/opt/riscv
cd $BASEDIR/$CM_FOLDER

# run the compile
echo "Start compilation"
#make PORT_DIR=../riscv64 compile
#mv coremark.riscv ../

make PORT_DIR=../riscv64-baremetal ITERATIONS=$ITERATIONS RISCVTOOLS=${RISCVTOOLS} compile
cp coremark.bare.riscv ../${ITERATIONS}coremark.bare.riscv -v
mv coremark.bare.riscv ../coremark.bare.riscv

cd ..

${RISCVTOOLS}/bin/riscv64-unknown-elf-objdump -D coremark.bare.riscv > ${ITERATIONS}coremark.bare.riscv.objdump
spike -g -l --log-commits --log=${ITERATIONS}coremark.bare.riscv.golden.log coremark.bare.riscv 2> ${ITERATIONS}pc.log
cat ${ITERATIONS}coremark.bare.riscv.golden.log | grep "mem 0x0000000080008000" | awk  '{printf $8}' | xxd -r -p  
#spike coremark.bare.riscv

cat ${ITERATIONS}coremark.bare.riscv.golden.log | grep "mem 0x0000000080008000" | awk  '{printf $8}' | xxd -r -p  > ${ITERATIONS}out.log
