.data 
A: .word 5
B: .word 6
C: .word 12
r: .word 0

.text
lw $t0, A # ponto A
lw $t1, B # ponto B
lw $t2, C # ponto C
lw $t3, r # valor de R 

add $s0, $t0, $t1 # $s0 recebe a soma de A + B -> 
add $s1, $t0, $t2 # $s1 recebe a soma de A + C -> 
add $s2, $t1, $t2 # $s3 recebe a soma de B + C -> 

blt $s0, $t2, naoEhTriangulo # caso (A + B) < C nao e um triangulo
blt $s1, $t1, naoEhTriangulo # caso (A + C) < B nao e um triangulo
blt $s2, $t0, naoEhTriangulo # caso (B + C) < A nao e um triangulo

beq $t0, $t1, AigualB      # if (A == B) vai para branch AigualB
bne $t0, $t1, AdiferenteB  # caso contrario, vai para branch AdiferenteB

AigualB:
beq $t0, $t2, equilatero # Caso A == C tambem, entao o triangulo e equilatero
bne $t0, $t2, isosceles  # se A != C, entao o triangulo e isosceles
 
AdiferenteB:
beq $t0, $t2, isosceles  # se A != B && A == C, entao o triangulo e isosceles
beq $t0, $t1, isosceles  # se (A != B && A != C) mas A == B, entao o triangulo tbm e isosceles
bne $t1, $t2, escaleno   # se chegou ate aqui, entao: A != B, A != C && B != C, portanto, o triangulo e escaleno

equilatero:
addi $s3, $t3, 1 # coloco no registrador $s3 o valor 1 (ja que $t3 tem 0)
sw $s3, r
j fim

isosceles:
addi $s3, $t3, 2 # coloco no registrador $s3 o valor 2 (ja que $t3 tem 0)
sw $s3, r
j fim

escaleno:
addi $s3, $t3, 3 # coloco no registrador $s3 o valor 3 (ja que $t3 tem 0)
sw $s3, r
j fim

naoEhTriangulo:
sw $s3, r
j fim

fim:
  
    