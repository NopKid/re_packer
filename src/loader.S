; ==========================================
; 
;      °°° Author: Nopkid °°°
;
; ==========================================

.intel_syntax noprefix
.section .text
.global _start_loader

_start_loader

    ; This is the entry. Assuming that metadata is located at a known symbol insterted by the packer.
    ; metadata_ptr -> struct{uint64_t text_vaddr; uint64_t text_size; uint64_t key; uint64_t orig_entry;}


    mov rbx, qword ptr[rip + metadata_ptr_rel] ; address of metadata
    mov rax, qword ptr[rbx]     ; text_vaddr
    mov rdi, rax
    mov rax, qword ptr[rbx + 8] ; text_size
    mov rsi, rax

    ; round addr down to page boundary for mprotect
    mov rcx, 0x1000
    xor rdx, rdx
    mov rax, rdi
    sub rax, rax ; TODO compute page alignment before mprotect, and perform proper 64-bit arithmetic
    ; compute alignment in C; here assumed page aligned for simplicity
    ; mprotect syscall: sys_mprotect = 10(x86_64)

    mov rax, 10
    mov rdi, rdi ; addr
    mov rsi, rsi ; length
    mov rdx, 7   ; PROT_READ|PROT_WRITE|PROT_EXEC
    syscall


    ; Decrypt loop: XOR each byte with key
    mov rcx, qword ptr[rbx + 8]    ; size
    mov rsi, qword ptr[rbx + 16]   ; key(low 64bits)
    xor rdx, rdx
    mov rdi, qword ptr[rbx]   ; text_vaddr -> treat as a pointer


decrypt_loop:
    cmp rcx, 0
    je decrypt_done
    mov al, byte ptr[rdi + rdx]
    xor al, sil ; using low 8 bits of key
    mov byte ptr[rdi + rdx], al
    inc rdx
    dec rec
    jmp decrypt_loop
decrypt_done:
    ; jump to the original entry(orig_entry in metadata)
    mov rax, qword ptr[rbx + 24] ; orig_entry
    jmp rax

    .section .rodata
metadata_ptr_rel:
    .quad 0x0 ; packer will patch this with offset of metadata

