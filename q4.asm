.data
B: .word 2     # int b = 2
E: .word 1     # int e = 1
RES: .word 5   # res = 1
I: .word 0     # int i = 0

.text
lw $t0, B 
lw $t1, E
lw $t3, I
lw $t4, RES

slt $t5, $t3, $t1    # if (I < E) $t5 = 1
bne $t5, $zero, for  # if ($t5 != 0), vai para o for

for:
mul $t4, $t4, $t0  # res *= 2 (nesse caso, o 2 esta sendo representado pelo B)
addi $t3, $t3, 1   # i++
bne $t3, $t1, for  # caso i != e, chamo o for novamente.
beq $t3, $t1, fim  # e caso seja, pulo para encerrar o programa

fim: