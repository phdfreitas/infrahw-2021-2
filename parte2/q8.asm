# Algoritmo escrito em c, usado de base para responder essa questao da lista: 

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# int soma(int a, int b){                         |
#     if(b < a){                                  |
#         return b;                               |
#     }                                           |
#                                                 |
#     return b + soma(a, b - 1);                  |
#                                                 |
# }                                               |
#                                                 |
# int main(int argc, char const *argv[]){         |
#                                                 |
#     printf("Int: %d\n", soma(1, 5));            |
#                                                 |
#     return 0;                                   |
# }                                               |
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

.data 
A: .word 1
B: .word 5

.text
lw $t0, A
lw $t1, B

bgt $t0, $t1, AmaiorB

soma:
addi $sp, $sp, -12   	# 3 itens
sw $ra, 8($sp)       	# endereco de retorno
sw $a0, 4($sp)       	# argumento 1
sw $a1, 0($sp)       	# argumento 2
slt $t2, $t1, $t0    	# Checo se b < a
beq $t2, $zero, main 
add  $v0, $zero, $a1 	# se for, retorno o valor que esta em B
addi $sp, $sp, 12    	# removo os 3 itens da pilha
jr $ra               	# e retorno
			
main:               	 
add $a0, $zero, $t0    	# O primeiro argumento continua com o mesmo valor inicial
add $a1, $a1, $t1   	# E o segundo argumento recebe o valor anterior - 1
addi $t1, $t1, -1	# subtrai 1 do valor que vai ser/e o segundo argumento
jal soma            	# chamo a funcao recursiva de soma
lw $a0, 0($sp)      	# Controle da pilha
lw $a1, 4($sp)
lw $ra, 8($sp) 
addi $sp, $sp, 12
j fim

AmaiorB:
addi $v1, $v1, 1 

fim:
