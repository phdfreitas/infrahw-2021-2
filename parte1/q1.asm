.data
A: .word 0
B: .word 2
X: .word 0

.text
lw $t0, A 
lw $t1, B 
lw $t3, X

bne $t0, $zero, verifica1 # Caso a != 0, precisamos verificar se b == 0 ou != 0.
beq $t0, $zero, verifica2 # Caso a == 0, precisamos verificar se b == 0 ou != 0.

verifica1:
beq $t1, $zero, if        # Caso b == 0, entao "para" no if, ou seja, x = 1
bne $t1, $zero, else      # Caso b != 0, entao vai para o else, ou seja, x = 4 

verifica2:
beq $t1, $zero, elseif1   # Se a == 0 && b == 0, entao x = 2
bne $t1, $zero, elseif2   # Caso contrario, a == 0 and b != 0, logo x = 3


# Em todos os labels abaixo, como x comeca com 0, entao eu so precisei adicionar em x o
# respectivo valor, nesse caso, 1 2 3 ou 4. 
# Quanto ao jump, eu so usei pra assim que fizer a adicao, terminar o programa :) 
if:
addi $t3, $t3, 1  
j fim 

elseif1:
addi $t3, $t3, 2
j fim

elseif2:
addi $t3, $t3, 3
j fim

else:
addi $t3, $t3, 4 
j fim

fim:
