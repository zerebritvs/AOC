#Ruben Zárate Gutiérrez
#Juan Antonio Pagés López

.data

cadena: .asciiz "cadena"

.text

itoa:
	li $t1, 10		# t1 = 10
	move $t0, $a0		# t0 = a0
	move $t2, $a1		# t2 = a1
	
	
	beq $a0, $zero, PreSalirCero	# compruebo si es 0
	
	bgtz $a0, Pos		# comprobamos si es negativo 
	
Neg:					
	li $t4, '-'		# guardo el - en t4											
	sb $t4, ($t2) 		# almaceno en primera posicion de t2 el -
	addi $a1, $a1, 1	# avanzo una posicion a la derecha en a1
	addi $t2, $t2, 1	# avanzo una posicion a la derecha en t3
	li $t4, -1		# cargo un -1 en t4
	mult $t4, $t0		# multiplico -1 por t0
	mflo $t0		# abs(t0) = t0
	 	
Pos: 	
	divu $t0, $t1		# a0/10
	mfhi $t3		# t3 = mfhi
	addi $t3, $t3, '0'	# paso a ASCII el numero
	
	sb $t3, ($a1)		# guardamos el resto en a1
	addi $a1, $a1, 1	# avanzamos posicion en a1
	mflo $t0		# remplazamos el cociente en t0
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
	addi $a1, $a1, -1	# retrocedo una posicion
	j SalirItoa
	
PreSalirCero:
	addi $t3, $t3, '0'	# paso a ASCII el 0
	sb $t3, ($a1)		# guardo el 0 en a1
	addi $a1, $a1, 1	# avanzo una posicion a1
	sb $zero, ($a1)		# guardo fin de linea en a1
	addi $a1, $a1, -1	# retrocedo una posicion a1
																			
SalirItoa:																					
	jr $ra
	
