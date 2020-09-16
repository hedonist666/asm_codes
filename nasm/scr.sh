#!/bin/bash

fn=$(echo $1 | sed -e 's/\.asm//')
#nasm -f elf64 $1 && ld -s -o $fn "$fn.o" && ./"$fn"
nasm -f bin $1 -o $fn && chmod +x $fn && dosbox -c "boot $fn"
