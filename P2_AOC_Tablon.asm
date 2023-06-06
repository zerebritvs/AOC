# Juan Antonio Pagés López
# Rubén Zárate Gutiérrez
.data
 
 Cero: .float 0.0
 Dos: .float 2.0
 Mensaje: .ascii "f(a) tiene el mismo signo que f(b)"
 
.text
 
 Bisec:
 
 addi $sp, $sp, -4	
 sw $ra, 0($sp)		# guardamos en pila $ra
 
 la $t0, Cero		
 lwc1 $f1, 0($t0)	# const 0 en f1
 
 la $t0, Dos		
 lwc1 $f2, 0($t0)	# const 2 en f2
 
 mov.s $f16, $f12
 
 jal Funcion 		# calculamos f(a)
 
 mov.s $f10, $f0	# f10 = f(a)
 
 c.eq.s 1 $f10, $f1	# f(a) = 0
 li $v0, 0		# v0 = 0
 mov.s $f0, $f12	# f0 = a
 bc1t 1 SalirGeneral	# si se cumple
 
 mov.s $f16, $f13
 
 jal Funcion 		# calculamos f(b)
 
 mov.s $f11, $f0	# f11 = f(b)
 
 c.eq.s 1 $f11, $f1	# f(b) = 0
 li $v0, 0		# v0 = 0
 mov.s $f0, $f13	# f0 = b
 bc1t 1 SalirGeneral	# si se cumple
 
 c.lt.s 1 $f10, $f1	# comparamos f(a) < 0
 
 bc1t 1 Signo1		# si se cumple f(a) < 0
 
 bc1f 1 Signo2 		# si no se cumple f(a) < 0
 
 Signo1:
 
 c.lt.s 1 $f11, $f1	# comparamos f(b) < 0
 
 bc1t 1 PreSalirIncorrecto	# si se cumple f(b) < 0 (signos iguales)
 
 jal Recur		# llamamos a Recur
 
 j SalirGeneral		# salimos de Bisec
 
 Signo2:
 
 c.lt.s 1 $f11, $f1	# comparamos f(b) < 0
 
 bc1f 1 PreSalirIncorrecto	# si no se cumple f(b) < 0 (signos iguales)
 
 jal Recur		# llamamos a Recur
 
 j SalirGeneral		# salimos de Bisec
  
 PreSalirIncorrecto:

 la $a0, Mensaje	# cargamos el mensaje de error en a0
 li $v0, 1		# cargamos en $v0 = 1
 
 SalirGeneral: 
 
 lw $ra, 0($sp)	
 addi $sp, $sp, 4	# cargamos $ra de la pila
 
 jr $ra			# salimos al main
 
 Recur:
 
 addi $sp, $sp, -4	
 sw $ra, 0($sp)		# guardamos en pila $ra
 
 mov.s $f16, $f12	
 
 PasoP:
 
 sub.s $f9, $f12, $f13	# f9 = a-b
 abs.s $f9, $f9		# f9 = |a-b|
 
 c.lt.s 1 $f9, $f14	# comparamos |a-b| < tolerancia
 bc1t 1 PreSalirCorrecto2	# si se cumple
 
 Paso2:
 
 la $t0, Cero
 lwc1  $f9, 0($t0)	# vaciamos el registro f9 para reusarlo
 
 add.s $f9, $f12, $f13	# f9 = a+b	
 div.s $f9, $f9, $f2	# f9 = f9/2 (p)
 
 mov.s $f16, $f9
 
 jal Funcion 
 
 c.eq.s 1 $f0, $f1	# f(p) = 0
 
 bc1t 1 PreSalirCorrecto	# si se cumple
 
 c.lt.s 1 $f10, $f1	# f(a) < 0
 
 bc1t 1 PasoA1		# si se cumple
 bc1f 1 PasoA2		# si no se cumple
 
 PasoB:
 
 c.lt.s 1 $f11, $f1	# f(b) < 0
 
 bc1t 1 PasoB1		# si se cumple
 bc1f 1 PasoB2		# si no se cumple
 
 PasoA1:
 
 c.lt.s 1 $f0, $f1	# f(p) < 0
 bc1t 1 SustAP		# si se cumple
 bc1f 1 PasoB		# si no se cumple
 
 PasoA2:
 
 c.lt.s 1 $f0, $f1	# f(p) < 0
 bc1f 1 SustAP		# si no se cumple
 bc1t 1 PasoB		# si se cumple
 
 SustAP:
 
 mov.s $f12, $f9	# sustituye a por p
 
 jal Recur		# llamamos a Recur
 
 j Salir		
 
 PasoB1:
 
 c.lt.s 1 $f0, $f1	# f(p) < 0
 bc1t 1 SustBP		# si se cumple
 
 PasoB2:
 
 c.lt.s 1 $f0, $f1	# f(p) < 0
 bc1f 1 SustBP		# si no se cumple
 
 SustBP:
 
 mov.s $f13, $f9	# sustituye b por p
 jal Recur 		# llamamos a Recur
 j Salir
 
 PreSalirCorrecto:

 mov.s $f0, $f9		# f0 = p
 li $v0, 0		# cargamos en $v0 = 0
 j Salir
 
 PreSalirCorrecto2:
 
 la $t0, Cero
 lwc1  $f9, 0($t0)	# vaciamos el registro f9 para reusarlo
 
 add.s $f9, $f12, $f13	# f9 = a+b	
 div.s $f9, $f9, $f2	# f9 = f9/2 (p)
 
 mov.s $f0, $f9		# f0 = p
 li $v0, 0		# cargamos en $v0 = 0
 
 j Salir
 
 Salir:
 
 lw $ra, 0($sp)
 addi $sp, $sp, 4	# cargamos $ra de la pila
 
 jr $ra
