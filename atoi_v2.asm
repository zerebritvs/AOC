#Zarate Gutierrez, Ruben
#Pages Lopez, Juan Antonio

.data

.text

atoi:
	li $t0, 32
	li $t1, 43
	li $t2, 45
	li $t3, 10
	li $t8, 48
	li $t9, 57
	li $t7, 1
	li $t6, 0
	li $t4, 0
	 
CompruebaSig:

	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	beq $t4, $t0, WhiteSpace	# comprobamos si es blanco, positivo o negativo
	beq $t4, $t1, Pos
	beq $t4, $t2, Neg
	beqz $a0, PreSalirCero		# compruebo si es 0, si lo es salimos
	li $t2, 0
	li $t0, 0
	li $t1, 0

Bucle:			
	blt $t4, $t8, SalirCharIncorrecto
	bgt $t4, $t9, SalirCharIncorrecto
	addi $t4, $t4, -48		# pasamos primer caracter a entero
	addu $t2, $t6 ,$t4
	
	or $t0, $t6, $t2
	or $t1, $t4, $t2
	and $t0, $t0, $t1
	blt $t0, $zero, SalirNumGrande	# detectamos el overflow en la suma
	
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)
	beqz $t4, SalirCorrecto
	blt $t4, $t8, SalirCorrecto
	bgt $t4, $t9, SalirCorrecto
	mult $t2, $t3  			#  *10
	mflo $t6
	
	or $t0, $t2, $t6
	or $t1, $t3, $t6
	and $t0, $t0, $t1
	blt $t0, $zero, SalirNumGrande	# detectamos el overflow en la suma
	
	j Bucle


WhiteSpace:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	j CompruebaSig

Pos:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	li $t2, 0
	li $t1, 0
	j Bucle

Neg:
	addi $a0, $a0, 1		# avanzamos una posicion del puntero para la siguiente iteracion
	lb $t4, ($a0)			# guardamos primer digito de la cadena en t4
	li $t7, -1
	li $t2, 0
	j Bucle

	
PreSalirCero:
	li $v0, 0
	j Salir
	
SalirCorrecto:
	mult $t2, $t7			# si es negativo en t7 hay un -1
	mflo $v0
	li $v1, 0
	j Salir

SalirCharIncorrecto:

	li $v1, 1
	j Salir

SalirNumGrande:

	li $v1, 2
	j Salir

Salir:
	jr $ra
