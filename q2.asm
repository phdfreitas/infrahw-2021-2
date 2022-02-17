.data
A: .word 81  # a = 81 (ultima condicao do if dentro do for)
B: .word 0   # b = 0  
i:  .word 0  # int i = 0
n: .word 10  # usei para representar o i != 10
r: .word 0   # usei para o store, no final do if/for

.text
lw $t0, A 
lw $t1, B 
lw $t3, i 
lw $t4, n

slt $t5, $t3, $t4    # checo se i < 10 -> $t5 = 1
bne $t5, $t4, for    # checo se $t5 e diferente de 10, "como se fosse i != 10", e vou para o for

for:
mul $t6, $t3, $t3    # primeiro, faco a multiplicacao (i * i) e coloco o resultado em $t6
beq $t6, $t0, if1    # verifico se (i * i) = a, se for, vou para if1
addi $t3, $t3, 1     # caso nao seja, somo 1 a i, ou seja, i++
bne $t3, $t4, for    # verifico se i != 10, caso seja, executo o for novamente. 
beq $t3, $t4, if2    # caso i == 10, vou para o if2

if1:
li $t1, 1            # caso (i * i) == a, faco b = 1
j fim1               # e vou para o break, que termina o loop

if2:
beq $t1, $zero, fim2 # Quando o loop acabar, se b == 0, vou para fim2

fim1:                # caso a condicao do if dentro do for tenha sido satisfeita
sw $t0, r            # guardo a 
beq $t1, $zero, fim2 # (ja "fora do loop") verifico se b == 0, se for, vou para fim2
bne $t1, $zero, fim  # caso nao seja, apenas termino o programa.

fim2:                # se b == 0, apenas guardo b.
sw $t1, r

fim:                 # Label apenas para o programa nao executar indevidamente.