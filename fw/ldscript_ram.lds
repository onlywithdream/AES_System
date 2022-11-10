OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)

ENTRY(boot)

MEMORY{
    RAM   (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS{
    .text.boot :
    {
        KEEP(*(.text.boot))
        . = ALIGN(4);
    } >RAM
    
    .text.irq_handler :
    {
        KEEP(*(.text.irq_handler))
        . = ALIGN(4);
    } >RAM

    .text :
    {
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        *(.srodata)
        *(.srodata*)
        . = ALIGN(4);
    } >RAM

    .data :
    {
        *(.data)
        *(.data)
        *(.sdata)
        *(.sdata*)
        . = ALIGN(4);
    } >RAM

    .bss :
    {
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
    } >RAM
}