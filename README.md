# Projeto InfraHW - 2021.2

# Unidade de Processamento
<div>
    <img src="Projeto\Unidade de Processamento\Unidade de Processamento.png"/>
</div>

# Instruções 
## Formato R
- [x] add rd, rs, rt 
- [x] and rd, rs, rt 
- [x] div rs, rt 
- [x] mult rs,rt 
- [] jr rs 0x0 rs # Não tenho certeza se está feito
- [x] mfhi rd
- [x] mflo rd
- [x] sll rd, rt, shamt 
- [x] sllv rd, rs, rt 
- [x] slt rd, rs, rt 
- [x] sra rd, rt, shamt 
- [x] srav rd, rs, rt
- [x] srl rd, rt, shamt 
- [x] sub rd, rs, rt
- [] break
- [x] Rte 
- [] addm rd, rs,rt

## Formato I
- [] addi rt, rs imediato
- [] addiu rt, rs imediato
- [x] beq rs,rt, offset
- [x] bne rs,rt, offset
- [x] ble rs,rt,offset
- [x] bgt rs,rt,offset
- [] sllm rt, offset(rs)
- [] lb rt, offset(rs)  
- [] lh rt, offset(rs) 
- [] lui rt, imediato  
- [x] lw rt, offset(rs) 
- [] sb rt, offset(rs)
- [] sh rt, offset(rs) 
- [] slti rt, rs, imediato
- [x] sw rt, offset(rs) 

# Formato J
- [x] j offset
- [x] jal offset