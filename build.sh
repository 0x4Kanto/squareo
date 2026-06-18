#!/bin/bash

nasm -f elf32 square.asm -o square.o && gcc -m32 -no-pie square.o -o square -lX11 -nostartfiles && rm square.o
