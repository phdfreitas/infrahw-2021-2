.data 
Texto: .asciiz "EntradA" 

.text
j main

ordenar: 	# ordena as letras da string
lb $t1, ($a0) 	# carrega primeiro byte para verificar se a string e vazia
beq $t1, $zero, Returnbs 

Loopbs: 	#loop bubble sort
li $t0, 0 
la $t1, ($a0) 
la $t2, ($a0) 
addi $t2, $t2, 1 

LoopTransicao:	#loop de transi��o
lb $t3, 0($t1) 	#carrega caractere n e n+1 
lb $t4, 0($t2) 
beq $t4, $zero, ExitLoopTransicao  # verificando se o byte e o caractere nulo, caso sim, sai da transicao 
sgt $t5, $t3, $t4  		   # verfica se o caractere na posicao n � maior que n+1
beq $t5, 0, ProximaTransicao 	   # caso nao seja, segue para proxima transicao	
addi $t6, $t4, 0	#aqui a gente faz a troca de posi��o
addi $t4, $t3, 0 	# (n+1) = n
addi $t3, $t6, 0 	# n = temp
sb $t3, ($t1) 		# carrega n+1 e n na mem�ria
sb $t4, ($t2)
li $t0, 1 		# passa a informacao que houve troca 

ProximaTransicao:
addi $t1, $t1, 1
addi $t2, $t2, 1
j LoopTransicao

ExitLoopTransicao:
beq $t0, $zero, Returnbs  # caso nao tenha trocado ordem no array saimos do loop
j Loopbs

Returnbs:
jr $ra

# fun��o para deixar string lower case
lowercase: 
	Looplc:
	# carregando o registrador
	lb $t0, 0($a0) 
	# verificando se o byte � o catctere nulo, se for retornamos a fun��o
	beq $t0, $zero, Returnlc 

	# verifica se o caractere � maior ou igual a 97 e faz o mesmo para 122 para ve se ja � min�scula
	sge $t2, $t0, 97  
	sle $t1, $t0, 122
	and $t3, $t2, $t1 
	beq $t3, 1, ProximoCaractere 

	# verifica se � mai�scula
	sge $t2, $t0, 65 
	sle $t1, $t0, 90 
	and $t3, $t2, $t1 
	bne $t3, 1, Erro 
	addi $t0, $t0, 32 
	# inserindo o caractere min�sculo de volta no array
	sb $t0, ($a0) 
	# vai para o pr�ximo caractere
	j ProximoCaractere 

Erro:
	addi $v1, $zero, 1
	j Returnlc

ProximoCaractere:
	addi $a0, $a0, 1
	j Looplc
Returnlc:
	jr $ra

main:
# carrega o endere�o na string e passa para fun��o
la $s1, Texto 
la $a0, ($s1) 
# chama a fun��o lower case e depois a fun��o para ordenar
jal lowercase 
beq $v1, 1, Fim 
# passando endere�o como argumento da funcao
la $a0, ($s1) 
# chamando o label ordenar
jal ordenar 
Fim:
