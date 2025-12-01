# Aluno: Augusto Malheiros de Souza
# Turma: A
# Email: ams10@cesar.school
# 1 questão 30/11 19:25
# 2 questão 30/11 20:39
# 3 questão 30/11 21:03
.data
    menu_msg:       .asciiz "\n\n--- CALCULADORA MIPS ---\n1. Base 10 -> Bin, Oct, Hex, BCD\n2. Base 10 -> Compl. a 2 (16 bits)\n3. Analise Float/Double\n0. Sair\nEscolha: "
    msg_int:        .asciiz "\nDigite um inteiro (Base 10): "
    newline:        .asciiz "\n"

    str_bin:        .asciiz "\nBinario (Base 2): 0b"
    str_oct:        .asciiz "\nOctal (Base 8):   0o"
    str_hex:        .asciiz "\nHexa (Base 16):   0x"
    str_bcd:        .asciiz "\nBCD (8421):       "

    str_neg_det:    .asciiz "\n[1] Numero negativo. Convertendo para positivo para analise..."
    str_inv:        .asciiz "\n[2] Invertendo bits (NOT)..."
    str_somar1:     .asciiz "\n[3] Somando 1..."
    str_res_16:     .asciiz "\nResultado Hex (16-bit): "

    msg_float:      .asciiz "\nDigite Float: "
    msg_double:     .asciiz "\nDigite Double: "
    str_sinal:      .asciiz "\nSinal (+/-): "
    str_exp:        .asciiz "\nExpoente (Bits): "
    str_vies:       .asciiz " | Com Vies: "
    str_frac:       .asciiz "\nFracao (Mantissa): "

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
    beq $t0, 2, opt_signed
    
    beq $t0, 3, opt_floats 
    
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
    
    # BINARIO
    li $v0, 4
    la $a0, str_bin
    syscall
    move $a0, $s0
    jal print_bin_32
    
    # OCTAL 
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
    mfhi $t3 
    subu $sp, $sp, 4
    sw $t3, ($sp)
    addi $t2, $t2, 1
    j loop_stack_bcd
print_res_bcd:
    lw $t3, ($sp)
    addu $sp, $sp, 4
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

#A2 
opt_signed:
    li $v0, 4
    la $a0, msg_int
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0
    
    andi $s1, $s0, 0xFFFF 
    
    blt $s0, 0, is_neg
    
    # Se positivo
    li $v0, 4
    la $a0, str_res_16
    syscall
    li $v0, 34
    move $a0, $s1
    syscall
    j main

is_neg:
    li $v0, 4
    la $a0, str_neg_det
    syscall
    
    sub $t0, $zero, $s0
    
    li $v0, 4
    la $a0, str_bin
    syscall
    move $a0, $t0
    jal print_bin_16
    
    li $v0, 4
    la $a0, str_inv
    syscall
    not $t1, $t0
    andi $t1, $t1, 0xFFFF
    
    li $v0, 4
    la $a0, str_bin
    syscall
    move $a0, $t1
    jal print_bin_16
    
    li $v0, 4
    la $a0, str_somar1
    syscall
    addi $t2, $t1, 1
    andi $t2, $t2, 0xFFFF
    
    li $v0, 4
    la $a0, str_bin
    syscall
    move $a0, $t2
    jal print_bin_16
    
    li $v0, 4
    la $a0, str_res_16
    syscall
    li $v0, 34
    move $a0, $t2
    syscall
    
    j main

print_bin_16:
    move $t8, $a0
    li $t9, 15
loop_b16:
    srlv $t7, $t8, $t9
    andi $t7, $t7, 1
    li $v0, 1
    move $a0, $t7
    syscall
    subi $t9, $t9, 1
    bge $t9, 0, loop_b16
    jr $ra
    
opt_floats:
    li $v0, 4
    la $a0, msg_float
    syscall
    
    li $v0, 6
    syscall
    
    mfc1 $t0, $f0
    
    li $v0, 4
    la $a0, str_sinal
    syscall
    srl $t1, $t0, 31
    li $v0, 1
    move $a0, $t1
    syscall
    
    li $v0, 4
    la $a0, str_exp
    syscall
    srl $t2, $t0, 23
    andi $t2, $t2, 0xFF
    move $a0, $t2
    li $a1, 8
    jal print_bits_n
    
    # Vies Float
    li $v0, 4
    la $a0, str_vies
    syscall
    subi $t3, $t2, 127
    li $v0, 1
    move $a0, $t3
    syscall
    
    # Fracao
    li $v0, 4
    la $a0, str_frac
    syscall
    andi $t4, $t0, 0x7FFFFF
    move $a0, $t4
    li $a1, 23
    jal print_bits_n
    
    #double
    li $v0, 4
    la $a0, msg_double
    syscall
    
    li $v0, 7
    syscall
    
    mfc1 $t5, $f1
    mfc1 $t6, $f0
    
    # Sinal
    li $v0, 4
    la $a0, str_sinal
    syscall
    srl $t1, $t5, 31
    li $v0, 1
    move $a0, $t1
    syscall
    
    # Expoente
    li $v0, 4
    la $a0, str_exp
    syscall
    srl $t2, $t5, 20
    andi $t2, $t2, 0x7FF
    move $a0, $t2
    li $a1, 11
    jal print_bits_n
    
    # Vies Double
    li $v0, 4
    la $a0, str_vies
    syscall
    subi $t3, $t2, 1023
    li $v0, 1
    move $a0, $t3
    syscall
    
    # Fracao
    li $v0, 4
    la $a0, str_frac
    syscall
    
    andi $t7, $t5, 0xFFFFF
    move $a0, $t7
    li $a1, 20
    jal print_bits_n
    
    move $a0, $t6
    li $a1, 32
    jal print_bits_n
    
    j main

print_bits_n:
    subi $t9, $a1, 1
loop_bits_n:
    srlv $t8, $a0, $t9
    andi $t8, $t8, 1
    li $v0, 1
    move $a0, $t8
    syscall
    subi $t9, $t9, 1
    bge $t9, 0, loop_bits_n
    jr $ra