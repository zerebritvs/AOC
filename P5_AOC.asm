#Zarate Gutierrez, Ruben
#Pages Lopez, Juan Antonio

.data

.text

logaritmos:
	addi $sp, $sp, -16	
 	sw $ra, 0($sp)		# guardamos en pila $ra
 	sw $s3, 4($sp)		# guardamos en pila $s3 (resultado atoi)
 	sw $s0, 8($sp)		# guardamos en pila $s0 (resultado log2)
 	sw $s1, 12($sp)		# guardamos en pila $s1	(a1)
 	
	move $s1, $a1
	
	jal atoi
	
	beq $v1, 2, SalirError2
	beq $v1, 1, SalirError1
	
	move $a0, $v0
	move $s3, $v0		# resultado atoi			
 	
	jal log2
	
	bnez $v1, SalirError3
	
	move $a0, $s3
	move $s0, $v0
	
	jal log10
	
	bnez $v1, SalirError3
	move $a0, $s0		# resultado de log2
 	move $a1, $s1		# cadena final a1
 	
	bnez $a0, Log2_0
	addi $a0, $a0, '0'
	sb $a0,($a1)
	addi $a1, $a1, 1
	li $t0, 32
	sb $t0,($a1)
	addi $a1, $a1, 1
	move $a0, $v0
	j itoa2
	
Log2_0:	
	jal itoa
	
	li $t0, 32
	sb $t0,($t5)		# añado el espacio
	addi $t5, $t5, 1
	move $a1, $t5
	move $a0, $v0 		# resultado de log10
	
itoa2:
	jal itoa
	
	li $v0, 0
	
	j SalirLog
	
SalirError1:
	li $v0, 1
	j SalirLog
	
SalirError2:		
	li $v0, 2
	j SalirLog			
	
SalirError3:
	li $v0, 3

SalirLog:
	lw $ra, 0($sp)
	lw $s3, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)	
 	addi $sp, $sp, 16	# cargamos $ra de la pila

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
	

.data

.text

atoi:	
	li $t0, 32
	li $t1, 43
	li $t2, 45
	li $t3, 10
	li $t7, 1
	li $t6, 0
	li $t4, 0
	 
CompruebaSig:
	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	beq $t4, $t0, WhiteSpace	# comprobamos si es blanco, positivo o negativo
	beq $t4, $t1, PosAtoi
	beq $t4, $t2, NegAtoi
	beqz $a0, PreSalir0		# compruebo si es 0, si lo es salimos
	li $t2, 0
	li $t0, 0
	li $t1, 0

Bucle:			
	blt $t4, 48, SalirCharIncorrecto
	bgt $t4, 57, SalirCharIncorrecto
	addi $t4, $t4, -48		# pasamos primer caracter a entero
	addu $t2, $t6 ,$t4
	
	or $t0, $t6, $t2
	or $t1, $t4, $t2
	and $t0, $t0, $t1
	blt $t0, $zero, SalirNumGrande	# detectamos el overflow en la suma
	
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)
	beqz $t4, SalirCorrecto
	blt $t4, 48, SalirCorrecto
	bgt $t4, 57, SalirCorrecto
	mult $t2, $t3  			#  *10
	mflo $t6
	mfhi $t8
	bnez $t8, SalirNumGrande
	bltz $t6, SalirNumGrande
	
	or $t0, $t2, $t6
	or $t1, $t3, $t6
	and $t0, $t0, $t1
	blt $t0, $zero, SalirNumGrande	# detectamos el overflow en la suma
	
	j Bucle


WhiteSpace:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	j CompruebaSig

PosAtoi:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	li $t2, 0
	li $t1, 0
	j Bucle

NegAtoi:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	li $t7, -1
	li $t2, 0
	j Bucle

	
PreSalir0:
	li $v0, 0
	j SalirAtoi
	
SalirCorrecto:
	mult $t2, $t7			# si es negativo en t7 hay un -1
	mflo $v0
	li $v1, 0
	j SalirAtoi

SalirCharIncorrecto:
	li $v1, 1
	j SalirAtoi

SalirNumGrande:
	li $v1, 2

SalirAtoi:
	jr $ra
