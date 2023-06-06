#Zarate Gutierrez, Ruben
#Pages Lopez, Juan Antonio

.data

.align 2
salida: .space 200
.align 2
eq1: .space 100
.align 2
eq2: .space 100

.text

#a0 = input_ec1, a1 = input_ec2 y a2 = output_sol
ResuelveSistema:
	
	addi $sp,$sp,-36			#Guardamos registros en la pila
        sw $ra,20($sp)
        sw $s0,16($sp)
        sw $s1,12($sp)
        sw $s2,8($sp)
        sw $s3,4($sp)
        sw $s4,0($sp)        
        sw $s5,24($sp)
        sw $s6,28($sp)
        sw $s7,32($sp)
		
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	li $t0, 0			#inicializamos a 0 los registros
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	
	la $a1, eq1
	
	jal String2Ecuacion		#Calculamos el primer objeto Ecuacion
	bnez $v0, SalirResuelve
	
	move $s0, $a1

	move $a0, $s1
	
	la $a1, eq2

	jal String2Ecuacion		#Calculamos el segundo objeto Ecuacion
	bnez $v0, SalirResuelve
	
	move $s1, $a1
	move $a0, $s0
	move $a1, $s1
	
	lw $t0, 12($a0)
	lw $t1, 12($a1)
	
	bne $t0, $t1, CompruebaDiagonal	
	
	lw $t0, 16($a0)
	lw $t1, 16($a1)
	
	bne $t0, $t1, ErrorResuelveSistema
	
LlamaCramer:
	
	move $a0, $s0
	move $a1, $s1
	la $a2, salida
	jal Cramer			#Obtenemos el objeto Solucion
	move $a0, $a2
	la $a0, salida
	move $a1, $s2
	jal Solucion2String		#Pasamos el objeto Solucion a String
	move $a2, $a1
	j SalirResuelve
	
CompruebaDiagonal:

	lw $t1, 16($a0)
	bne $t0, $t1, ErrorResuelveSistema

CompruebaDiagonal2:
	
	lw $t0, 16($a1)
	lw $t1, 12($a0)
	bne $t0, $t1, ErrorResuelveSistema
	
	sw $t1, 16($a0)			#Intercambiamos las variables de las ecuaciones
	lw $t0, 12($a1)
	sw $t0, 12($a0)
	
	j LlamaCramer
	
ErrorResuelveSistema:
	
	li $v0, 5
	
SalirResuelve:
	move $a0, $s0			#Restauramos los registros de la pila
	move $a1, $s1
	move $t2, $s2
	move $t3, $s3
	move $t4, $s4
	move $t5, $s5
	move $t6, $s6
	move $t7, $s7
        lw $ra,20($sp)
        lw $s0,16($sp)
        lw $s1,12($sp)
        lw $s2,8($sp)
        lw $s3,4($sp)
        lw $s4,0($sp)        
        lw $s5,24($sp)
        lw $s6,28($sp)
        lw $s7,32($sp)

        addi $sp,$sp, 36
        
        jr $ra
	
.text

#a0 = input_cad y a1 = output_ec		
String2Ecuacion:

	addi $sp, $sp, -4
	sw $ra, 0($sp)		#Guardamos en pila $ra	
        jal atoi
        move $t0, $v0
        sw $t0, 0($a1)
        move $v0, $v1
        bnez $v0, errorS2E
        sw $t9, 12($a1)
                
    anadoPos:
    
        addi $a0, $a0, 1
        lb $t0, 0($a0)
        beq $t0, 32, anadoPos
        
        jal atoi
        move $t0, $v0
        sw $t0, 4($a1)
        move $v0, $v1
        bnez $v0, errorS2E
        sw $t9, 16($a1)
        
    anadoPos2:
    
        addi $a0, $a0, 1
        lb $t0, 0($a0)
        beq $t0, 32, anadoPos2
        
        beq $t0, '=', cambiarLado		#Pasamos al otro lado del igual si t0 == '='
        
        j SalirErrorSintaxis
        
        
    cambiarLado:		
    
        addi $a0, $a0, 1
        jal atoi
        move $t0, $v0
	bnez $t9, CompruebaIncognitas
        sw $t0, 8($a1)
        move $v0, $v1
        li $v0, 0
        j SalirGeneral

        
        CompruebaIncognitas:
        
        	lw $t8, 16($a1)
        	bne $t9, $t8, CompruebaIncognitas2
        	j SalirErrorSintaxis
        	
        CompruebaIncognitas2:
        
        	lw $t8, 12($a1)
        	bne $t9, $t8, SalirIncognitaError
        	j SalirErrorSintaxis
        	
        
        errorS2E:
        	
        	beq $v0, 1, SalirErrorSintaxis
        	beq $v0, 2, SalirOverflowCoef
        	
        SalirIncognitaError:
        
     	  	li $v0, 4    	
        	j SalirGeneral
        	
        SalirOverflowCoef:
        
        	li $v0, 2
        	j SalirGeneral
        
        SalirErrorSintaxis:
        
        	li $v0, 1
        
        SalirGeneral:
        	        
        	lw $ra, 0($sp)				#Restauramos la pila
		addi $sp, $sp, 4	
        	jr $ra
        
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

    lb $t4, ($a0)            # guardamos primer digito de la cadena en t4
    beq $t4, $t0, WhiteSpace    # comprobamos si es blanco, positivo o negativo
    beq $t4, $t1, Pos
    beq $t4, $t2, Neg
    beqz $a0, PreSalirCero        # compruebo si es 0, si lo es salimos
    li $t2, 0
    li $t0, 0
    li $t1, 0

Bucle:         

    blt $t4, 48, SalirCharIncorrecto
    bgt $t4, 57, CompLetra1
    addi $t4, $t4, -48        # pasamos primer caracter a entero
    addu $t2, $t6 ,$t4
    
    bltz $t2, MinInt		# detectamos el overflow en la suma	
    
    addi $a0, $a0, 1        # avanzamos una posicion del puntero para la siguiente iteracion
    lb $t4, ($a0)
    beqz $t4, SalirCorrecto
    blt $t4, 48, SalirCorrecto
    bgt $t4, 57, CompLetraN
    mult $t2, $t3              #  *10
    mflo $t6
    mfhi $t5
    bnez $t5, SalirNumGrande	#Comprobamos Overflow
    bltz $t6, SalirNumGrande
    
    
    j Bucle


WhiteSpace:
    addi $a0, $a0, 1        # avanzamos una posicion del puntero para la siguiente iteracion
    j CompruebaSig

Pos:
    addi $a0, $a0, 1        # avanzamos una posicion del puntero para la siguiente iteracion
    lb $t4, ($a0)            # guardamos primer digito de la cadena en t4
    li $t2, 0
    li $t1, 0
    j Bucle

Neg:
    addi $a0, $a0, 1        # avanzamos una posicion del puntero para la siguiente iteracion
    lb $t4, ($a0)            # guardamos primer digito de la cadena en t4
    li $t7, -1
    li $t2, 0
    j Bucle
	
CompLetra1:
	
	blt $t4, 65, SalirCharIncorrecto
	bgt $t4, 122, SalirCharIncorrecto
	
	CompLetraMayus1:
		bgt $t4, 90, CompLetraMinus1
		li $t0, 1
		mult $t0, $t7
		mflo $v0
		lb $t9, ($a0)
		j Salir
	
	CompLetraMinus1:

		blt $t4, 97, SalirCharIncorrecto
		li $t0, 1
		mult $t0, $t7
		mflo $v0
		lb $t9, ($a0)
		j Salir
    
CompLetraN:
	
	blt $t4, 65, SalirCharIncorrecto		#Comprobamos si es una letra valida
	bgt $t4, 122, SalirCharIncorrecto
	
	CompLetraMayus:
	
		bgt $t4, 90, CompLetraMinus
		mult $t7, $t2
		mflo $v0
		lb $t9, ($a0)
		j Salir
	
	CompLetraMinus:

		blt $t4, 97, SalirCharIncorrecto
		mult $t7, $t2
		mflo $v0
		lb $t9, ($a0)
		j Salir
		

PreSalirCero:
    li $v0, 0
    j Salir
    
SalirCorrecto:
    mult $t2, $t7            # si es negativo en t7 hay un -1
    mflo $v0
    li $v1, 0
    li $t9, 0
    j Salir

SalirCharIncorrecto:

    li $v1, 1
    j Salir

MinInt:
	bne $t2, -2147483648, SalirNumGrande	#Comprobamos overflow
	beq $t7, -1, SalirCorrecto

SalirNumGrande:

    li $v1, 2
    
Salir:
	jr $ra


.data

indeterminado : .asciiz "INDETERMINADO"
incompatible: .asciiz "INCOMPATIBLE"
.text

#a0 = input_sol y a1 = output_str, siempre genera cadena
Solucion2String:

	addi $sp, $sp, -4			# Guardamos ra en pila
	sw $ra, 0($sp)
	li $a2, 0
	
	move $a2, $a0
	
	lw $t0, 0($a2)
	beq $t0, 2, SalirIncompatible		# Comprobamos el tipo de solucion
	beq $t0, 1, SalirIndeterminado
	
	lw $t0, 28($a2)				# Metemos en el string la primera ecuacion
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
	beqz $t0, AddDecimales		# Bucle que va metiendo cantidad de ceros necesaria en la primera variable
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

AddVar2:				# Metemos en el string el espacio y la segunda varibale con su igual
	li $t1, ' '
	sb $t1, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 32($a2)
	sb $t0, ($t5)
	addi $t5, $t5, 1
	li $t0, '='
	sb $t0, ($t5)			# Metemos el igual de la segunda variable
	addi $t5, $t5, 1
	
	lw $t0, 16($a2)
	move $a0, $t0
	move $a1, $t5
	jal itoa	
	
	lw $t0, 24($a2)
	beqz $t0, SalirSol2Str		# Si t0 == 0 solucion correcta
	
	li $t1, '.'			# Metemos el punto de la segunda variable
	sb $t1, ($t5)
	addi $t5, $t5, 1
	
	lw $t0, 20($a2)
	
AddZero2:
	beqz $t0, AddDecimales2		# Bucle que va metiendo cantidad de ceros necesaria en la segunda variable
	li $t1, '0'
	sb $t1, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, -1
	bnez $t0, AddZero2
	
AddDecimales2:
	lw $t0, 24($a2)			# Metemos los decimales de la segunda variable
	move $a0, $t0
	move $a1, $t5
	jal itoa
	j SalirSol2Str

SalirIndeterminado:
	la $a0, indeterminado
Loop1:
	lb $t0, ($a0)			# Bucle que recorre caracter a caracter INDETERMINADO
	sb $t0, ($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, Loop1
	j SalirSol2Str
	
SalirIncompatible:
	la $a0, incompatible
Loop2:					# Bucle que recorre caracter a caracter INCOMPATIBLE
	lb $t0, ($a0)
	sb $t0, ($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, Loop2

SalirSol2Str:
	lw $ra, 0($sp)			# Restauramos la pila
	addi $sp, $sp, 4
	jr $ra

.data

.text

itoa:	
	li $t1, 10		
	move $t0, $a0		
	move $t2, $a1		
	
	beq $a0, $zero, PreSalirCeroItoa	
	bgtz $a0, PosItoa	 
	
NegItoa:					
	li $t4, '-'													
	sb $t4, ($t2) 		# Almaceno en primera posicion de t2 el -
	addi $a1, $a1, 1	# Avanzo una posicion a la derecha en a1
	addi $t2, $t2, 1	# Avanzo una posicion a la derecha en t3
	li $t4, -1		
	mult $t4, $t0		
	mflo $t0		
	 	
PosItoa: 	
	divu $t0, $t1		
	mfhi $t3	
	addi $t3, $t3, '0'	
	
	sb $t3,($a1)		# Guardamos el resto en a1
	addi $a1, $a1, 1	
	mflo $t0		
	bne $t0, $zero, PosItoa 	# Si cociente es distinto de 0 Bucle
	move $t5, $a1		# Guarda la ultima posicion
	addi $a1, $a1, -1	# Avanza a1 a la penultima posicion
	
Invertir:
	lb $t3, ($a1)		# Cargo la penultima posicion en t3
	lb $t4, ($t2)		# Cargo la primera posicion en t4
	sb $t3, ($t2)		# Almaceno t3 en la primera posicion
	sb $t4, ($a1)		# Almaceno t4 en la penultima posicion
	addi $t2, $t2, 1	# Avanzo una posición t2
	addi $a1, $a1, -1	# Retrocedo una posicion a1
	bge $a1, $t2, Invertir	# Si a1 >= t2 sigo invirtiendo
	sb $zero, ($t5)		# Almaceno fin de linea en t5
	
	bgtz $a0, SalirItoa	# Compruebo si es 0
	addi $a1, $a1, -1	
	j SalirItoa
	
PreSalirCeroItoa:
	li $t3, 0
	addi $t3, $t3, '0'
	sb $t3, ($a1)		# Guardo el 0 en a1
	addi $a1, $a1, 1	
	sb $zero, ($a1)		
	addi $a1, $a1, -1
	move $t5, $a1
	addi $t5, $t5, 1
																																	
SalirItoa:																					
	jr $ra
	
