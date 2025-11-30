.data
    menu_msg:       .asciiz "\n\n--- CALCULADORA MIPS ---\n1. Base 10 -> Bin, Oct, Hex, BCD\n2. Base 10 -> Compl. a 2 (16 bits)\n3. Analise Float/Double\n0. Sair\nEscolha: "
    msg_int:        .asciiz "\nDigite um inteiro (Base 10): "
    str_bin:        .asciiz "\nBinario (Base 2): 0b"
    str_oct:        .asciiz "\nOctal (Base 8):   0o"
    str_hex:        .asciiz "\nHexa (Base 16):   0x"
    str_bcd:        .asciiz "\nBCD (8421):       "
    newline:        .asciiz "\n"
    
.text
.globl main

main:
    # Exibir Menu
    li $v0, 4
    la $a0, menu_msg
    syscall
    
    # Ler Opção
    li $v0, 5
    syscall
    move $t0, $v0
    
    beq $t0, 0, exit
    beq $t0, 1, opt_bases
    
    j main 

exit:
    li $v0, 10
    syscall
opt_bases:
    li $v0, 4
    la $a0, msg_int
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0
    
    #BINARIO
    li $v0, 4
    la $a0, str_bin
    syscall
    
    move $a0, $s0
    jal print_bin_32
    
    #OCTAL 
    li $v0, 4
    la $a0, str_oct
    syscall
    
    move $a0, $s0
    jal print_oct
    
    # HEXADECIMAL
    li $v0, 4
    la $a0, str_hex
    syscall
    
    move $a0, $s0
    li $v0, 34
    syscall
    
    # BCD
    li $v0, 4
    la $a0, str_bcd
    syscall
    
    move $a0, $s0
    jal print_bcd
    
    j main


print_bin_32:
    move $t0, $a0
    li $t1, 31 
loop_b32:
    srlv $t2, $t0, $t1
    andi $t2, $t2, 1
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    subi $t1, $t1, 1
    bge $t1, 0, loop_b32
    jr $ra

print_oct:
    # Imprime Octal por divisão 
    move $t0, $a0
    li $t1, 8
    
    bne $t0, 0, calc_oct
    li $v0, 1
    syscall
    jr $ra
calc_oct:
    li $t2, 0
loop_stack_oct:
    beq $t0, 0, print_stack_oct
    divu $t0, $t1
    mflo $t0
    mfhi $t3 
    
    subu $sp, $sp, 4
    sw $t3, ($sp)
    addi $t2, $t2, 1
    j loop_stack_oct
print_stack_oct:
    lw $a0, ($sp)
    addu $sp, $sp, 4
    li $v0, 1
    syscall
    subi $t2, $t2, 1
    bgt $t2, 0, print_stack_oct
    jr $ra

print_bcd:
    # BCD
    move $t0, $a0
    li $t1, 10
    li $t2, 0 
    bne $t0, 0, loop_stack_bcd
    li $a0, 0
    li $v0, 1
    syscall
    jr $ra
    
loop_stack_bcd:
    beq $t0, 0, print_res_bcd
    divu $t0, $t1
    mflo $t0
    mfhi $t3 # Digito decimal
    
    subu $sp, $sp, 4
    sw $t3, ($sp)
    addi $t2, $t2, 1
    j loop_stack_bcd

print_res_bcd:
    lw $t3, ($sp)
    addu $sp, $sp, 4
    
    # Imprimir espaco
    li $v0, 11
    li $a0, 32
    syscall
    
    li $t4, 3
inner_bcd:
    srlv $t5, $t3, $t4
    andi $t5, $t5, 1
    li $v0, 1
    move $a0, $t5
    syscall
    subi $t4, $t4, 1
    bge $t4, 0, inner_bcd
    
    subi $t2, $t2, 1
    bgt $t2, 0, print_res_bcd
    jr $ra
