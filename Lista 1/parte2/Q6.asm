.data

A: .word -13
B: .word -2
RESULT: .word 0
REMAINDER: .word 0

.text

lw $t0, A # dividendo
lw $t1, B # divisor

#verifica e salva se o divisor e dividendo são positivos ou negativos
slt $s0, $t0, $zero        #se o dividendo for negativo -> $s0 == 1
beq $s0, $zero, t0pos      #se o dividendo nao for negativo, pule a proxima instrução
sub $t0, $zero, $t0        #converte o valor negativo em positivo
t0pos: slt $s1, $t1, $zero #se o divisor for negativo -> $s1 == 1
beq $s1, $zero, loop       #se o divisor nao for negativo, pule a proxima instrução
sub $t1, $zero, $t1        #converte o valor negativo em positivo

loop:
slt $t2, $t0, $t1    #verifica se o valor restante do dividendo é maior (divisivel) que o divisor
bne $t2, $zero, cont #se o valor for menor, termine o loop
sub $t0, $t0, $t1    # dividendo > divisor, entao o dividendo é subtraído o valor do divisor
addi $s3, $s3, 1     # adicione 1 ao numero de divisoes feitas no dividendo
j loop

cont:
beq $s0, $zero, res      # considera se o dividendo for negativo, o que implicaria que o resto deve ser negativo tambem
sub $t0, $zero, $t0      # transforma em negativo o resto
res: beq $s0, $s1, store # se o divisor e o dividendo forem + +/- - o resultado será positivo e nao precisara ser modificado 
sub $s3, $zero, $s3      # tranforma em negativo o resultado

store:
sw $t0, REMAINDER
sw $s3, RESULT