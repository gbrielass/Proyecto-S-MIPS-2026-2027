.data
cadena:  .asciiz "ARQUITECTURA DE COMPUTADORAS"
mensaje: .asciiz "Introduce k: "
salto:   .asciiz "\n"

.text
.globl main
main:
    li   $v0, 4                # Mostrar la peticion.
    la   $a0, mensaje
    syscall

    li   $v0, 5                # Leer k; el resultado llega en v0.
    syscall
    move $s0, $v0

normalizar_negativos:
    slti $t2, $s0, 0           # Si k < 0, sumar vueltas de 26.
    beq  $t2, $zero, normalizar_positivos
    addi $s0, $s0, 26
    j    normalizar_negativos

normalizar_positivos:
    slti $t2, $s0, 26          # Si k >= 26, quitar vueltas completas.
    bne  $t2, $zero, iniciar
    addi $s0, $s0, -26
    j    normalizar_positivos

iniciar:
    la   $t0, cadena           # Direccion del primer caracter.

bucle:
    lbu  $t1, 0($t0)           # Leer un byte sin extension de signo.
    beq  $t1, $zero, fin       # No cifrar el terminador nulo.

    li   $t2, 32               # ASCII del espacio.
    beq  $t1, $t2, siguiente   # Conservar los espacios.

    add  $t1, $t1, $s0         # Desplazar la letra.
    slti $t2, $t1, 91          # Resultado <= 'Z' (90).
    bne  $t2, $zero, guardar
    addi $t1, $t1, -26         # Volver al inicio del alfabeto.

guardar:
    sb   $t1, 0($t0)           # Reemplazar el caracter original.

siguiente:
    addi $t0, $t0, 1           # Avanzar un byte.
    j    bucle

fin:
    li   $v0, 4                # Imprimir la cadena ya modificada.
    la   $a0, cadena
    syscall

    li   $v0, 4
    la   $a0, salto
    syscall

    li   $v0, 10               # Terminar.
    syscall
