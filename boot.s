; boot.s

BITS 32

section .multiboot_header align=8
multiboot_header_start:
    dd 0xE85250D6
    dd 0
    dd multiboot_header_end - multiboot_header_start
    dd -(0xE85250D6 + 0 + (multiboot_header_end - multiboot_header_start))

    dd 6
    dd 20
    dd 0x100000
    dd 0x100000
    dd 0
    dd 0

    dd 7
    dd 16
    dq _start

    dd 0
    dd 8
multiboot_header_end:

section .text
global _start
extern kernel_entry

_start:
    cli
    mov esp, stack_top

    lgdt [gdt_descriptor]

    ; Setup page tables
    lea  ebx, [pdpt]
    lea  ecx, [pd]

    lea  eax, [pml4]
    mov  edx, ebx
    or   edx, 0x03
    mov  dword [eax], edx

    mov  edx, ecx
    or   edx, 0x03
    mov  dword [ebx], edx

    mov  eax, 0x0
    or   eax, 0x83
    mov  dword [ecx], eax

    ; Enable PAE
    mov  eax, cr4
    or   eax, 0x20
    mov  cr4, eax

    ; Load page table base
    lea  eax, [pml4]
    mov  cr3, eax

    ; Enable Long Mode in EFER
    mov  ecx, 0xC0000080
    rdmsr
    or   eax, 0x100
    wrmsr

    ; Enable paging and protection
    mov  eax, cr0
    or   eax, 0x80000001
    mov  cr0, eax

    push dword 0x08
    push dword long_mode_entry
    retf

; now in 64-bit mode
[BITS 64]
long_mode_entry:
    ; reload data segments
    mov ax, 0x10           ; data selector for GDT[2]
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; set up 64-bit stack
    mov  rsp, stack_top
    and  rsp, -16           ; align

    call kernel_entry

.hang:
    hlt
    jmp .hang

; ----------------------------------------
; page tables (identity map first 2 MiB)
; ----------------------------------------
section .data
align 4096
pml4:
    dq 0                      ; cleared; we'll fill entry 0
align 4096
pdpt:
    dq 0                      ; cleared; we'll fill entry 0
align 4096
pd:
    dq 0                      ; cleared; we'll fill entry 0

; ----------------------------------------
; GDT setup
; ----------------------------------------
gdt_start:
    dq 0x0000000000000000        ; null
    dq 0x00A09B0000000000        ; code: base=0, L=1, DPL=0, P=1
    dq 0x00A0930000000000        ; data: base=0, L=0, DPL=0, P=1
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start

; ----------------------------------------
; stack
; ----------------------------------------
section .bss
align 16
stack_space:
    resb 16384
stack_top equ stack_space + 16384
