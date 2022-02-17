.data
B: .word 2
E: .word 1
I: .word 0
RES: .word 5

.text
lw $t0, B 
lw $t1, E
lw $t3, I
lw $t4, RES

slt $t5, $t3, $t1
bne $t5, $zero, for

for:
mul $t4, $t4, $t0
addi $t3, $t3, 1
bne $t3, $t1, for
beq $t3, $t1, fim

fim:


