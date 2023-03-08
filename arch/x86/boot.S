#include "multiboot.h"

.section .multiboot
    .long MB_MAGIC
    .long MB_ALIGNED_4K_MEM_MAP
    .long CHECKSUM(MB_ALIGNED_4K_MEM_MAP)

.section .bss
    /* According to System V ABI, the stack must be 16-byte aligned. */
    .align 16
    stack_bottom:
        .skip 16318, 0
    stack_top:


.section .text
    .global _start
    _start:
        /* Set up the stack. */
        movl $stack_top, %esp
        /*
            TODO: kernel init
                1. Load GDT
                2. Load IDT
                3. Enable paging
        */
        call _kernel_init

        pushl %ebx
        call _kernel_main

        cli
    j_:
        hlt
        jmp j_