.data

A:     .word 3, 4, 5
Asize: .word 12
i:     .word 0
j:     .word 2

B: .space 100

.text


lw $t0, i  #index do array
lw $t1, j
la $s0, A
la $s1, B
lw $t4, Asize

addi $s1, $zero, 0
add $t4, $t4, $s0   #posição final do array A na memoria

L1:
sll $s2, $t0, 2          #endereço no array mais 4
add $s2, $s2, $s0        #inicio do array
beq $s2, $t4, exit       #quando chegar no tamanho do array, acabar o programa
lw $t2, 0($s2)	         #colocar o elemento do Array A em $t2
li $t1, 2                #fazer valor de j voltar para 2
bne $t2, $zero, ehPrimo  #verificar se o número é primo
j L1

li $t5, 1  #constante
li $t6, 2  #constante

ehPrimo:
beq $t5, $t2, if      # se o valor do array A for 1, va para o if
beq $t6, $t2, Else    # se o valor do array A for 2, é primo va pro else

#caso seja outro valor
div $t2, $t1           #divida o número por j
mfhi $s3               #pegar o resto de hi
beq $s3, $zero, if     #verificar se o resto é zero, se for, não é primo
beq $t1, $t2, Else     #verificar se j incrementou até ficar igual ao numero,se ficou vai pra Else
addi $t1, $t1, 1       #j++
bne $t1, $t2, ehPrimo  # se j!= número, volta pro loop
j Else

if:
addi $t0, $t0, 1       #i++
j L1                   #manda pro próximo número do array A


Else:
sw $t2, B($s1)    #é primo, coloca no outro array
addi $s1, $s1, 4  #almenta a posição do array B
addi $t0, $t0, 1  #i++
j L1              #manda pro próximo número do array A

exit:




