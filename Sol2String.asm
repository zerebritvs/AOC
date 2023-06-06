#Zarate Gutierrez, Ruben
#Pages Lopez, Juan Antonio
# posible caso, numeros partes enteras negativas

String2Ecuacion:
	jr $ra

ResuelveSistema:
	jr $ra

.data

indeterminado : .asciiz "INDETERMINADO"
incompatible: .asciiz "INCOMPATIBLE"
.text

#a0=input_sol, a1=output_str, siempre genera cadena
Solucion2String:
	sw $ra, 0($sp)
	move $a2, $a0
	
	lw $t0, 0($a2)
	beq $t0, 2, SalirIncompatible
	beq $t0, 1, SalirIndeterminado
	
	lw $t0, 28($a2)
	sb $t0, ($a1)
	addi $a1, $a1, 1
	li $t0, '='
	sb $t0, ($a1)
	addi $a1, $a1, 1
	
	lw $t0, 4($a2)

	move $a0, $t0
	jal itoa
	
	lw $t0, 12($a2)
	beqz $t0, AddVar2
	
	li $t1, '.'
	sb $t1, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 8($a2)
	
AddZero:
	beqz $t0, AddDecimales
	li $t1, '0'
	sb $t1, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, -1
	bnez $t0, AddZero
	
AddDecimales:
	lw $t0, 12($a2)
	move $a0, $t0
	move $a1, $t5
	jal itoa

AddVar2:
	li $t1, ' '
	sb $t1, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 32($a2)
	sb $t0, ($t5)
	addi $t5, $t5, 1
	li $t0, '='
	sb $t0, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 16($a2)
	move $a0, $t0
	move $a1, $t5
	jal itoa	
	
	lw $t0, 24($a2)
	beqz $t0, SalirSol2Str
	
	li $t1, '.'
	sb $t1, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 20($a2)
	
AddZero2:
	beqz $t0, AddDecimales2
	li $t1, '0'
	sb $t1, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, -1
	bnez $t0, AddZero2
	
AddDecimales2:
	lw $t0, 24($a2)
	move $a0, $t0
	move $a1, $t5
	jal itoa
	j SalirSol2Str

SalirIndeterminado:
	la $a0, indeterminado
Loop1:
	lb $t0, ($a0)
	sb $t0, ($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, Loop1
	j SalirSol2Str
	
SalirIncompatible:
	la $a0, incompatible
Loop2:
	lb $t0, ($a0)
	sb $t0, ($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, Loop2

SalirSol2Str:

	lw $ra, 0($sp)
	jr $ra

.data

.text

itoa:	
	li $t1, 10		
	move $t0, $a0		
	move $t2, $a1		
	
	beq $a0, $zero, PreSalirCero	
	bgtz $a0, Pos		 
	
Neg:					
	li $t4, '-'													
	sb $t4, ($t2) 		# almaceno en primera posicion de t2 el -
	addi $a1, $a1, 1	# avanzo una posicion a la derecha en a1
	addi $t2, $t2, 1	# avanzo una posicion a la derecha en t3
	li $t4, -1		
	mult $t4, $t0		
	mflo $t0		
	 	
Pos: 	
	divu $t0, $t1		
	mfhi $t3	
	addi $t3, $t3, '0'	
	
	sb $t3,($a1)		# guardamos el resto en a1
	addi $a1, $a1, 1	
	mflo $t0		
	bne $t0, $zero, Pos 	# si cociente es distinto de 0 Bucle
	move $t5, $a1		# guarda la ultima posicion
	addi $a1, $a1, -1	# avanza a1 a la penultima posicion
	
Invertir:
	lb $t3, ($a1)		# cargo la penultima posicion en t3
	lb $t4, ($t2)		# cargo la primera posicion en t4
	sb $t3, ($t2)		# almaceno t3 en la primera posicion
	sb $t4, ($a1)		# almaceno t4 en la penultima posicion
	addi $t2, $t2, 1	# avanzo una posición t2
	addi $a1, $a1, -1	# retrocedo una posicion a1
	bge $a1, $t2, Invertir	# si a1 >= t2 sigo invirtiendo
	sb $zero, ($t5)		# almaceno fin de linea en t5
	
	bgtz $a0, SalirItoa	# compruebo si es 0
	addi $a1, $a1, -1	
	j SalirItoa
	
PreSalirCero:
	li $t3, 0
	addi $t3, $t3, '0'
	sb $t3, ($a1)		# guardo el 0 en a1
	addi $a1, $a1, 1	
	sb $zero, ($a1)		
	addi $a1, $a1, -1	
																			
SalirItoa:																					
	jr $ra
