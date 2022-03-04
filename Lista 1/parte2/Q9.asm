.data

n: .word 4

.text

lw $a0, n

main:
jal f
j fim 
## o valor do menor numero de movimentos ficara armazenado em $v0

f: 
addi $sp, $sp, -8    # decrementa em 2 sp na pilha
sw $ra, 4($sp)       # salva o endereço de retorno de $ra na pilha, acima do endereço atual de sp
sw $a0, 0($sp)       # salva o n dessa etapa no endereço atual de sp
slti $t0, $a0, 2     # verifica se $a0 é menor que 2, se nao for, $t0 == 0 
beq $t0, $zero, L1   # se $t0 == 0, mais uma recursão deve ser feita
addi $v0, $zero, 1   # salva em $v0 o valor atual da soma das recursoes
addi $sp, $sp, 8     # recursão finalizada, sp deve ser incrementado para voltar aos valores do n que sera trabalhado
jr $ra

L1:
addi $a0, $a0, -1  # valor de n --
jal f              # verifica o valor de f para f($a0 - 1)
lw $a0, 0($sp)     # recupera o valor de n anterior ao da ultima recursao feita
lw $ra, 4($sp)     # recupera o valor de retorno do n atual (o que foi recuperado)
addi $sp, $sp, 8   # sobre dois endereços em sp
add $v0, $v0, $v0  # 2*(f(n-1))
addi $v0, $v0, 1   # +1
jr $ra


fim:

