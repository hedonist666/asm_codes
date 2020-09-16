#!/bin/bash

fn=$(echo $1 | sed -e 's/\.asm//')

fasm $1 && ./"$fn" qewr QWER 
